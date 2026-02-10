import { useCallback } from 'react';
import { Q } from '@nozbe/watermelondb';
import { database } from '@/src/database';
import type Task from '@/src/database/models/Task';

type CreateTaskInput = {
  milestoneId: string;
  title: string;
  estimatedTime?: number; // 秒为单位
};

type UpdateTaskInput = {
  title?: string;
  estimatedTime?: number;
};

// 任务 CRUD 操作
export function useTaskCrud() {
  // 创建任务
  const createTask = useCallback(async (input: CreateTaskInput) => {
    const collection = database.get<Task>('tasks');
    // 获取当前里程碑下最大排序值
    const existing = await collection
      .query(Q.where('milestone_id', input.milestoneId))
      .fetch();
    const maxOrder = existing.reduce((max, t) => Math.max(max, t.sortOrder), 0);

    await database.write(async () => {
      await collection.create((task) => {
        task.milestoneId = input.milestoneId;
        task.title = input.title;
        task.isCompleted = false;
        task.estimatedTime = input.estimatedTime ?? 0;
        task.sortOrder = maxOrder + 1;
      });
    });
  }, []);

  // 更新任务
  const updateTask = useCallback(async (taskId: string, input: UpdateTaskInput) => {
    const task = await database.get<Task>('tasks').find(taskId);
    await database.write(async () => {
      await task.update((t) => {
        if (input.title !== undefined) t.title = input.title;
        if (input.estimatedTime !== undefined) t.estimatedTime = input.estimatedTime;
      });
    });
  }, []);

  // 删除任务
  const deleteTask = useCallback(async (taskId: string) => {
    const task = await database.get<Task>('tasks').find(taskId);
    await database.write(async () => {
      await task.markAsDeleted();
    });
  }, []);

  return { createTask, updateTask, deleteTask };
}
