import { useState, useRef, useImperativeHandle, forwardRef, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { Check, Plus, Settings, Pencil, Trash2 } from 'lucide-react-native';
import { useColorScheme, FlatList } from 'react-native';
import { YStack, XStack, Text } from 'tamagui';
import GorhomBottomSheet from '@gorhom/bottom-sheet';

import { BottomSheet, ProgressBar } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';
import type { GoalDisplay } from '../types';

// 格式化秒数为可读时间
function formatDuration(seconds: number): string {
  if (seconds < 60) return `${seconds}s`;
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (h > 0) return `${h}h${m > 0 ? `${m}m` : ''}`;
  return `${m}m`;
}

type GoalSwitcherProps = {
  goals: GoalDisplay[];
  currentGoalId: string | null;
  onSelect: (goalId: string) => void;
  onAddGoal?: () => void;
  onEditGoal?: (goalId: string) => void;
  onDeleteGoal?: (goalId: string) => void;
};

export type GoalSwitcherRef = {
  open: () => void;
  close: () => void;
};

// 目标切换抽屉
export const GoalSwitcher = forwardRef<GoalSwitcherRef, GoalSwitcherProps>(
  function GoalSwitcher(
    { goals, currentGoalId, onSelect, onAddGoal, onEditGoal, onDeleteGoal },
    ref,
  ) {
    const { t } = useTranslation('goals');
    const colorScheme = useColorScheme();
    const theme = colorScheme === 'dark' ? colors.dark : colors.light;

    const sheetRef = useRef<GorhomBottomSheet>(null);
    const [manageMode, setManageMode] = useState(false);

    useImperativeHandle(ref, () => ({
      open: () => {
        setManageMode(false);
        sheetRef.current?.snapToIndex(0);
      },
      close: () => {
        sheetRef.current?.close();
      },
    }));

    const handleSelect = useCallback(
      (goalId: string) => {
        if (manageMode) return;
        onSelect(goalId);
        sheetRef.current?.close();
      },
      [manageMode, onSelect],
    );

    const handleClose = useCallback(() => {
      setManageMode(false);
    }, []);

    return (
      <BottomSheet sheetRef={sheetRef} snapPoints={['50%', '75%']} onClose={handleClose}>
        <YStack flex={1} paddingHorizontal="$4" paddingTop="$2">
          {/* 标题 */}
          <XStack alignItems="center" marginBottom="$3">
            <Text fontSize="$5" fontWeight="bold" flex={1}>
              {t('switchGoal')}
            </Text>
          </XStack>

          {/* 目标列表 */}
          <FlatList
            data={goals}
            keyExtractor={(item) => item.id}
            renderItem={({ item }) => {
              const isSelected = item.id === currentGoalId;
              return (
                <XStack
                  paddingVertical="$3"
                  paddingHorizontal="$3"
                  borderRadius="$3"
                  backgroundColor={isSelected ? '$backgroundHover' : 'transparent'}
                  alignItems="center"
                  gap="$3"
                  onPress={() => handleSelect(item.id)}
                  pressStyle={manageMode ? undefined : { opacity: 0.7 }}
                >
                  {/* 颜色指示圆点 */}
                  <YStack
                    width={10}
                    height={10}
                    borderRadius={5}
                    backgroundColor={item.color || theme.accent}
                  />

                  {/* 标题 + 进度 */}
                  <YStack flex={1} gap="$1">
                    <Text fontSize="$4" color="$color" numberOfLines={1}>
                      {item.title}
                    </Text>
                    <XStack alignItems="center" gap="$2">
                      <YStack flex={1}>
                        <ProgressBar
                          progress={item.progress}
                          height={4}
                          color={theme.accent}
                          trackColor={theme.border}
                        />
                      </YStack>
                      <Text fontSize="$1" color="$placeholderColor">
                        {formatDuration(item.effectiveTime)} / {formatDuration(item.estimatedTime)}
                      </Text>
                    </XStack>
                  </YStack>

                  {/* 管理模式：编辑/删除按钮 */}
                  {manageMode && (
                    <XStack gap="$2">
                      <YStack
                        padding="$2"
                        onPress={() => onEditGoal?.(item.id)}
                        pressStyle={{ opacity: 0.7 }}
                      >
                        <Pencil size={18} color={theme.textSecondary} />
                      </YStack>
                      <YStack
                        padding="$2"
                        onPress={() => onDeleteGoal?.(item.id)}
                        pressStyle={{ opacity: 0.7 }}
                      >
                        <Trash2 size={18} color={theme.error} />
                      </YStack>
                    </XStack>
                  )}

                  {/* 非管理模式：选中勾选 */}
                  {!manageMode && isSelected && (
                    <Check size={18} color={theme.accent} />
                  )}
                </XStack>
              );
            }}
          />

          {/* 底部操作栏 */}
          <XStack
            paddingVertical="$3"
            borderTopWidth={1}
            borderTopColor="$borderColor"
            gap="$3"
            justifyContent="center"
          >
            {/* 添加新目标 */}
            <XStack
              flex={1}
              alignItems="center"
              justifyContent="center"
              gap="$2"
              paddingVertical="$2"
              borderRadius="$3"
              backgroundColor="$backgroundPress"
              onPress={onAddGoal}
              pressStyle={{ opacity: 0.7 }}
            >
              <Plus size={18} color={theme.accent} />
              <Text fontSize="$3" color={theme.accent}>
                {t('addGoal')}
              </Text>
            </XStack>

            {/* 管理目标 */}
            <XStack
              flex={1}
              alignItems="center"
              justifyContent="center"
              gap="$2"
              paddingVertical="$2"
              borderRadius="$3"
              backgroundColor={manageMode ? theme.accent : '$backgroundPress'}
              onPress={() => setManageMode((prev) => !prev)}
              pressStyle={{ opacity: 0.7 }}
            >
              <Settings size={18} color={manageMode ? '#FFF' : theme.textSecondary} />
              <Text fontSize="$3" color={manageMode ? '#FFF' : '$placeholderColor'}>
                {t('manageGoals')}
              </Text>
            </XStack>
          </XStack>
        </YStack>
      </BottomSheet>
    );
  },
);
