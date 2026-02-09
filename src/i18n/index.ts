import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import { getLocales } from 'expo-localization';

import zhCommon from './zh/common.json';
import zhGoals from './zh/goals.json';
import zhFocus from './zh/focus.json';
import zhMe from './zh/me.json';

import enCommon from './en/common.json';
import enGoals from './en/goals.json';
import enFocus from './en/focus.json';
import enMe from './en/me.json';

const systemLang = getLocales()[0]?.languageCode ?? 'zh';

i18n.use(initReactI18next).init({
  lng: systemLang === 'zh' ? 'zh' : 'en',
  fallbackLng: 'en',
  defaultNS: 'common',
  resources: {
    zh: {
      common: zhCommon,
      goals: zhGoals,
      focus: zhFocus,
      me: zhMe,
    },
    en: {
      common: enCommon,
      goals: enGoals,
      focus: enFocus,
      me: enMe,
    },
  },
  interpolation: {
    escapeValue: false,
  },
});

export default i18n;
