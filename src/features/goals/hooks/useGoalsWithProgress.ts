import { useState, useEffect } from 'react';
import { Q } from '@nozbe/watermelondb';
import { database } from '@/src/database';
import type Goal from '@/src/database/models/Goal';
import type { GoalDisplay } from '../types';
import {
  getGoalEffectiveTime,
  getGoalEstimatedTime,
  getGoalProgress,
  isGoalCompleted,
} from '@/src/database/helpers';

// 获取所有活跃目标及其进度信息（目标切换抽屉用）
export function useGoalsWithProgress() {
  const [goals, setGoals] = useState<GoalDisplay[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);

    const subscription = database
      .get<Goal>('goals')
      .query(Q.where('status', 'active'), Q.sortBy('sort_order', Q.asc))
      .observe()
      .subscribe(async (rawGoals) => {
        const displays = await Promise.all(
          rawGoals.map(async (g) => {
            const effectiveTime = await getGoalEffectiveTime(g);
            const estimatedTime = await getGoalEstimatedTime(g);
            const progress = await getGoalProgress(g);
            const completed = await isGoalCompleted(g);

            return {
              id: g.id,
              title: g.title,
              color: g.color,
              effectiveTime,
              estimatedTime,
              progress,
              isCompleted: completed,
            } satisfies GoalDisplay;
          }),
        );

        setGoals(displays);
        setLoading(false);
      });

    return () => subscription.unsubscribe();
  }, []);

  return { goals, loading };
}
