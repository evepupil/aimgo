import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

type GoalState = {
  // 当前选中的目标 ID
  currentGoalId: string | null;
  // 当前展开的里程碑 ID 集合
  expandedMilestoneIds: Set<string>;
  // 切换当前目标
  setCurrentGoalId: (id: string | null) => void;
  // 展开/收起里程碑
  toggleMilestone: (id: string) => void;
};

export const useGoalStore = create<GoalState>()(
  immer((set) => ({
    currentGoalId: null,
    expandedMilestoneIds: new Set<string>(),

    setCurrentGoalId: (id) =>
      set((state) => {
        state.currentGoalId = id;
        // 切换目标时收起所有里程碑
        state.expandedMilestoneIds = new Set<string>();
      }),

    toggleMilestone: (id) =>
      set((state) => {
        const next = new Set(state.expandedMilestoneIds);
        if (next.has(id)) {
          next.delete(id);
        } else {
          next.add(id);
        }
        state.expandedMilestoneIds = next;
      }),
  })),
);
