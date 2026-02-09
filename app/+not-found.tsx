import { Stack } from 'expo-router';
import { YStack, Text } from 'tamagui';
import { SafeAreaView } from 'react-native-safe-area-context';

export default function NotFoundScreen() {
  return (
    <>
      <Stack.Screen options={{ title: '404' }} />
      <SafeAreaView style={{ flex: 1 }}>
        <YStack flex={1} alignItems="center" justifyContent="center" padding="$4">
          <Text fontSize="$8" fontWeight="bold">
            页面不存在
          </Text>
        </YStack>
      </SafeAreaView>
    </>
  );
}
