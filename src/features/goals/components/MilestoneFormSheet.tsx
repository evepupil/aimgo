import { useState, useRef, useImperativeHandle, forwardRef, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { useColorScheme } from 'react-native';
import { YStack, Text, Input, TextArea, ScrollView } from 'tamagui';
import type GorhomBottomSheet from '@gorhom/bottom-sheet';

import { BottomSheet } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';

type MilestoneFormData = {
  title: string;
  description: string;
  deadline: number | null;
};

type MilestoneFormSheetProps = {
  onSubmit: (data: MilestoneFormData, milestoneId?: string) => void;
};

export type MilestoneFormSheetRef = {
  openCreate: () => void;
  openEdit: (milestone: {
    id: string;
    title: string;
    description: string;
    deadline: number | null;
  }) => void;
  close: () => void;
};

// 里程碑创建/编辑表单
export const MilestoneFormSheet = forwardRef<MilestoneFormSheetRef, MilestoneFormSheetProps>(
  function MilestoneFormSheet({ onSubmit }, ref) {
    const { t } = useTranslation('goals');
    const colorScheme = useColorScheme();
    const theme = colorScheme === 'dark' ? colors.dark : colors.light;

    const sheetRef = useRef<GorhomBottomSheet>(null);
    const [editingId, setEditingId] = useState<string | null>(null);
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [titleError, setTitleError] = useState(false);

    const isEditMode = editingId !== null;

    useImperativeHandle(ref, () => ({
      openCreate: () => {
        setEditingId(null);
        setTitle('');
        setDescription('');
        setTitleError(false);
        sheetRef.current?.snapToIndex(0);
      },
      openEdit: (milestone) => {
        setEditingId(milestone.id);
        setTitle(milestone.title);
        setDescription(milestone.description);
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

      onSubmit(
        {
          title: trimmedTitle,
          description: description.trim(),
          deadline: null,
        },
        editingId ?? undefined,
      );
      sheetRef.current?.close();
    }, [title, description, editingId, onSubmit]);

    return (
      <BottomSheet sheetRef={sheetRef} snapPoints={['55%']}>
        <ScrollView flex={1} paddingHorizontal="$4" paddingTop="$2" keyboardShouldPersistTaps="handled">
          {/* 标题 */}
          <Text fontSize="$6" fontWeight="bold" marginBottom="$4">
            {isEditMode ? t('editMilestone') : t('addMilestone')}
          </Text>

          {/* 里程碑名称 */}
          <YStack marginBottom="$4" gap="$2">
            <Text fontSize="$3" color="$placeholderColor">
              {t('milestoneName')}
            </Text>
            <Input
              value={title}
              onChangeText={(text: string) => {
                setTitle(text);
                if (titleError) setTitleError(false);
              }}
              placeholder={t('milestoneNamePlaceholder')}
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

          {/* 描述 */}
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
