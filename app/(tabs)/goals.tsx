import { useEffect } from 'react';
import { YStack } from 'tamagui';
import { Plus } from 'lucide-react-native';

import { FAB } from '@/src/shared/components/ui';
import { GoalsHeader, MilestoneList } from '@/src/features/goals/components';
import { useGoals, useGoal, useMilestones } from '@/src/features/goals/hooks';
import { useGoalStore } from '@/src/features/goals/store';

export default function GoalsScreen() {
  const goals = useGoals();
  const currentGoalId = useGoalStore((s) => s.currentGoalId);
  const setCurrentGoalId = useGoalStore((s) => s.setCurrentGoalId);

  // 自动选中第一个目标
  useEffect(() => {
    if (!currentGoalId && goals.length > 0) {
      setCurrentGoalId(goals[0].id);
    }
  }, [currentGoalId, goals, setCurrentGoalId]);

  const currentGoal = useGoal(currentGoalId);
  const { milestones } = useMilestones(currentGoalId);

  return (
    <YStack flex={1} backgroundColor="$background">
      <GoalsHeader
        currentGoalTitle={currentGoal?.title ?? null}
        onGoalPress={() => {
          // Phase 3.2：目标切换抽屉
        }}
        onSearchPress={() => {
          // Phase 3.4：搜索功能
        }}
      />

      <MilestoneList milestones={milestones} />

      <FAB
        icon={<Plus size={24} color="#FFF" />}
        onPress={() => {
          // Phase 3.3：添加目标/里程碑/任务
        }}
      />
    </YStack>
  );
}
