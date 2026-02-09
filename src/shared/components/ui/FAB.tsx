import type { ReactNode } from 'react';
import { StyleSheet } from 'react-native';
import { YStack } from 'tamagui';

type FABProps = {
  icon: ReactNode;
  onPress: () => void;
};

export function FAB({ icon, onPress }: FABProps) {
  return (
    <YStack
      position="absolute"
      bottom={24}
      right={24}
      width={56}
      height={56}
      borderRadius={28}
      backgroundColor="$color"
      alignItems="center"
      justifyContent="center"
      elevation={4}
      shadowColor="#000"
      shadowOffset={{ width: 0, height: 2 }}
      shadowOpacity={0.25}
      shadowRadius={4}
      onPress={onPress}
      pressStyle={{ scale: 0.95, opacity: 0.9 }}
    >
      {icon}
    </YStack>
  );
}
