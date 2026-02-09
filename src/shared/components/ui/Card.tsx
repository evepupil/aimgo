import type { ReactNode } from 'react';
import { YStack, type YStackProps } from 'tamagui';

type CardProps = YStackProps & {
  children: ReactNode;
};

export function Card({ children, ...props }: CardProps) {
  return (
    <YStack
      backgroundColor="$backgroundHover"
      borderRadius="$4"
      padding="$4"
      borderWidth={1}
      borderColor="$borderColor"
      {...props}
    >
      {children}
    </YStack>
  );
}
