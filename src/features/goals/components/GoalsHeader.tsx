import { useTranslation } from 'react-i18next';
import { Search, ChevronDown } from 'lucide-react-native';
import { useColorScheme } from 'react-native';
import { XStack, YStack, Text } from 'tamagui';

import { ScreenHeader } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';

type GoalsHeaderProps = {
  currentGoalTitle: string | null;
  onGoalPress?: () => void;
  onSearchPress?: () => void;
};

export function GoalsHeader({
  currentGoalTitle,
  onGoalPress,
  onSearchPress,
}: GoalsHeaderProps) {
  const { t } = useTranslation('goals');
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  return (
    <YStack>
      <ScreenHeader
        title={t('title')}
        rightActions={[
          {
            icon: <Search size={22} color={theme.textSecondary} />,
            onPress: onSearchPress ?? (() => {}),
          },
        ]}
      />

      {/* 当前目标切换按钮 */}
      {currentGoalTitle && (
        <XStack
          paddingHorizontal="$4"
          paddingBottom="$2"
          backgroundColor="$background"
          alignItems="center"
          gap="$1"
          onPress={onGoalPress}
          pressStyle={{ opacity: 0.7 }}
        >
          <Text fontSize="$3" color="$placeholderColor" numberOfLines={1} maxWidth="80%">
            {currentGoalTitle}
          </Text>
          <ChevronDown size={14} color={theme.textMuted} />
        </XStack>
      )}
    </YStack>
  );
}
