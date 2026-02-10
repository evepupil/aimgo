import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

import type { FocusMode, TimerStatus, FocusTarget } from './types';
import { DEFAULT_POMODORO_DURATION } from './types';

// 空的专注目标
const EMPTY_TARGET: FocusTarget = {
  goalId: null,
  goalTitle: null,
  milestoneId: null,
  milestoneTitle: null,
  taskId: null,
  taskTitle: null,
};

type TimerState = {
  // 专注模式：番茄钟 / 自由
  mode: FocusMode;
  // 计时状态
  status: TimerStatus;
  // 番茄钟设定时长（秒）
  pomodoroDuration: number;
  // 已计时秒数
  elapsed: number;
  // 专注开始时间戳（毫秒）
  startedAt: number | null;
  // 专注目标上下文
  target: FocusTarget;

  // ---- Actions ----
  setMode: (mode: FocusMode) => void;
  setPomodoroDuration: (seconds: number) => void;
  setTarget: (target: FocusTarget) => void;
  start: () => void;
  pause: () => void;
  resume: () => void;
  stop: () => void;
  tick: () => void;
  reset: () => void;
};

export const useTimerStore = create<TimerState>()(
  immer((set) => ({
    mode: 'pomodoro',
    status: 'idle',
    pomodoroDuration: DEFAULT_POMODORO_DURATION,
    elapsed: 0,
    startedAt: null,
    target: EMPTY_TARGET,

    setMode: (mode) =>
      set((state) => {
        // 只能在空闲时切换模式
        if (state.status !== 'idle') return;
        state.mode = mode;
      }),

    setPomodoroDuration: (seconds) =>
      set((state) => {
        if (state.status !== 'idle') return;
        state.pomodoroDuration = seconds;
      }),

    setTarget: (target) =>
      set((state) => {
        state.target = target;
      }),

    start: () =>
      set((state) => {
        state.status = 'running';
        state.elapsed = 0;
        state.startedAt = Date.now();
      }),

    pause: () =>
      set((state) => {
        if (state.status !== 'running') return;
        state.status = 'paused';
      }),

    resume: () =>
      set((state) => {
        if (state.status !== 'paused') return;
        state.status = 'running';
      }),

    stop: () =>
      set((state) => {
        state.status = 'idle';
        state.elapsed = 0;
        state.startedAt = null;
      }),

    tick: () =>
      set((state) => {
        if (state.status !== 'running') return;
        state.elapsed += 1;
      }),

    reset: () =>
      set((state) => {
        state.status = 'idle';
        state.elapsed = 0;
        state.startedAt = null;
        state.target = EMPTY_TARGET;
      }),
  })),
);
