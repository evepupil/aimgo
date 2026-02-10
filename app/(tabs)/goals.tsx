import { useEffect, useRef, useState, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { YStack } from 'tamagui';
import { Plus } from 'lucide-react-native';

import { database } from '@/src/database';
import type Goal from '@/src/database/models/Goal';
import type Milestone from '@/src/database/models/Milestone';
import { FAB, SearchHeader, DeleteConfirmDialog } from '@/src/shared/components/ui';
import {
  GoalsHeader,
  GoalSwitcher,
  MilestoneList,
  GoalFormSheet,
  MilestoneFormSheet,
  TaskFormSheet,
  SearchResults,
} from '@/src/features/goals/components';
import type {
  GoalSwitcherRef,
  GoalFormSheetRef,
  MilestoneFormSheetRef,
  TaskFormSheetRef,
} from '@/src/features/goals/components';
import {
  useGoals,
  useGoal,
  useGoalsWithProgress,
  useMilestones,
  useGoalCrud,
  useMilestoneCrud,
  useTaskCrud,
  useSearch,
} from '@/src/features/goals/hooks';
import { useGoalStore } from '@/src/features/goals/store';
import type { MilestoneDisplay, TaskDisplay } from '@/src/features/goals/types';

export default function GoalsScreen() {
  const { t } = useTranslation('goals');
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

  // CRUD hooks
  const { createGoal, updateGoal, deleteGoal } = useGoalCrud();
  const { createMilestone, updateMilestone, deleteMilestone } = useMilestoneCrud();
  const { createTask, updateTask, deleteTask } = useTaskCrud();

  // 搜索状态
  const [isSearchMode, setIsSearchMode] = useState(false);
  const [searchKeyword, setSearchKeyword] = useState('');
  const { results: searchResults, isSearching } = useSearch(isSearchMode ? searchKeyword : '');

  // 删除确认弹窗状态
  const [deleteDialog, setDeleteDialog] = useState<{
    visible: boolean;
    title: string;
    message: string;
    onConfirm: () => void;
  }>({ visible: false, title: '', message: '', onConfirm: () => {} });

  // 里程碑创建时需要的 goalId（当前选中的目标）
  const [activeMilestoneGoalId, setActiveMilestoneGoalId] = useState<string | null>(null);
  // 任务创建时需要的 milestoneId
  const [activeTaskMilestoneId, setActiveTaskMilestoneId] = useState<string | null>(null);

  // Refs
  const switcherRef = useRef<GoalSwitcherRef>(null);
  const goalFormRef = useRef<GoalFormSheetRef>(null);
  const milestoneFormRef = useRef<MilestoneFormSheetRef>(null);
  const taskFormRef = useRef<TaskFormSheetRef>(null);

  // === 目标 CRUD 回调 ===
  const handleGoalSubmit = useCallback(
    async (data: { title: string; description: string; color: string; deadline: number | null }, goalId?: string) => {
      if (goalId) {
        await updateGoal(goalId, data);
      } else {
        await createGoal(data);
      }
    },
    [createGoal, updateGoal],
  );

  const handleAddGoal = useCallback(() => {
    switcherRef.current?.close();
    // 延迟打开表单，等 GoalSwitcher 关闭动画完成
    setTimeout(() => goalFormRef.current?.openCreate(), 300);
  }, []);

  const handleEditGoal = useCallback(
    async (goalId: string) => {
      const goal = goalsWithProgress.find((g) => g.id === goalId);
      if (!goal) return;
      // 从数据库获取完整数据（description, deadline）
      const fullGoal = await database.get<Goal>('goals').find(goalId);
      switcherRef.current?.close();
      setTimeout(() => {
        goalFormRef.current?.openEdit({
          id: goal.id,
          title: goal.title,
          description: fullGoal.description,
          color: goal.color,
          deadline: fullGoal.deadline,
        });
      }, 300);
    },
    [goalsWithProgress],
  );

  const handleDeleteGoal = useCallback(
    (goalId: string) => {
      const goal = goalsWithProgress.find((g) => g.id === goalId);
      setDeleteDialog({
        visible: true,
        title: t('deleteGoalTitle'),
        message: t('deleteGoalMessage', { title: goal?.title ?? '' }),
        onConfirm: async () => {
          await deleteGoal(goalId);
          setDeleteDialog((prev) => ({ ...prev, visible: false }));
          // 如果删除的是当前选中的目标，切换到第一个
          if (goalId === currentGoalId) {
            const remaining = goals.filter((g) => g.id !== goalId);
            setCurrentGoalId(remaining.length > 0 ? remaining[0].id : null);
          }
        },
      });
    },
    [t, goalsWithProgress, deleteGoal, currentGoalId, goals, setCurrentGoalId],
  );

  // === 里程碑 CRUD 回调 ===
  const handleMilestoneSubmit = useCallback(
    async (data: { title: string; description: string; deadline: number | null }, milestoneId?: string) => {
      if (milestoneId) {
        await updateMilestone(milestoneId, data);
      } else if (activeMilestoneGoalId) {
        await createMilestone({ goalId: activeMilestoneGoalId, ...data });
      }
    },
    [createMilestone, updateMilestone, activeMilestoneGoalId],
  );

  const handleAddMilestone = useCallback(() => {
    if (!currentGoalId) return;
    setActiveMilestoneGoalId(currentGoalId);
    milestoneFormRef.current?.openCreate();
  }, [currentGoalId]);

  const handleEditMilestone = useCallback(async (milestone: MilestoneDisplay) => {
    // 从数据库获取完整数据（description, deadline）
    const fullMilestone = await database.get<Milestone>('milestones').find(milestone.id);
    milestoneFormRef.current?.openEdit({
      id: milestone.id,
      title: milestone.title,
      description: fullMilestone.description,
      deadline: fullMilestone.deadline,
    });
  }, []);

  const handleDeleteMilestone = useCallback(
    (milestoneId: string) => {
      const milestone = milestones.find((m) => m.id === milestoneId);
      setDeleteDialog({
        visible: true,
        title: t('deleteMilestoneTitle'),
        message: t('deleteMilestoneMessage', { title: milestone?.title ?? '' }),
        onConfirm: async () => {
          await deleteMilestone(milestoneId);
          setDeleteDialog((prev) => ({ ...prev, visible: false }));
        },
      });
    },
    [t, milestones, deleteMilestone],
  );

  // === 任务 CRUD 回调 ===
  const handleTaskSubmit = useCallback(
    async (data: { title: string; estimatedTime: number }, taskId?: string) => {
      if (taskId) {
        await updateTask(taskId, data);
      } else if (activeTaskMilestoneId) {
        await createTask({ milestoneId: activeTaskMilestoneId, ...data });
      }
    },
    [createTask, updateTask, activeTaskMilestoneId],
  );

  const handleAddTask = useCallback((milestoneId: string) => {
    setActiveTaskMilestoneId(milestoneId);
    taskFormRef.current?.openCreate();
  }, []);

  const handleEditTask = useCallback((task: TaskDisplay) => {
    taskFormRef.current?.openEdit({
      id: task.id,
      title: task.title,
      estimatedTime: task.estimatedTime,
    });
  }, []);

  const handleDeleteTask = useCallback(
    (taskId: string) => {
      setDeleteDialog({
        visible: true,
        title: t('deleteTaskTitle'),
        message: t('deleteTaskMessage'),
        onConfirm: async () => {
          await deleteTask(taskId);
          setDeleteDialog((prev) => ({ ...prev, visible: false }));
        },
      });
    },
    [t, deleteTask],
  );

  // === 搜索回调 ===
  const handleSearchGoal = useCallback(
    (goalId: string) => {
      setCurrentGoalId(goalId);
      setIsSearchMode(false);
      setSearchKeyword('');
    },
    [setCurrentGoalId],
  );

  const handleSearchMilestone = useCallback(
    (milestoneId: string) => {
      // 找到该里程碑所属目标，切换过去
      const result = searchResults.find((r) => r.id === milestoneId && r.type === 'milestone');
      if (result?.goalId) {
        setCurrentGoalId(result.goalId);
      }
      setIsSearchMode(false);
      setSearchKeyword('');
    },
    [searchResults, setCurrentGoalId],
  );

  const handleSearchTask = useCallback(
    (taskId: string) => {
      const result = searchResults.find((r) => r.id === taskId && r.type === 'task');
      if (result?.goalId) {
        setCurrentGoalId(result.goalId);
      }
      setIsSearchMode(false);
      setSearchKeyword('');
    },
    [searchResults, setCurrentGoalId],
  );

  return (
    <YStack flex={1} backgroundColor="$background">
      {/* 搜索模式切换 */}
      {isSearchMode ? (
        <SearchHeader
          value={searchKeyword}
          onChangeText={setSearchKeyword}
          onClose={() => {
            setIsSearchMode(false);
            setSearchKeyword('');
          }}
          placeholder={t('searchPlaceholder')}
        />
      ) : (
        <GoalsHeader
          currentGoalTitle={currentGoal?.title ?? null}
          onGoalPress={() => switcherRef.current?.open()}
          onSearchPress={() => setIsSearchMode(true)}
        />
      )}

      {/* 搜索结果 / 里程碑列表 */}
      {isSearchMode ? (
        <SearchResults
          results={searchResults}
          keyword={searchKeyword}
          isSearching={isSearching}
          onGoalPress={handleSearchGoal}
          onMilestonePress={handleSearchMilestone}
          onTaskPress={handleSearchTask}
        />
      ) : (
        <>
          <MilestoneList
            milestones={milestones}
            onEditMilestone={handleEditMilestone}
            onDeleteMilestone={handleDeleteMilestone}
            onAddTask={handleAddTask}
            onEditTask={handleEditTask}
            onDeleteTask={handleDeleteTask}
          />

          <FAB
            icon={<Plus size={24} color="#FFF" />}
            onPress={handleAddMilestone}
          />
        </>
      )}

      {/* 目标切换抽屉 */}
      <GoalSwitcher
        ref={switcherRef}
        goals={goalsWithProgress}
        currentGoalId={currentGoalId}
        onSelect={setCurrentGoalId}
        onAddGoal={handleAddGoal}
        onEditGoal={handleEditGoal}
        onDeleteGoal={handleDeleteGoal}
      />

      {/* 表单 BottomSheets */}
      <GoalFormSheet ref={goalFormRef} onSubmit={handleGoalSubmit} />
      <MilestoneFormSheet ref={milestoneFormRef} onSubmit={handleMilestoneSubmit} />
      <TaskFormSheet ref={taskFormRef} onSubmit={handleTaskSubmit} />

      {/* 删除确认弹窗 */}
      <DeleteConfirmDialog
        visible={deleteDialog.visible}
        title={deleteDialog.title}
        message={deleteDialog.message}
        onConfirm={deleteDialog.onConfirm}
        onCancel={() => setDeleteDialog((prev) => ({ ...prev, visible: false }))}
      />
    </YStack>
  );
}
