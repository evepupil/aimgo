import { useState, useEffect } from 'react';
import { Q } from '@nozbe/watermelondb';
import type { Query } from '@nozbe/watermelondb';
import { database } from '@/src/database';
import type Milestone from '@/src/database/models/Milestone';
import type Task from '@/src/database/models/Task';
import type { MilestoneDisplay } from '../types';
import {
  getMilestoneEffectiveTime,
  getMilestoneEstimatedTime,
  getMilestoneProgress,
  isMilestoneCompleted,
} from '@/src/database/helpers';

// 获取指定目标下的里程碑展示数据
export function useMilestones(goalId: string | null) {
  const [milestones, setMilestones] = useState<MilestoneDisplay[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!goalId) {
      setMilestones([]);
      return;
    }

    setLoading(true);

    const subscription = database
      .get<Milestone>('milestones')
      .query(Q.where('goal_id', goalId), Q.sortBy('sort_order', Q.asc))
      .observe()
      .subscribe(async (rawMilestones) => {
        const displays = await Promise.all(
          rawMilestones.map(async (ms) => {
            const tasks: Task[] = await (ms.tasks as Query<Task>).fetch();
            const completedCount = tasks.filter((t) => t.isCompleted).length;
            const effectiveTime = await getMilestoneEffectiveTime(ms);
            const estimatedTime = await getMilestoneEstimatedTime(ms);
            const progress = await getMilestoneProgress(ms);
            const completed = await isMilestoneCompleted(ms);

            return {
              id: ms.id,
              title: ms.title,
              completedTaskCount: completedCount,
              totalTaskCount: tasks.length,
              effectiveTime,
              estimatedTime,
              progress,
              isCompleted: completed,
            } satisfies MilestoneDisplay;
          }),
        );

        setMilestones(displays);
        setLoading(false);
      });

    return () => subscription.unsubscribe();
  }, [goalId]);

  return { milestones, loading };
}
