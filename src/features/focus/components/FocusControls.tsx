import { useTranslation } from 'react-i18next';
import { Play, Pause, Square } from 'lucide-react-native';
import { useColorScheme } from 'react-native';
import { XStack, YStack, Text } from 'tamagui';

import { colors } from '@/src/constants/theme';
import type { TimerStatus } from '../types';

type FocusControlsProps = {
  status: TimerStatus;
  onStart: () => void;
  onPause: () => void;
  onResume: () => void;
  onStop: () => void;
};

// 专注控制按钮组
export function FocusControls({
  status,
  onStart,
  onPause,
  onResume,
  onStop,
}: FocusControlsProps) {
  const { t } = useTranslation('focus');
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  // 空闲态：开始按钮
  if (status === 'idle') {
    return (
      <XStack justifyContent="center">
        <YStack
          width={72}
          height={72}
          borderRadius={36}
          backgroundColor={theme.accent}
          alignItems="center"
          justifyContent="center"
          onPress={onStart}
          pressStyle={{ opacity: 0.8 }}
        >
          <Play size={32} color="#FFF" fill="#FFF" />
        </YStack>
      </XStack>
    );
  }

  // 运行/暂停态：暂停/继续 + 终止
  return (
    <XStack justifyContent="center" gap="$6" alignItems="center">
      {/* 终止按钮 */}
      <YStack
        width={56}
        height={56}
        borderRadius={28}
        backgroundColor={theme.border}
        alignItems="center"
        justifyContent="center"
        onPress={onStop}
        pressStyle={{ opacity: 0.8 }}
      >
        <Square size={24} color={theme.textSecondary} fill={theme.textSecondary} />
      </YStack>

      {/* 暂停/继续按钮 */}
      <YStack
        width={72}
        height={72}
        borderRadius={36}
        backgroundColor={theme.accent}
        alignItems="center"
        justifyContent="center"
        onPress={status === 'running' ? onPause : onResume}
        pressStyle={{ opacity: 0.8 }}
      >
        {status === 'running' ? (
          <Pause size={32} color="#FFF" fill="#FFF" />
        ) : (
          <Play size={32} color="#FFF" fill="#FFF" />
        )}
      </YStack>
    </XStack>
  );
}
