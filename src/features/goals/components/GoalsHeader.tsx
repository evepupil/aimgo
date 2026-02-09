import { useTranslation } from 'react-i18next';
import { Search } from 'lucide-react-native';
import { useColorScheme } from 'react-native';
import { XStack, Text } from 'tamagui';

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
    <ScreenHeader
      title={t('title')}
      rightActions={[
        {
          icon: <Search size={22} color={theme.textSecondary} />,
          onPress: onSearchPress ?? (() => {}),
        },
      ]}
    />
  );
}
