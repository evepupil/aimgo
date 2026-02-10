import { useEffect, useRef } from 'react';
import { YStack } from 'tamagui';
import { Plus } from 'lucide-react-native';

import { FAB } from '@/src/shared/components/ui';
import { GoalsHeader, GoalSwitcher, MilestoneList } from '@/src/features/goals/components';
import type { GoalSwitcherRef } from '@/src/features/goals/components';
import { useGoals, useGoal, useGoalsWithProgress, useMilestones } from '@/src/features/goals/hooks';
import { useGoalStore } from '@/src/features/goals/store';

export default function GoalsScreen() {
  const goals = useGoals();
  const { goals: goalsWithProgress } = useGoalsWithProgress();
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

  const switcherRef = useRef<GoalSwitcherRef>(null);

  return (
    <YStack flex={1} backgroundColor="$background">
      <GoalsHeader
        currentGoalTitle={currentGoal?.title ?? null}
        onGoalPress={() => switcherRef.current?.open()}
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

      {/* 目标切换抽屉 */}
      <GoalSwitcher
        ref={switcherRef}
        goals={goalsWithProgress}
        currentGoalId={currentGoalId}
        onSelect={setCurrentGoalId}
        onAddGoal={() => {
          // Phase 3.3：创建目标表单
        }}
        onEditGoal={(_goalId) => {
          // Phase 3.3：编辑目标
        }}
        onDeleteGoal={(_goalId) => {
          // Phase 3.3：删除目标
        }}
      />
    </YStack>
  );
}
