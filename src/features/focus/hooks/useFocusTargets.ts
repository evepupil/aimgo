import { useState, useEffect } from 'react';
import { Q } from '@nozbe/watermelondb';
import type { Query } from '@nozbe/watermelondb';
import { database } from '@/src/database';
import type Goal from '@/src/database/models/Goal';
import type Milestone from '@/src/database/models/Milestone';
import type Task from '@/src/database/models/Task';

// 简单展示项
type SelectItem = {
  id: string;
  title: string;
};

// 获取所有活跃目标（用于选择器）
export function useFocusGoals() {
  const [goals, setGoals] = useState<SelectItem[]>([]);

  useEffect(() => {
    const subscription = database
      .get<Goal>('goals')
      .query(Q.where('status', 'active'), Q.sortBy('sort_order', Q.asc))
      .observe()
      .subscribe((rows) => {
        setGoals(rows.map((g) => ({ id: g.id, title: g.title })));
      });

    return () => subscription.unsubscribe();
  }, []);

  return goals;
}

// 获取指定目标下的里程碑（用于选择器）
export function useFocusMilestones(goalId: string | null) {
  const [milestones, setMilestones] = useState<SelectItem[]>([]);

  useEffect(() => {
    if (!goalId) {
      setMilestones([]);
      return;
    }

    const subscription = database
      .get<Milestone>('milestones')
      .query(Q.where('goal_id', goalId), Q.sortBy('sort_order', Q.asc))
      .observe()
      .subscribe((rows) => {
        setMilestones(rows.map((m) => ({ id: m.id, title: m.title })));
      });

    return () => subscription.unsubscribe();
  }, [goalId]);

  return milestones;
}

// 获取指定里程碑下的任务（用于选择器）
export function useFocusTasks(milestoneId: string | null) {
  const [tasks, setTasks] = useState<SelectItem[]>([]);

  useEffect(() => {
    if (!milestoneId) {
      setTasks([]);
      return;
    }

    const subscription = database
      .get<Task>('tasks')
      .query(
        Q.where('milestone_id', milestoneId),
        Q.where('is_completed', false),
        Q.sortBy('sort_order', Q.asc),
      )
      .observe()
      .subscribe((rows) => {
        setTasks(rows.map((t) => ({ id: t.id, title: t.title })));
      });

    return () => subscription.unsubscribe();
  }, [milestoneId]);

  return tasks;
}
