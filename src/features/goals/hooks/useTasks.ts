import { useState, useEffect, useCallback } from 'react';
import { Q } from '@nozbe/watermelondb';
import { database } from '@/src/database';
import type Task from '@/src/database/models/Task';
import type { TaskDisplay } from '../types';
import { getTaskEffectiveTime, getTaskProgress } from '@/src/database/helpers';

// 获取指定里程碑下的任务展示数据
export function useTasks(milestoneId: string | null) {
  const [tasks, setTasks] = useState<TaskDisplay[]>([]);

  useEffect(() => {
    if (!milestoneId) {
      setTasks([]);
      return;
    }

    const subscription = database
      .get<Task>('tasks')
      .query(Q.where('milestone_id', milestoneId), Q.sortBy('sort_order', Q.asc))
      .observe()
      .subscribe(async (rawTasks) => {
        const displays = await Promise.all(
          rawTasks.map(async (t) => {
            const effectiveTime = await getTaskEffectiveTime(t);
            const progress = await getTaskProgress(t);

            return {
              id: t.id,
              title: t.title,
              isCompleted: t.isCompleted,
              effectiveTime,
              estimatedTime: t.estimatedTime,
              progress,
            } satisfies TaskDisplay;
          }),
        );

        setTasks(displays);
      });

    return () => subscription.unsubscribe();
  }, [milestoneId]);

  // 切换任务完成状态
  const toggleTask = useCallback(async (taskId: string) => {
    const task = await database.get<Task>('tasks').find(taskId);
    await database.write(async () => {
      await task.update((t) => {
        t.isCompleted = !t.isCompleted;
      });
    });
  }, []);

  return { tasks, toggleTask };
}
