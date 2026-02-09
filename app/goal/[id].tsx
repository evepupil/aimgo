import { YStack, Text } from 'tamagui';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalSearchParams } from 'expo-router';

export default function GoalDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <YStack flex={1} padding="$4">
        <Text fontSize="$8" fontWeight="bold">
          目标详情
        </Text>
        <Text color="$colorHover">{id}</Text>
      </YStack>
    </SafeAreaView>
  );
}
