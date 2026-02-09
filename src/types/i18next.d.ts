import type zhCommon from '../i18n/zh/common.json';
import type zhGoals from '../i18n/zh/goals.json';
import type zhFocus from '../i18n/zh/focus.json';
import type zhMe from '../i18n/zh/me.json';

// i18next 类型声明：翻译 key 自动补全 + 类型检查
declare module 'i18next' {
  interface CustomTypeOptions {
    defaultNS: 'common';
    resources: {
      common: typeof zhCommon;
      goals: typeof zhGoals;
      focus: typeof zhFocus;
      me: typeof zhMe;
    };
  }
}
