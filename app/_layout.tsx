import { useColorScheme } from 'react-native';
import { TamaguiProvider, Theme } from 'tamagui';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { DatabaseProvider } from '@nozbe/watermelondb/react';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import 'react-native-reanimated';
import '@/src/i18n';

import tamaguiConfig from '../tamagui.config';
import { database } from '@/src/database';

const queryClient = new QueryClient();

export const unstable_settings = {
  anchor: '(tabs)',
};

export default function RootLayout() {
  const colorScheme = useColorScheme();

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <TamaguiProvider config={tamaguiConfig} defaultTheme={colorScheme ?? 'dark'}>
        <Theme name={colorScheme ?? 'dark'}>
          <DatabaseProvider database={database}>
            <QueryClientProvider client={queryClient}>
              <Stack>
                <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
                <Stack.Screen name="goal/[id]" options={{ headerShown: false }} />
              </Stack>
              <StatusBar style="auto" />
            </QueryClientProvider>
          </DatabaseProvider>
        </Theme>
      </TamaguiProvider>
    </GestureHandlerRootView>
  );
}
