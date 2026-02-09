import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface AppState {
  // 在此定义全局应用状态
}

export const useAppStore = create<AppState>()(
  immer(() => ({
    // 初始状态
  })),
);
