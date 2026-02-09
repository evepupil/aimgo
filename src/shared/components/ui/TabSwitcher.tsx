import { useState } from 'react';
import { XStack, Text } from 'tamagui';
import Animated, { useAnimatedStyle, withTiming } from 'react-native-reanimated';

type Tab = {
  key: string;
  label: string;
};

type TabSwitcherProps = {
  tabs: Tab[];
  activeKey: string;
  onTabChange: (key: string) => void;
};

export function TabSwitcher({ tabs, activeKey, onTabChange }: TabSwitcherProps) {
  return (
    <XStack
      backgroundColor="$backgroundPress"
      borderRadius="$3"
      padding="$1"
    >
      {tabs.map((tab) => {
        const isActive = tab.key === activeKey;
        return (
          <XStack
            key={tab.key}
            flex={1}
            height={36}
            alignItems="center"
            justifyContent="center"
            borderRadius="$2"
            backgroundColor={isActive ? '$background' : 'transparent'}
            onPress={() => onTabChange(tab.key)}
            pressStyle={{ opacity: 0.7 }}
          >
            <Text
              fontSize="$3"
              fontWeight={isActive ? 'bold' : 'normal'}
              color={isActive ? '$color' : '$placeholderColor'}
            >
              {tab.label}
            </Text>
          </XStack>
        );
      })}
    </XStack>
  );
}
