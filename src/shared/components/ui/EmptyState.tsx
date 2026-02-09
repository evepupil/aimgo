import type { ReactNode } from 'react';
import { YStack, Text } from 'tamagui';

type EmptyStateProps = {
  icon?: ReactNode;
  message: string;
};

export function EmptyState({ icon, message }: EmptyStateProps) {
  return (
    <YStack flex={1} alignItems="center" justifyContent="center" padding="$6" gap="$3">
      {icon}
      <Text color="$placeholderColor" fontSize="$4" textAlign="center">
        {message}
      </Text>
    </YStack>
  );
}
