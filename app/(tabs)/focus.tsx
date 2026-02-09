import { YStack, Text } from 'tamagui';
import { SafeAreaView } from 'react-native-safe-area-context';

export default function FocusScreen() {
  return (
    <SafeAreaView style={{ flex: 1 }}>
      <YStack flex={1} padding="$4">
        <Text fontSize="$8" fontWeight="bold">
          专注
        </Text>
      </YStack>
    </SafeAreaView>
  );
}
