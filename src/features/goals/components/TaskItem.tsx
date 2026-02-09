import { XStack, Text, Separator } from 'tamagui';
import { useColorScheme } from 'react-native';
import type { TaskDisplay } from '../types';
import { TaskProgressCircle } from './TaskProgressCircle';
import { formatDuration } from '@/src/shared/utils';
import { colors } from '@/src/constants/theme';

type TaskItemProps = {
  task: TaskDisplay;
  onToggle: (taskId: string) => void;
  isLast?: boolean;
};

export function TaskItem({ task, onToggle, isLast }: TaskItemProps) {
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  return (
    <>
      <XStack
        alignItems="center"
        paddingVertical="$2.5"
        paddingHorizontal="$3"
        gap="$3"
      >
        <TaskProgressCircle
          progress={task.progress}
          isCompleted={task.isCompleted}
          onPress={() => onToggle(task.id)}
        />

        <Text
          flex={1}
          fontSize="$3"
          color={task.isCompleted ? '$placeholderColor' : '$color'}
          textDecorationLine={task.isCompleted ? 'line-through' : 'none'}
          numberOfLines={1}
        >
          {task.title}
        </Text>

        {task.estimatedTime > 0 && (
          <Text fontSize="$2" color="$placeholderColor">
            {formatDuration(task.effectiveTime)} / {formatDuration(task.estimatedTime)}
          </Text>
        )}
      </XStack>

      {!isLast && <Separator borderColor="$borderColor" marginLeft="$8" />}
    </>
  );
}
