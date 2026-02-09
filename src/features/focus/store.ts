import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface TimerState {
  // 在此定义番茄钟状态
}

export const useTimerStore = create<TimerState>()(
  immer(() => ({
    // 初始状态
  })),
);
