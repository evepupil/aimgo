import { appSchema, tableSchema } from '@nozbe/watermelondb';

export const schema = appSchema({
  version: 1,
  tables: [
    tableSchema({
      name: 'goals',
      columns: [
        { name: 'title', type: 'string' },
        { name: 'description', type: 'string' },
        { name: 'status', type: 'string' }, // active | completed | archived | paused
        { name: 'color', type: 'string' },
        { name: 'deadline', type: 'number', isOptional: true },
        { name: 'sort_order', type: 'number' },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),
    tableSchema({
      name: 'milestones',
      columns: [
        { name: 'goal_id', type: 'string', isIndexed: true },
        { name: 'title', type: 'string' },
        { name: 'description', type: 'string' },
        { name: 'sort_order', type: 'number' },
        { name: 'deadline', type: 'number', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),
    tableSchema({
      name: 'tasks',
      columns: [
        { name: 'milestone_id', type: 'string', isIndexed: true },
        { name: 'title', type: 'string' },
        { name: 'is_completed', type: 'boolean' },
        { name: 'sort_order', type: 'number' },
        { name: 'estimated_time', type: 'number' }, // 预估时间（秒）
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),
    tableSchema({
      name: 'focus_sessions',
      columns: [
        { name: 'task_id', type: 'string', isIndexed: true },
        { name: 'goal_id', type: 'string', isIndexed: true },
        { name: 'duration', type: 'number' }, // 实际专注时长（秒）
        { name: 'efficiency', type: 'number' }, // 效率系数 0~1
        { name: 'effective_duration', type: 'number' }, // 有效时长 = duration × efficiency（秒）
        { name: 'started_at', type: 'number' },
        { name: 'ended_at', type: 'number', isOptional: true },
        { name: 'note', type: 'string', isOptional: true },
      ],
    }),
  ],
});
