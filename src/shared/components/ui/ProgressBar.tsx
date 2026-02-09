import { View, StyleSheet } from 'react-native';
import Animated, {
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated';

type ProgressBarProps = {
  /** 进度值，0~N（可超过 1） */
  progress: number;
  /** 进度条高度 */
  height?: number;
  /** 正常色 */
  color?: string;
  /** 超时色（进度 > 1 时渐变到此色） */
  overflowColor?: string;
  /** 背景色 */
  trackColor?: string;
};

export function ProgressBar({
  progress,
  height = 6,
  color = '#6366F1',
  overflowColor = '#F97316',
  trackColor = '#2A2A2A',
}: ProgressBarProps) {
  // 进度条宽度上限 100%
  const clampedWidth = Math.min(progress, 1);
  // 超出部分单独渲染
  const overflowWidth = progress > 1 ? Math.min(progress - 1, 1) : 0;

  const barStyle = useAnimatedStyle(() => ({
    width: `${withTiming(clampedWidth * 100, { duration: 300 })}%` as unknown as number,
  }));

  const overflowStyle = useAnimatedStyle(() => ({
    width: `${withTiming(overflowWidth * 100, { duration: 300 })}%` as unknown as number,
  }));

  return (
    <View style={[styles.track, { height, backgroundColor: trackColor, borderRadius: height / 2 }]}>
      <Animated.View
        style={[
          styles.bar,
          { backgroundColor: color, borderRadius: height / 2 },
          barStyle,
        ]}
      />
      {progress > 1 && (
        <Animated.View
          style={[
            styles.overflow,
            { backgroundColor: overflowColor, borderRadius: height / 2, left: '100%' },
            overflowStyle,
          ]}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  track: {
    width: '100%',
    overflow: 'hidden',
    position: 'relative',
  },
  bar: {
    height: '100%',
    position: 'absolute',
    left: 0,
    top: 0,
  },
  overflow: {
    height: '100%',
    position: 'absolute',
    top: 0,
  },
});
