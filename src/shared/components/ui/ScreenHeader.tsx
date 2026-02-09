import { type ReactNode } from 'react';
import { XStack, YStack, Text } from 'tamagui';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

type HeaderAction = {
  icon: ReactNode;
  onPress: () => void;
};

type ScreenHeaderProps = {
  title: string;
  leftActions?: HeaderAction[];
  rightActions?: HeaderAction[];
};

export function ScreenHeader({ title, leftActions, rightActions }: ScreenHeaderProps) {
  const insets = useSafeAreaInsets();

  return (
    <YStack paddingTop={insets.top} backgroundColor="$background">
      <XStack
        height={56}
        alignItems="center"
        paddingHorizontal="$4"
        justifyContent="space-between"
      >
        <XStack alignItems="center" gap="$2">
          {leftActions?.map((action, i) => (
            <YStack key={i} onPress={action.onPress} padding="$2">
              {action.icon}
            </YStack>
          ))}
        </XStack>

        <Text fontSize="$6" fontWeight="bold" flex={1} paddingHorizontal="$2">
          {title}
        </Text>

        <XStack alignItems="center" gap="$2">
          {rightActions?.map((action, i) => (
            <YStack key={i} onPress={action.onPress} padding="$2">
              {action.icon}
            </YStack>
          ))}
        </XStack>
      </XStack>
    </YStack>
  );
}
