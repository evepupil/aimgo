import { Model } from '@nozbe/watermelondb';
import { text, field, date, readonly, relation, children } from '@nozbe/watermelondb/decorators';

export default class Task extends Model {
  static table = 'tasks';

  static associations = {
    milestones: { type: 'belongs_to' as const, key: 'milestone_id' },
    focus_sessions: { type: 'has_many' as const, foreignKey: 'task_id' },
  };

  @text('title') title!: string;
  @field('milestone_id') milestoneId!: string;
  @field('is_completed') isCompleted!: boolean;
  @field('sort_order') sortOrder!: number;
  @field('estimated_time') estimatedTime!: number;
  @readonly @date('created_at') createdAt!: Date;
  @date('updated_at') updatedAt!: Date;

  @relation('milestones', 'milestone_id') milestone!: any;
  @children('focus_sessions') focusSessions!: any;
}
