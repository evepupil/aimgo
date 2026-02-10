import { FlatList, type ListRenderItemInfo } from 'react-native';
import { YStack } from 'tamagui';
import { useTranslation } from 'react-i18next';
import { Target } from 'lucide-react-native';
import { useColorScheme } from 'react-native';

import { EmptyState } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';
import type { MilestoneDisplay, TaskDisplay } from '../types';
import { useGoalStore } from '../store';
import { MilestoneCard } from './MilestoneCard';

type MilestoneListProps = {
  milestones: MilestoneDisplay[];
  onEditMilestone?: (milestone: MilestoneDisplay) => void;
  onDeleteMilestone?: (milestoneId: string) => void;
  onAddTask?: (milestoneId: string) => void;
  onEditTask?: (task: TaskDisplay) => void;
  onDeleteTask?: (taskId: string) => void;
};

export function MilestoneList({
  milestones,
  onEditMilestone,
  onDeleteMilestone,
  onAddTask,
  onEditTask,
  onDeleteTask,
}: MilestoneListProps) {
  const { t } = useTranslation('goals');
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;
  const expandedMilestoneIds = useGoalStore((s) => s.expandedMilestoneIds);
  const toggleMilestone = useGoalStore((s) => s.toggleMilestone);

  const renderItem = ({ item }: ListRenderItemInfo<MilestoneDisplay>) => (
    <MilestoneCard
      milestone={item}
      isExpanded={expandedMilestoneIds.has(item.id)}
      onToggleExpand={() => toggleMilestone(item.id)}
      onEditMilestone={onEditMilestone}
      onDeleteMilestone={onDeleteMilestone}
      onAddTask={onAddTask}
      onEditTask={onEditTask}
      onDeleteTask={onDeleteTask}
    />
  );

  if (milestones.length === 0) {
    return (
      <EmptyState
        icon={<Target size={48} color={theme.textMuted} />}
        message={t('noMilestones')}
      />
    );
  }

  return (
    <FlatList
      data={milestones}
      keyExtractor={(item) => item.id}
      renderItem={renderItem}
      contentContainerStyle={{ padding: 16, paddingBottom: 96 }}
      showsVerticalScrollIndicator={false}
    />
  );
}
