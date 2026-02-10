import { useState, useEffect } from 'react';
import { Q } from '@nozbe/watermelondb';
import { database } from '@/src/database';
import type Goal from '@/src/database/models/Goal';
import type Milestone from '@/src/database/models/Milestone';
import type Task from '@/src/database/models/Task';

// 搜索结果条目
export type SearchResultItem = {
  id: string;
  title: string;
  type: 'goal' | 'milestone' | 'task';
  /** 里程碑的父目标标题 / 任务的父里程碑标题 */
  parentTitle?: string;
  /** 关联目标的颜色 */
  goalColor?: string;
  isCompleted?: boolean;
  /** 所属目标 ID */
  goalId?: string;
  /** 所属里程碑 ID（仅任务有） */
  milestoneId?: string;
};

type SearchResults = {
  results: SearchResultItem[];
  isSearching: boolean;
};

// 全文搜索 hook —— 跨目标/里程碑/任务按标题模糊搜索，300ms 防抖
export function useSearch(keyword: string): SearchResults {
  const [results, setResults] = useState<SearchResultItem[]>([]);
  const [isSearching, setIsSearching] = useState(false);

  useEffect(() => {
    if (!keyword.trim()) {
      setResults([]);
      setIsSearching(false);
      return;
    }

    setIsSearching(true);

    const timer = setTimeout(async () => {
      try {
        const sanitized = Q.sanitizeLikeString(keyword.trim());
        const likePattern = `%${sanitized}%`;

        // 并行查询三张表
        const [goals, milestones, tasks] = await Promise.all([
          database
            .get<Goal>('goals')
            .query(Q.where('title', Q.like(likePattern)))
            .fetch(),
          database
            .get<Milestone>('milestones')
            .query(Q.where('title', Q.like(likePattern)))
            .fetch(),
          database
            .get<Task>('tasks')
            .query(Q.where('title', Q.like(likePattern)))
            .fetch(),
        ]);

        const items: SearchResultItem[] = [];

        // 目标结果
        for (const g of goals) {
          items.push({
            id: g.id,
            title: g.title,
            type: 'goal',
            goalColor: g.color,
            goalId: g.id,
          });
        }

        // 里程碑结果：附带父目标信息
        for (const m of milestones) {
          let parentTitle: string | undefined;
          let goalColor: string | undefined;
          try {
            const goal = await m.goal.fetch();
            parentTitle = goal.title;
            goalColor = goal.color;
          } catch {
            // 父目标可能已被删除
          }
          items.push({
            id: m.id,
            title: m.title,
            type: 'milestone',
            parentTitle,
            goalColor,
            goalId: m.goalId,
          });
        }

        // 任务结果：附带父里程碑 + 祖父目标信息
        for (const t of tasks) {
          let parentTitle: string | undefined;
          let goalColor: string | undefined;
          let goalId: string | undefined;
          try {
            const milestone = await t.milestone.fetch();
            parentTitle = milestone.title;
            const goal = await milestone.goal.fetch();
            goalColor = goal.color;
            goalId = goal.id;
          } catch {
            // 父级记录可能已被删除
          }
          items.push({
            id: t.id,
            title: t.title,
            type: 'task',
            parentTitle,
            goalColor,
            isCompleted: t.isCompleted,
            goalId,
            milestoneId: t.milestoneId,
          });
        }

        setResults(items);
      } catch {
        // 查询异常时清空结果
        setResults([]);
      } finally {
        setIsSearching(false);
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [keyword]);

  return { results, isSearching };
}
