import { useCallback } from 'react';
import { Canvas, Path, Skia } from '@shopify/react-native-skia';
import { useColorScheme } from 'react-native';
import { colors } from '@/src/constants/theme';

type TimerRingProps = {
  // 进度 0~1（番茄钟：elapsed/total，自由：始终为 0 脉冲态）
  progress: number;
  size?: number;
  strokeWidth?: number;
};

// Skia 圆环进度组件
export function TimerRing({ progress, size = 260, strokeWidth = 8 }: TimerRingProps) {
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  const center = size / 2;
  const radius = center - strokeWidth;

  // 背景圆环路径
  const bgPath = useCallback(() => {
    const path = Skia.Path.Make();
    path.addCircle(center, center, radius);
    return path;
  }, [center, radius]);

  // 进度弧路径（从顶部 -90° 开始顺时针）
  const progressPath = useCallback(() => {
    const path = Skia.Path.Make();
    const sweepAngle = progress * 360;
    const oval = Skia.XYWHRect(
      center - radius,
      center - radius,
      radius * 2,
      radius * 2,
    );
    path.addArc(oval, -90, sweepAngle);
    return path;
  }, [center, radius, progress]);

  return (
    <Canvas style={{ width: size, height: size }}>
      {/* 背景圆环 */}
      <Path
        path={bgPath()}
        style="stroke"
        strokeWidth={strokeWidth}
        color={theme.border}
        strokeCap="round"
      />
      {/* 进度弧 */}
      {progress > 0 && (
        <Path
          path={progressPath()}
          style="stroke"
          strokeWidth={strokeWidth}
          color={theme.accent}
          strokeCap="round"
        />
      )}
    </Canvas>
  );
}
