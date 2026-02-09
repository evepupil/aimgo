import Svg, { Circle } from 'react-native-svg';
import { CheckCircle2 } from 'lucide-react-native';
import { useColorScheme } from 'react-native';
import { colors } from '@/src/constants/theme';

type TaskProgressCircleProps = {
  progress: number; // 0~N
  isCompleted: boolean;
  size?: number;
  onPress?: () => void;
};

export function TaskProgressCircle({
  progress,
  isCompleted,
  size = 22,
  onPress,
}: TaskProgressCircleProps) {
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  if (isCompleted) {
    return <CheckCircle2 size={size} color={theme.success} onPress={onPress} />;
  }

  const strokeWidth = 2.5;
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const clampedProgress = Math.min(progress, 1);
  const strokeDashoffset = circumference * (1 - clampedProgress);

  return (
    <Svg
      width={size}
      height={size}
      onPress={onPress}
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
    >
      {/* 底圈 */}
      <Circle
        cx={size / 2}
        cy={size / 2}
        r={radius}
        stroke={theme.border}
        strokeWidth={strokeWidth}
        fill="none"
      />
      {/* 进度圈 */}
      {clampedProgress > 0 && (
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={theme.success}
          strokeWidth={strokeWidth}
          fill="none"
          strokeDasharray={`${circumference}`}
          strokeDashoffset={strokeDashoffset}
          strokeLinecap="round"
          rotation={-90}
          origin={`${size / 2}, ${size / 2}`}
        />
      )}
    </Svg>
  );
}
