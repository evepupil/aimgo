export const colors = {
  dark: {
    background: '#0A0A0A',
    card: '#141414',
    cardHover: '#1A1A1A',
    border: '#2A2A2A',
    borderLight: '#1F1F1F',
    text: '#FAFAFA',
    textSecondary: '#A0A0A0',
    textMuted: '#666666',
    accent: '#6366F1',
    accentLight: '#818CF8',
    success: '#22C55E',
    warning: '#F97316',
    error: '#EF4444',
  },
  light: {
    background: '#FAFAFA',
    card: '#FFFFFF',
    cardHover: '#F5F5F5',
    border: '#E5E5E5',
    borderLight: '#F0F0F0',
    text: '#0A0A0A',
    textSecondary: '#6B7280',
    textMuted: '#9CA3AF',
    accent: '#6366F1',
    accentLight: '#818CF8',
    success: '#16A34A',
    warning: '#EA580C',
    error: '#DC2626',
  },
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
} as const;

export const radius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  full: 9999,
} as const;
