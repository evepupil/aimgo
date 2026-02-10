export type FocusMode = 'pomodoro' | 'free';

export type TimerStatus = 'idle' | 'running' | 'paused';

// 番茄钟预设时间（秒）
export const POMODORO_PRESETS = [
  { label: '25 min', value: 25 * 60 },
  { label: '45 min', value: 45 * 60 },
  { label: '60 min', value: 60 * 60 },
  { label: '90 min', value: 90 * 60 },
] as const;

export const DEFAULT_POMODORO_DURATION = 25 * 60;

// 专注目标上下文
export type FocusTarget = {
  goalId: string | null;
  goalTitle: string | null;
  milestoneId: string | null;
  milestoneTitle: string | null;
  taskId: string | null;
  taskTitle: string | null;
};
