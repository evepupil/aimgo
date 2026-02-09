import { Model } from '@nozbe/watermelondb';
import { text, field, date, readonly, relation } from '@nozbe/watermelondb/decorators';

export default class FocusSession extends Model {
  static table = 'focus_sessions';

  static associations = {
    tasks: { type: 'belongs_to' as const, key: 'task_id' },
    goals: { type: 'belongs_to' as const, key: 'goal_id' },
  };

  @field('task_id') taskId!: string;
  @field('goal_id') goalId!: string;
  @field('duration') duration!: number;
  @field('efficiency') efficiency!: number;
  @field('effective_duration') effectiveDuration!: number;
  @field('started_at') startedAt!: number;
  @field('ended_at') endedAt!: number | null;
  @text('note') note!: string | null;

  @relation('tasks', 'task_id') task!: any;
  @relation('goals', 'goal_id') goal!: any;
}
