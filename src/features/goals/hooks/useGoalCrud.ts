import { useCallback } from 'react';
import { database } from '@/src/database';
import type Goal from '@/src/database/models/Goal';

type CreateGoalInput = {
  title: string;
  description?: string;
  color?: string;
  deadline?: number | null;
};

type UpdateGoalInput = {
  title?: string;
  description?: string;
  color?: string;
  deadline?: number | null;
  status?: string;
};

// 目标 CRUD 操作
export function useGoalCrud() {
  // 创建目标
  const createGoal = useCallback(async (input: CreateGoalInput) => {
    const goalsCollection = database.get<Goal>('goals');
    // 获取当前最大排序值
    const allGoals = await goalsCollection.query().fetch();
    const maxOrder = allGoals.reduce((max, g) => Math.max(max, g.sortOrder), 0);

    await database.write(async () => {
      await goalsCollection.create((goal) => {
        goal.title = input.title;
        goal.description = input.description ?? '';
        goal.color = input.color ?? '#6366F1';
        goal.deadline = input.deadline ?? null;
        goal.status = 'active';
        goal.sortOrder = maxOrder + 1;
      });
    });
  }, []);

  // 更新目标
  const updateGoal = useCallback(async (goalId: string, input: UpdateGoalInput) => {
    const goal = await database.get<Goal>('goals').find(goalId);
    await database.write(async () => {
      await goal.update((g) => {
        if (input.title !== undefined) g.title = input.title;
        if (input.description !== undefined) g.description = input.description;
        if (input.color !== undefined) g.color = input.color;
        if (input.deadline !== undefined) g.deadline = input.deadline;
        if (input.status !== undefined) g.status = input.status;
      });
    });
  }, []);

  // 删除目标（级联删除关联的里程碑和任务）
  const deleteGoal = useCallback(async (goalId: string) => {
    const goal = await database.get<Goal>('goals').find(goalId);
    await database.write(async () => {
      const milestones = await goal.milestones.fetch();
      for (const milestone of milestones) {
        const tasks = await milestone.tasks.fetch();
        for (const task of tasks) {
          await task.markAsDeleted();
        }
        await milestone.markAsDeleted();
      }
      await goal.markAsDeleted();
    });
  }, []);

  return { createGoal, updateGoal, deleteGoal };
}
