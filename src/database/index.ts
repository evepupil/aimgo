import { Database } from '@nozbe/watermelondb';
import SQLiteAdapter from '@nozbe/watermelondb/adapters/sqlite';
import { schema } from './schema';
import Goal from './models/Goal';
import Milestone from './models/Milestone';
import Task from './models/Task';
import FocusSession from './models/FocusSession';

const adapter = new SQLiteAdapter({
  schema,
  jsi: true,
  onSetUpError: (error) => {
    console.error('Database setup error:', error);
  },
});

export const database = new Database({
  adapter,
  modelClasses: [Goal, Milestone, Task, FocusSession],
});
