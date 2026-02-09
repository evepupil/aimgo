import { config } from '@tamagui/config/v3';
import { createTamagui } from 'tamagui';

const tamaguiConfig = createTamagui({
  ...config,
  themes: {
    ...config.themes,
    dark: {
      ...config.themes.dark,
      background: '#0A0A0A',
      backgroundHover: '#111111',
      backgroundPress: '#1A1A1A',
      backgroundFocus: '#1A1A1A',
      color: '#FAFAFA',
      colorHover: '#FFFFFF',
      colorPress: '#E0E0E0',
      borderColor: '#2A2A2A',
      borderColorHover: '#3A3A3A',
      placeholderColor: '#666666',
    },
    light: {
      ...config.themes.light,
      background: '#FAFAFA',
      backgroundHover: '#F0F0F0',
      backgroundPress: '#E8E8E8',
      backgroundFocus: '#E8E8E8',
      color: '#0A0A0A',
      colorHover: '#000000',
      colorPress: '#333333',
      borderColor: '#E0E0E0',
      borderColorHover: '#D0D0D0',
      placeholderColor: '#999999',
    },
  },
});

export default tamaguiConfig;

export type AppConfig = typeof tamaguiConfig;

declare module 'tamagui' {
  interface TamaguiCustomConfig extends AppConfig {}
}
