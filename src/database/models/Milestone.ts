import { Model } from '@nozbe/watermelondb';
import { text, field, date, readonly, relation, children } from '@nozbe/watermelondb/decorators';

export default class Milestone extends Model {
  static table = 'milestones';

  static associations = {
    goals: { type: 'belongs_to' as const, key: 'goal_id' },
    tasks: { type: 'has_many' as const, foreignKey: 'milestone_id' },
  };

  @text('title') title!: string;
  @text('description') description!: string;
  @field('goal_id') goalId!: string;
  @field('sort_order') sortOrder!: number;
  @field('deadline') deadline!: number | null;
  @readonly @date('created_at') createdAt!: Date;
  @date('updated_at') updatedAt!: Date;

  @relation('goals', 'goal_id') goal!: any;
  @children('tasks') tasks!: any;
}
