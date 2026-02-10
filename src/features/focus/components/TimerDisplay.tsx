import { Text, YStack } from 'tamagui';

type TimerDisplayProps = {
  // 要显示的秒数
  seconds: number;
  // 标签文字（如 "剩余" / "已专注"）
  label?: string;
};

// 格式化秒数为 MM:SS
function formatTime(totalSeconds: number): string {
  const h = Math.floor(totalSeconds / 3600);
  const m = Math.floor((totalSeconds % 3600) / 60);
  const s = totalSeconds % 60;

  const mm = String(m).padStart(2, '0');
  const ss = String(s).padStart(2, '0');

  if (h > 0) {
    return `${h}:${mm}:${ss}`;
  }
  return `${mm}:${ss}`;
}

// 计时器时间展示
export function TimerDisplay({ seconds, label }: TimerDisplayProps) {
  return (
    <YStack alignItems="center" gap="$1">
      <Text
        fontSize={56}
        fontWeight="200"
        fontFamily="$mono"
        color="$color"
        letterSpacing={2}
      >
        {formatTime(seconds)}
      </Text>
      {label && (
        <Text fontSize="$3" color="$placeholderColor">
          {label}
        </Text>
      )}
    </YStack>
  );
}
