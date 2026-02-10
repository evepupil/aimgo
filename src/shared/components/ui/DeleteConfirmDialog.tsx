import { Modal, Pressable, StyleSheet } from 'react-native';
import { YStack, XStack, Text } from 'tamagui';
import { useColorScheme } from 'react-native';
import { useTranslation } from 'react-i18next';

import { colors, radius, spacing } from '@/src/constants/theme';

type DeleteConfirmDialogProps = {
  visible: boolean;
  title: string;
  message: string;
  onConfirm: () => void;
  onCancel: () => void;
};

// 删除确认弹窗
export function DeleteConfirmDialog({
  visible,
  title,
  message,
  onConfirm,
  onCancel,
}: DeleteConfirmDialogProps) {
  const { t } = useTranslation('common');
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onCancel}
    >
      {/* 半透明遮罩层 */}
      <Pressable style={styles.overlay} onPress={onCancel}>
        {/* 阻止点击卡片区域关闭弹窗 */}
        <Pressable onPress={(e) => e.stopPropagation()}>
          <YStack
            backgroundColor={theme.card}
            borderRadius={radius.lg}
            padding={spacing.lg}
            width={300}
            borderWidth={1}
            borderColor={theme.border}
            gap="$3"
          >
            {/* 标题 */}
            <Text
              fontSize="$5"
              fontWeight="bold"
              color={theme.text}
            >
              {title}
            </Text>

            {/* 描述信息 */}
            <Text
              fontSize="$3"
              color={theme.textSecondary}
              lineHeight={22}
            >
              {message}
            </Text>

            {/* 操作按钮 */}
            <XStack gap="$3" marginTop="$2">
              {/* 取消按钮 */}
              <YStack
                flex={1}
                alignItems="center"
                justifyContent="center"
                paddingVertical="$2.5"
                borderRadius={radius.sm}
                backgroundColor={theme.cardHover}
                pressStyle={{ opacity: 0.7 }}
                onPress={onCancel}
              >
                <Text fontSize="$3" fontWeight="600" color={theme.textSecondary}>
                  {t('cancel')}
                </Text>
              </YStack>

              {/* 删除确认按钮 */}
              <YStack
                flex={1}
                alignItems="center"
                justifyContent="center"
                paddingVertical="$2.5"
                borderRadius={radius.sm}
                backgroundColor={theme.error}
                pressStyle={{ opacity: 0.7 }}
                onPress={onConfirm}
              >
                <Text fontSize="$3" fontWeight="600" color="#FFFFFF">
                  {t('delete')}
                </Text>
              </YStack>
            </XStack>
          </YStack>
        </Pressable>
      </Pressable>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
