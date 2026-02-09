import { XStack, YStack, Input } from 'tamagui';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Search, X } from 'lucide-react-native';
import { useColorScheme } from 'react-native';

import { colors } from '@/src/constants/theme';

type SearchHeaderProps = {
  value: string;
  onChangeText: (text: string) => void;
  onClose: () => void;
  placeholder?: string;
};

export function SearchHeader({ value, onChangeText, onClose, placeholder }: SearchHeaderProps) {
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  return (
    <YStack paddingTop={insets.top} backgroundColor="$background">
      <XStack height={56} alignItems="center" paddingHorizontal="$4" gap="$3">
        <Search size={20} color={theme.textMuted} />

        <Input
          flex={1}
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          autoFocus
          borderWidth={0}
          backgroundColor="transparent"
          placeholderTextColor="$placeholderColor"
          fontSize="$4"
          padding={0}
        />

        <YStack onPress={onClose} padding="$2">
          <X size={20} color={theme.textSecondary} />
        </YStack>
      </XStack>
    </YStack>
  );
}
