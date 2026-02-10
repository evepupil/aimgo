import { useState, useRef, useImperativeHandle, forwardRef, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { useColorScheme } from 'react-native';
import { XStack, YStack, Text, Input, ScrollView } from 'tamagui';
import type GorhomBottomSheet from '@gorhom/bottom-sheet';

import { BottomSheet } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';

type TaskFormData = {
  title: string;
  estimatedTime: number; // 秒
};

type TaskFormSheetProps = {
  onSubmit: (data: TaskFormData, taskId?: string) => void;
};

export type TaskFormSheetRef = {
  openCreate: () => void;
  openEdit: (task: { id: string; title: string; estimatedTime: number }) => void;
  close: () => void;
};

// 任务创建/编辑表单
export const TaskFormSheet = forwardRef<TaskFormSheetRef, TaskFormSheetProps>(
  function TaskFormSheet({ onSubmit }, ref) {
    const { t } = useTranslation('goals');
    const colorScheme = useColorScheme();
    const theme = colorScheme === 'dark' ? colors.dark : colors.light;

    const sheetRef = useRef<GorhomBottomSheet>(null);
    const [editingId, setEditingId] = useState<string | null>(null);
    const [title, setTitle] = useState('');
    const [estimatedMinutes, setEstimatedMinutes] = useState('');
    const [titleError, setTitleError] = useState(false);

    const isEditMode = editingId !== null;

    useImperativeHandle(ref, () => ({
      openCreate: () => {
        setEditingId(null);
        setTitle('');
        setEstimatedMinutes('');
        setTitleError(false);
        sheetRef.current?.snapToIndex(0);
      },
      openEdit: (task) => {
        setEditingId(task.id);
        setTitle(task.title);
        setEstimatedMinutes(
          task.estimatedTime > 0 ? String(Math.round(task.estimatedTime / 60)) : '',
        );
        setTitleError(false);
        sheetRef.current?.snapToIndex(0);
      },
      close: () => sheetRef.current?.close(),
    }));

    const handleSubmit = useCallback(() => {
      const trimmedTitle = title.trim();
      if (!trimmedTitle) {
        setTitleError(true);
        return;
      }

      const minutes = parseInt(estimatedMinutes, 10);
      const seconds = isNaN(minutes) || minutes <= 0 ? 0 : minutes * 60;

      onSubmit(
        { title: trimmedTitle, estimatedTime: seconds },
        editingId ?? undefined,
      );
      sheetRef.current?.close();
    }, [title, estimatedMinutes, editingId, onSubmit]);

    return (
      <BottomSheet sheetRef={sheetRef} snapPoints={['45%']}>
        <ScrollView flex={1} paddingHorizontal="$4" paddingTop="$2" keyboardShouldPersistTaps="handled">
          {/* 标题 */}
          <Text fontSize="$6" fontWeight="bold" marginBottom="$4">
            {isEditMode ? t('editTask') : t('addTask')}
          </Text>

          {/* 任务名称 */}
          <YStack marginBottom="$4" gap="$2">
            <Text fontSize="$3" color="$placeholderColor">
              {t('taskName')}
            </Text>
            <Input
              value={title}
              onChangeText={(text) => {
                setTitle(text);
                if (titleError) setTitleError(false);
              }}
              placeholder={t('taskNamePlaceholder')}
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

          {/* 预估时间 */}
          <YStack marginBottom="$4" gap="$2">
            <Text fontSize="$3" color="$placeholderColor">
              {t('estimatedTime')}
            </Text>
            <XStack alignItems="center" gap="$2">
              <Input
                flex={1}
                value={estimatedMinutes}
                onChangeText={setEstimatedMinutes}
                placeholder="0"
                keyboardType="number-pad"
                borderWidth={1}
                borderColor="$borderColor"
                borderRadius="$3"
                padding="$3"
                fontSize="$4"
              />
              <Text fontSize="$3" color="$placeholderColor">
                {t('minutes')}
              </Text>
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
