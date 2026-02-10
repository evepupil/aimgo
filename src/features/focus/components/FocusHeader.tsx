import { useTranslation } from 'react-i18next';
import { History, Settings } from 'lucide-react-native';
import { useColorScheme } from 'react-native';

import { ScreenHeader } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';

type FocusHeaderProps = {
  onHistoryPress?: () => void;
  onSettingsPress?: () => void;
};

export function FocusHeader({ onHistoryPress, onSettingsPress }: FocusHeaderProps) {
  const { t } = useTranslation('focus');
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  return (
    <ScreenHeader
      title={t('title')}
      rightActions={[
        {
          icon: <History size={22} color={theme.textSecondary} />,
          onPress: onHistoryPress ?? (() => {}),
        },
        {
          icon: <Settings size={22} color={theme.textSecondary} />,
          onPress: onSettingsPress ?? (() => {}),
        },
      ]}
    />
  );
}
