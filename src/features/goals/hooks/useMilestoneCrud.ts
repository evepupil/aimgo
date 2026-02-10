import { useCallback } from 'react';
import { Q } from '@nozbe/watermelondb';
import { database } from '@/src/database';
import type Milestone from '@/src/database/models/Milestone';

type CreateMilestoneInput = {
  goalId: string;
  title: string;
  description?: string;
  deadline?: number | null;
};

type UpdateMilestoneInput = {
  title?: string;
  description?: string;
  deadline?: number | null;
};

// 里程碑 CRUD 操作
export function useMilestoneCrud() {
  // 创建里程碑
  const createMilestone = useCallback(async (input: CreateMilestoneInput) => {
    const collection = database.get<Milestone>('milestones');
    // 获取当前目标下最大排序值
    const existing = await collection
      .query(Q.where('goal_id', input.goalId))
      .fetch();
    const maxOrder = existing.reduce((max, m) => Math.max(max, m.sortOrder), 0);

    await database.write(async () => {
      await collection.create((milestone) => {
        milestone.goalId = input.goalId;
        milestone.title = input.title;
        milestone.description = input.description ?? '';
        milestone.deadline = input.deadline ?? null;
        milestone.sortOrder = maxOrder + 1;
      });
    });
  }, []);

  // 更新里程碑
  const updateMilestone = useCallback(async (milestoneId: string, input: UpdateMilestoneInput) => {
    const milestone = await database.get<Milestone>('milestones').find(milestoneId);
    await database.write(async () => {
      await milestone.update((m) => {
        if (input.title !== undefined) m.title = input.title;
        if (input.description !== undefined) m.description = input.description;
        if (input.deadline !== undefined) m.deadline = input.deadline;
      });
    });
  }, []);

  // 删除里程碑（级联删除关联的任务）
  const deleteMilestone = useCallback(async (milestoneId: string) => {
    const milestone = await database.get<Milestone>('milestones').find(milestoneId);
    await database.write(async () => {
      const tasks = await milestone.tasks.fetch();
      for (const task of tasks) {
        await task.markAsDeleted();
      }
      await milestone.markAsDeleted();
    });
  }, []);

  return { createMilestone, updateMilestone, deleteMilestone };
}
