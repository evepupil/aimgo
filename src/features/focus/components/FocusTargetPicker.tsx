import { useState, useRef, useCallback, useImperativeHandle, forwardRef } from 'react';
import { useTranslation } from 'react-i18next';
import { ArrowLeft, Check } from 'lucide-react-native';
import { useColorScheme, FlatList } from 'react-native';
import { YStack, XStack, Text } from 'tamagui';
import GorhomBottomSheet from '@gorhom/bottom-sheet';

import { BottomSheet } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';
import { useFocusGoals, useFocusMilestones, useFocusTasks } from '../hooks';
import type { FocusTarget } from '../types';

type FocusTargetPickerProps = {
  currentTarget: FocusTarget;
  onSelect: (target: FocusTarget) => void;
};

export type FocusTargetPickerRef = {
  open: () => void;
  close: () => void;
};

// 三级逐步选择：目标 → 里程碑 → 任务
type PickerStep = 'goal' | 'milestone' | 'task';

export const FocusTargetPicker = forwardRef<FocusTargetPickerRef, FocusTargetPickerProps>(
  function FocusTargetPicker({ currentTarget, onSelect }, ref) {
    const { t } = useTranslation('focus');
    const colorScheme = useColorScheme();
    const theme = colorScheme === 'dark' ? colors.dark : colors.light;

    const sheetRef = useRef<GorhomBottomSheet>(null);
    const [step, setStep] = useState<PickerStep>('goal');

    // 临时选中状态
    const [selectedGoalId, setSelectedGoalId] = useState<string | null>(null);
    const [selectedGoalTitle, setSelectedGoalTitle] = useState<string | null>(null);
    const [selectedMilestoneId, setSelectedMilestoneId] = useState<string | null>(null);
    const [selectedMilestoneTitle, setSelectedMilestoneTitle] = useState<string | null>(null);

    // 数据源
    const goals = useFocusGoals();
    const milestones = useFocusMilestones(selectedGoalId);
    const tasks = useFocusTasks(selectedMilestoneId);

    useImperativeHandle(ref, () => ({
      open: () => {
        setStep('goal');
        setSelectedGoalId(currentTarget.goalId);
        setSelectedGoalTitle(currentTarget.goalTitle);
        setSelectedMilestoneId(currentTarget.milestoneId);
        setSelectedMilestoneTitle(currentTarget.milestoneTitle);
        sheetRef.current?.snapToIndex(0);
      },
      close: () => {
        sheetRef.current?.close();
      },
    }));

    // 选中目标
    const handleGoalSelect = useCallback((id: string, title: string) => {
      setSelectedGoalId(id);
      setSelectedGoalTitle(title);
      setSelectedMilestoneId(null);
      setSelectedMilestoneTitle(null);
      setStep('milestone');
    }, []);

    // 选中里程碑
    const handleMilestoneSelect = useCallback((id: string, title: string) => {
      setSelectedMilestoneId(id);
      setSelectedMilestoneTitle(title);
      setStep('task');
    }, []);

    // 选中任务 → 完成选择
    const handleTaskSelect = useCallback(
      (id: string, title: string) => {
        onSelect({
          goalId: selectedGoalId,
          goalTitle: selectedGoalTitle,
          milestoneId: selectedMilestoneId,
          milestoneTitle: selectedMilestoneTitle,
          taskId: id,
          taskTitle: title,
        });
        sheetRef.current?.close();
      },
      [selectedGoalId, selectedGoalTitle, selectedMilestoneId, selectedMilestoneTitle, onSelect],
    );

    // 跳过里程碑/任务，直接以目标为专注对象
    const handleSkipToGoal = useCallback(() => {
      onSelect({
        goalId: selectedGoalId,
        goalTitle: selectedGoalTitle,
        milestoneId: null,
        milestoneTitle: null,
        taskId: null,
        taskTitle: null,
      });
      sheetRef.current?.close();
    }, [selectedGoalId, selectedGoalTitle, onSelect]);

    // 跳过任务，以里程碑为专注对象
    const handleSkipToMilestone = useCallback(() => {
      onSelect({
        goalId: selectedGoalId,
        goalTitle: selectedGoalTitle,
        milestoneId: selectedMilestoneId,
        milestoneTitle: selectedMilestoneTitle,
        taskId: null,
        taskTitle: null,
      });
      sheetRef.current?.close();
    }, [selectedGoalId, selectedGoalTitle, selectedMilestoneId, selectedMilestoneTitle, onSelect]);

    const handleBack = useCallback(() => {
      if (step === 'task') setStep('milestone');
      else if (step === 'milestone') setStep('goal');
    }, [step]);

    // 获取当前步骤标题
    const stepTitle =
      step === 'goal'
        ? t('pickGoal')
        : step === 'milestone'
          ? t('pickMilestone')
          : t('pickTask');

    return (
      <BottomSheet sheetRef={sheetRef} snapPoints={['60%', '80%']}>
        <YStack flex={1} paddingHorizontal="$4" paddingTop="$2">
          {/* 标题栏 */}
          <XStack alignItems="center" marginBottom="$3" gap="$2">
            {step !== 'goal' && (
              <YStack onPress={handleBack} padding="$1">
                <ArrowLeft size={20} color={theme.text} />
              </YStack>
            )}
            <Text fontSize="$5" fontWeight="bold" flex={1}>
              {stepTitle}
            </Text>
            {/* 跳过按钮 */}
            {step === 'milestone' && selectedGoalId && (
              <Text
                fontSize="$3"
                color={theme.accent}
                onPress={handleSkipToGoal}
                pressStyle={{ opacity: 0.7 }}
              >
                {t('skipSelectGoalOnly')}
              </Text>
            )}
            {step === 'task' && selectedMilestoneId && (
              <Text
                fontSize="$3"
                color={theme.accent}
                onPress={handleSkipToMilestone}
                pressStyle={{ opacity: 0.7 }}
              >
                {t('skipSelectMilestoneOnly')}
              </Text>
            )}
          </XStack>

          {/* 目标列表 */}
          {step === 'goal' && (
            <FlatList
              data={goals}
              keyExtractor={(item) => item.id}
              renderItem={({ item }) => (
                <XStack
                  paddingVertical="$3"
                  paddingHorizontal="$3"
                  borderRadius="$3"
                  backgroundColor={item.id === currentTarget.goalId ? '$backgroundHover' : 'transparent'}
                  alignItems="center"
                  onPress={() => handleGoalSelect(item.id, item.title)}
                  pressStyle={{ opacity: 0.7 }}
                >
                  <Text flex={1} fontSize="$4" color="$color">
                    {item.title}
                  </Text>
                  {item.id === currentTarget.goalId && (
                    <Check size={18} color={theme.accent} />
                  )}
                </XStack>
              )}
            />
          )}

          {/* 里程碑列表 */}
          {step === 'milestone' && (
            <FlatList
              data={milestones}
              keyExtractor={(item) => item.id}
              renderItem={({ item }) => (
                <XStack
                  paddingVertical="$3"
                  paddingHorizontal="$3"
                  borderRadius="$3"
                  backgroundColor={
                    item.id === currentTarget.milestoneId ? '$backgroundHover' : 'transparent'
                  }
                  alignItems="center"
                  onPress={() => handleMilestoneSelect(item.id, item.title)}
                  pressStyle={{ opacity: 0.7 }}
                >
                  <Text flex={1} fontSize="$4" color="$color">
                    {item.title}
                  </Text>
                  {item.id === currentTarget.milestoneId && (
                    <Check size={18} color={theme.accent} />
                  )}
                </XStack>
              )}
            />
          )}

          {/* 任务列表 */}
          {step === 'task' && (
            <FlatList
              data={tasks}
              keyExtractor={(item) => item.id}
              renderItem={({ item }) => (
                <XStack
                  paddingVertical="$3"
                  paddingHorizontal="$3"
                  borderRadius="$3"
                  backgroundColor={item.id === currentTarget.taskId ? '$backgroundHover' : 'transparent'}
                  alignItems="center"
                  onPress={() => handleTaskSelect(item.id, item.title)}
                  pressStyle={{ opacity: 0.7 }}
                >
                  <Text flex={1} fontSize="$4" color="$color">
                    {item.title}
                  </Text>
                  {item.id === currentTarget.taskId && (
                    <Check size={18} color={theme.accent} />
                  )}
                </XStack>
              )}
            />
          )}
        </YStack>
      </BottomSheet>
    );
  },
);
