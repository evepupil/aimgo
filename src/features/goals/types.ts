// 目标计算后的展示数据（目标切换抽屉用）
export type GoalDisplay = {
  id: string;
  title: string;
  color: string;
  effectiveTime: number; // 秒
  estimatedTime: number; // 秒
  progress: number; // 0~N
  isCompleted: boolean;
};

// 里程碑计算后的展示数据
export type MilestoneDisplay = {
  id: string;
  title: string;
  completedTaskCount: number;
  totalTaskCount: number;
  effectiveTime: number; // 秒
  estimatedTime: number; // 秒
  progress: number; // 0~N
  isCompleted: boolean;
};

// 任务计算后的展示数据
export type TaskDisplay = {
  id: string;
  title: string;
  isCompleted: boolean;
  effectiveTime: number;
  estimatedTime: number;
  progress: number;
};
