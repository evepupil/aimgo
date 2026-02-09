import { useState, useCallback } from 'react';
import { XStack, YStack, Text } from 'tamagui';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';
import type { LayoutChangeEvent } from 'react-native';
import { ChevronDown } from 'lucide-react-native';
import { useColorScheme } from 'react-native';
import { useTranslation } from 'react-i18next';

import { Card } from '@/src/shared/components/ui';
import { ProgressBar } from '@/src/shared/components/ui';
import { formatDuration } from '@/src/shared/utils';
import { colors } from '@/src/constants/theme';
import type { MilestoneDisplay } from '../types';
import { useTasks } from '../hooks';
import { TaskItem } from './TaskItem';

type MilestoneCardProps = {
  milestone: MilestoneDisplay;
  isExpanded: boolean;
  onToggleExpand: () => void;
};

export function MilestoneCard({
  milestone,
  isExpanded,
  onToggleExpand,
}: MilestoneCardProps) {
  const { t } = useTranslation('goals');
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  const { tasks, toggleTask } = useTasks(isExpanded ? milestone.id : null);

  // 手风琴动画
  const [contentHeight, setContentHeight] = useState(0);
  const animatedHeight = useSharedValue(0);
  const animatedOpacity = useSharedValue(0);
  const animatedRotation = useSharedValue(0);

  const onContentLayout = useCallback(
    (event: LayoutChangeEvent) => {
      const height = event.nativeEvent.layout.height;
      if (height > 0 && height !== contentHeight) {
        setContentHeight(height);
      }
    },
    [contentHeight],
  );

  // 同步展开/收起状态到动画值
  if (isExpanded && contentHeight > 0) {
    animatedHeight.value = withTiming(contentHeight, { duration: 250 });
    animatedOpacity.value = withTiming(1, { duration: 250 });
    animatedRotation.value = withTiming(180, { duration: 250 });
  } else if (!isExpanded) {
    animatedHeight.value = withTiming(0, { duration: 200 });
    animatedOpacity.value = withTiming(0, { duration: 150 });
    animatedRotation.value = withTiming(0, { duration: 250 });
  }

  const collapsibleStyle = useAnimatedStyle(() => ({
    height: animatedHeight.value,
    opacity: animatedOpacity.value,
    overflow: 'hidden' as const,
  }));

  const chevronStyle = useAnimatedStyle(() => ({
    transform: [{ rotate: `${animatedRotation.value}deg` }],
  }));

  return (
    <Card marginBottom="$3" padding={0} overflow="hidden">
      {/* 可点击的头部区域 */}
      <YStack
        padding="$4"
        onPress={onToggleExpand}
        pressStyle={{ opacity: 0.8 }}
      >
        {/* 标题行 */}
        <XStack alignItems="center" justifyContent="space-between">
          <Text fontSize="$5" fontWeight="600" flex={1} numberOfLines={1}>
            {milestone.title}
          </Text>

          <XStack alignItems="center" gap="$2">
            <Text fontSize="$3" color="$placeholderColor">
              {t('taskCount', {
                completed: milestone.completedTaskCount,
                total: milestone.totalTaskCount,
              })}
            </Text>
            <Animated.View style={chevronStyle}>
              <ChevronDown size={18} color={theme.textMuted} />
            </Animated.View>
          </XStack>
        </XStack>

        {/* 进度条 */}
        <YStack marginTop="$3" gap="$1.5">
          <ProgressBar progress={milestone.progress} color={theme.accent} />
          <XStack justifyContent="space-between">
            <Text fontSize="$2" color="$placeholderColor">
              {formatDuration(milestone.effectiveTime)} /{' '}
              {formatDuration(milestone.estimatedTime)}
            </Text>
            {milestone.isCompleted && (
              <Text fontSize="$2" color={theme.success}>
                {t('completed')}
              </Text>
            )}
          </XStack>
        </YStack>
      </YStack>

      {/* 手风琴展开的任务列表 */}
      <Animated.View style={collapsibleStyle}>
        <YStack
          onLayout={onContentLayout}
          position={contentHeight === 0 ? 'absolute' : 'relative'}
          opacity={contentHeight === 0 ? 0 : 1}
          width="100%"
          borderTopWidth={1}
          borderTopColor="$borderColor"
        >
          {tasks.map((task, index) => (
            <TaskItem
              key={task.id}
              task={task}
              onToggle={toggleTask}
              isLast={index === tasks.length - 1}
            />
          ))}
        </YStack>
      </Animated.View>
    </Card>
  );
}
