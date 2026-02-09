import { Model } from '@nozbe/watermelondb';
import { text, field, date, readonly, children } from '@nozbe/watermelondb/decorators';

export default class Goal extends Model {
  static table = 'goals';

  static associations = {
    milestones: { type: 'has_many' as const, foreignKey: 'goal_id' },
    focus_sessions: { type: 'has_many' as const, foreignKey: 'goal_id' },
  };

  @text('title') title!: string;
  @text('description') description!: string;
  @text('status') status!: string;
  @text('color') color!: string;
  @field('deadline') deadline!: number | null;
  @field('sort_order') sortOrder!: number;
  @readonly @date('created_at') createdAt!: Date;
  @date('updated_at') updatedAt!: Date;

  @children('milestones') milestones!: any;
  @children('focus_sessions') focusSessions!: any;
}
