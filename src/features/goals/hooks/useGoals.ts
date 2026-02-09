import { useState, useEffect } from 'react';
import { Q } from '@nozbe/watermelondb';
import { database } from '@/src/database';
import type Goal from '@/src/database/models/Goal';

// 获取所有活跃目标
export function useGoals() {
  const [goals, setGoals] = useState<Goal[]>([]);

  useEffect(() => {
    const subscription = database
      .get<Goal>('goals')
      .query(Q.where('status', 'active'), Q.sortBy('sort_order', Q.asc))
      .observe()
      .subscribe(setGoals);

    return () => subscription.unsubscribe();
  }, []);

  return goals;
}

// 根据 ID 获取单个目标
export function useGoal(goalId: string | null) {
  const [goal, setGoal] = useState<Goal | null>(null);

  useEffect(() => {
    if (!goalId) {
      setGoal(null);
      return;
    }

    const subscription = database
      .get<Goal>('goals')
      .findAndObserve(goalId)
      .subscribe({
        next: setGoal,
        error: () => setGoal(null),
      });

    return () => subscription.unsubscribe();
  }, [goalId]);

  return goal;
}
