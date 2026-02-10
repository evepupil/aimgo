import { useState, useRef, useImperativeHandle, forwardRef, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { Check, X, Calendar } from 'lucide-react-native';
import { useColorScheme } from 'react-native';
import { YStack, XStack, Text, Input, TextArea, ScrollView } from 'tamagui';
import type GorhomBottomSheet from '@gorhom/bottom-sheet';

import { BottomSheet } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';

// 预设颜色列表
const COLOR_PRESETS = [
  '#6366F1', // Indigo（默认）
  '#EC4899', // Pink
  '#F97316', // Orange
  '#22C55E', // Green
  '#06B6D4', // Cyan
  '#8B5CF6', // Violet
  '#EF4444', // Red
  '#F59E0B', // Amber
];

// 默认颜色
const DEFAULT_COLOR = COLOR_PRESETS[0];

// 表单提交数据
type GoalFormData = {
  title: string;
  description: string;
  color: string;
  deadline: number | null;
};

type GoalFormSheetProps = {
  onSubmit: (data: GoalFormData, goalId?: string) => void;
};

export type GoalFormSheetRef = {
  openCreate: () => void;
  openEdit: (goal: {
    id: string;
    title: string;
    description: string;
    color: string;
    deadline: number | null;
  }) => void;
  close: () => void;
};

// 格式化时间戳为日期字符串
function formatDate(timestamp: number): string {
  const date = new Date(timestamp);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// 目标创建/编辑表单 BottomSheet
export const GoalFormSheet = forwardRef<GoalFormSheetRef, GoalFormSheetProps>(
  function GoalFormSheet({ onSubmit }, ref) {
    const { t } = useTranslation('goals');
    const colorScheme = useColorScheme();
    const theme = colorScheme === 'dark' ? colors.dark : colors.light;

    const sheetRef = useRef<GorhomBottomSheet>(null);

    // 表单状态
    const [mode, setMode] = useState<'create' | 'edit'>('create');
    const [editGoalId, setEditGoalId] = useState<string | null>(null);
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [color, setColor] = useState(DEFAULT_COLOR);
    const [deadline, setDeadline] = useState<number | null>(null);
    const [titleError, setTitleError] = useState(false);

    const isEditMode = mode === 'edit';

    // 重置表单到默认值
    const resetForm = useCallback(() => {
      setTitle('');
      setDescription('');
      setColor(DEFAULT_COLOR);
      setDeadline(null);
      setTitleError(false);
      setEditGoalId(null);
    }, []);

    useImperativeHandle(ref, () => ({
      openCreate: () => {
        setMode('create');
        resetForm();
        sheetRef.current?.snapToIndex(0);
      },
      openEdit: (goal) => {
        setMode('edit');
        setEditGoalId(goal.id);
        setTitle(goal.title);
        setDescription(goal.description);
        setColor(goal.color || DEFAULT_COLOR);
        setDeadline(goal.deadline);
        setTitleError(false);
        sheetRef.current?.snapToIndex(0);
      },
      close: () => {
        sheetRef.current?.close();
      },
    }));

    // 提交表单
    const handleSubmit = useCallback(() => {
      const trimmedTitle = title.trim();
      if (!trimmedTitle) {
        setTitleError(true);
        return;
      }

      onSubmit(
        {
          title: trimmedTitle,
          description: description.trim(),
          color,
          deadline,
        },
        isEditMode && editGoalId ? editGoalId : undefined,
      );

      sheetRef.current?.close();
    }, [title, description, color, deadline, isEditMode, editGoalId, onSubmit]);

    // 切换截止日期（简单实现：设置为 30 天后 / 清除）
    const handleToggleDeadline = useCallback(() => {
      if (deadline) {
        // 已有截止日期，清除
        setDeadline(null);
      } else {
        // 无截止日期，默认设置为 30 天后
        const thirtyDaysLater = Date.now() + 30 * 24 * 60 * 60 * 1000;
        setDeadline(thirtyDaysLater);
      }
    }, [deadline]);

    // 关闭时重置错误状态
    const handleClose = useCallback(() => {
      setTitleError(false);
    }, []);

    return (
      <BottomSheet sheetRef={sheetRef} snapPoints={['70%']} onClose={handleClose}>
        <ScrollView flex={1} paddingHorizontal="$4" paddingTop="$2" keyboardShouldPersistTaps="handled">
          {/* 标题栏 */}
          <XStack alignItems="center" justifyContent="space-between" marginBottom="$4">
            <Text fontSize="$6" fontWeight="bold">
              {isEditMode ? t('editGoal') : t('createGoal')}
            </Text>
            <YStack
              padding="$2"
              borderRadius="$round"
              onPress={() => sheetRef.current?.close()}
              pressStyle={{ opacity: 0.7 }}
            >
              <X size={20} color={theme.textSecondary} />
            </YStack>
          </XStack>

          {/* 目标名称输入 */}
          <YStack marginBottom="$4" gap="$2">
            <Text fontSize="$3" color="$placeholderColor">
              {t('goalName')}
            </Text>
            <Input
              value={title}
              onChangeText={(text: string) => {
                setTitle(text);
                if (titleError) setTitleError(false);
              }}
              placeholder={t('goalNamePlaceholder')}
              borderColor={titleError ? theme.error : '$borderColor'}
              borderWidth={1}
              borderRadius="$3"
              padding="$3"
              fontSize="$4"
            />
            {titleError && (
              <Text fontSize="$2" color={theme.error}>
                {t('titleRequired')}
              </Text>
            )}
          </YStack>

          {/* 目标描述输入 */}
          <YStack marginBottom="$4" gap="$2">
            <Text fontSize="$3" color="$placeholderColor">
              {t('descriptionLabel')}
            </Text>
            <TextArea
              value={description}
              onChangeText={setDescription}
              placeholder={t('descriptionPlaceholder')}
              borderWidth={1}
              borderColor="$borderColor"
              borderRadius="$3"
              padding="$3"
              fontSize="$4"
              numberOfLines={3}
              minHeight={80}
            />
          </YStack>

          {/* 颜色选择 */}
          <YStack marginBottom="$4" gap="$2">
            <Text fontSize="$3" color="$placeholderColor">
              {t('goalColor')}
            </Text>
            <XStack gap="$3" flexWrap="wrap">
              {COLOR_PRESETS.map((preset) => {
                const isSelected = color === preset;
                return (
                  <YStack
                    key={preset}
                    width={40}
                    height={40}
                    borderRadius={20}
                    backgroundColor={preset}
                    alignItems="center"
                    justifyContent="center"
                    borderWidth={isSelected ? 3 : 0}
                    borderColor={isSelected ? '#FFFFFF' : 'transparent'}
                    onPress={() => setColor(preset)}
                    pressStyle={{ opacity: 0.7, scale: 0.95 }}
                  >
                    {isSelected && <Check size={18} color="#FFFFFF" strokeWidth={3} />}
                  </YStack>
                );
              })}
            </XStack>
          </YStack>

          {/* 截止日期 */}
          <YStack marginBottom="$4" gap="$2">
            <Text fontSize="$3" color="$placeholderColor">
              {t('goalDeadline')}
            </Text>
            <XStack
              alignItems="center"
              borderWidth={1}
              borderColor="$borderColor"
              borderRadius="$3"
              paddingHorizontal="$3"
              paddingVertical="$3"
              gap="$2"
              onPress={handleToggleDeadline}
              pressStyle={{ opacity: 0.7 }}
            >
              <Calendar size={18} color={deadline ? theme.accent : theme.textMuted} />
              <Text
                flex={1}
                fontSize="$3"
                color={deadline ? '$color' : '$placeholderColor'}
              >
                {deadline ? formatDate(deadline) : t('setDeadline')}
              </Text>
              {deadline && (
                <YStack
                  padding="$1"
                  borderRadius="$round"
                  onPress={(e) => {
                    e.stopPropagation();
                    setDeadline(null);
                  }}
                  pressStyle={{ opacity: 0.7 }}
                >
                  <X size={16} color={theme.textSecondary} />
                </YStack>
              )}
            </XStack>
          </YStack>

          {/* 保存按钮 */}
          <YStack
            backgroundColor={theme.accent}
            paddingVertical="$3"
            borderRadius="$3"
            alignItems="center"
            onPress={handleSubmit}
            pressStyle={{ opacity: 0.8 }}
            marginBottom="$4"
          >
            <Text fontSize="$4" fontWeight="600" color="#FFF">
              {isEditMode ? t('save') : t('create')}
            </Text>
          </YStack>
        </ScrollView>
      </BottomSheet>
    );
  },
);
