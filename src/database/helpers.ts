import type { Query } from '@nozbe/watermelondb';
import type Task from './models/Task';
import type Milestone from './models/Milestone';
import type Goal from './models/Goal';
import type FocusSession from './models/FocusSession';

// ──── 任务级 ────

/** 获取任务的累计有效专注时间（秒） */
export async function getTaskEffectiveTime(task: Task): Promise<number> {
  const sessions: FocusSession[] = await (task.focusSessions as Query<FocusSession>).fetch();
  return sessions.reduce((sum, s) => sum + s.effectiveDuration, 0);
}

/** 获取任务的时间进度（可超过 1） */
export async function getTaskProgress(task: Task): Promise<number> {
  if (task.estimatedTime <= 0) return 0;
  const effective = await getTaskEffectiveTime(task);
  return effective / task.estimatedTime;
}

// ──── 里程碑级 ────

/** 获取里程碑的预估时间 = 子任务预估时间之和（秒） */
export async function getMilestoneEstimatedTime(milestone: Milestone): Promise<number> {
  const tasks: Task[] = await (milestone.tasks as Query<Task>).fetch();
  return tasks.reduce((sum, t) => sum + t.estimatedTime, 0);
}

/** 获取里程碑的累计有效专注时间（秒） */
export async function getMilestoneEffectiveTime(milestone: Milestone): Promise<number> {
  const tasks: Task[] = await (milestone.tasks as Query<Task>).fetch();
  let total = 0;
  for (const task of tasks) {
    total += await getTaskEffectiveTime(task);
  }
  return total;
}

/** 获取里程碑的时间进度（可超过 1） */
export async function getMilestoneProgress(milestone: Milestone): Promise<number> {
  const estimated = await getMilestoneEstimatedTime(milestone);
  if (estimated <= 0) return 0;
  const effective = await getMilestoneEffectiveTime(milestone);
  return effective / estimated;
}

/** 判断里程碑是否完成（所有子任务已勾选） */
export async function isMilestoneCompleted(milestone: Milestone): Promise<boolean> {
  const tasks: Task[] = await (milestone.tasks as Query<Task>).fetch();
  if (tasks.length === 0) return false;
  return tasks.every((t) => t.isCompleted);
}

// ──── 目标级 ────

/** 获取目标的预估时间 = 子里程碑预估时间之和（秒） */
export async function getGoalEstimatedTime(goal: Goal): Promise<number> {
  const milestones: Milestone[] = await (goal.milestones as Query<Milestone>).fetch();
  let total = 0;
  for (const ms of milestones) {
    total += await getMilestoneEstimatedTime(ms);
  }
  return total;
}

/** 获取目标的累计有效专注时间（秒） */
export async function getGoalEffectiveTime(goal: Goal): Promise<number> {
  const sessions: FocusSession[] = await (goal.focusSessions as Query<FocusSession>).fetch();
  return sessions.reduce((sum, s) => sum + s.effectiveDuration, 0);
}

/** 获取目标的时间进度（可超过 1） */
export async function getGoalProgress(goal: Goal): Promise<number> {
  const estimated = await getGoalEstimatedTime(goal);
  if (estimated <= 0) return 0;
  const effective = await getGoalEffectiveTime(goal);
  return effective / estimated;
}

/** 判断目标是否完成（所有子里程碑已完成） */
export async function isGoalCompleted(goal: Goal): Promise<boolean> {
  const milestones: Milestone[] = await (goal.milestones as Query<Milestone>).fetch();
  if (milestones.length === 0) return false;
  for (const ms of milestones) {
    const completed = await isMilestoneCompleted(ms);
    if (!completed) return false;
  }
  return true;
}
