import { useTranslation } from 'react-i18next';
import { ChevronRight } from 'lucide-react-native';
import { useColorScheme } from 'react-native';
import { XStack, Text } from 'tamagui';

import { colors } from '@/src/constants/theme';
import type { FocusTarget } from '../types';

type FocusContextPathProps = {
  target: FocusTarget;
  onPress?: () => void;
};

// 专注目标路径展示（目标 > 里程碑 > 任务）
export function FocusContextPath({ target, onPress }: FocusContextPathProps) {
  const { t } = useTranslation('focus');
  const colorScheme = useColorScheme();
  const theme = colorScheme === 'dark' ? colors.dark : colors.light;

  const hasTarget = target.goalId !== null;

  return (
    <XStack
      alignItems="center"
      justifyContent="center"
      paddingHorizontal="$4"
      paddingVertical="$2"
      gap="$1"
      onPress={onPress}
      pressStyle={{ opacity: 0.7 }}
    >
      {hasTarget ? (
        <>
          <Text fontSize="$2" color="$placeholderColor" numberOfLines={1}>
            {target.goalTitle}
          </Text>
          {target.milestoneTitle && (
            <>
              <ChevronRight size={12} color={theme.textMuted} />
              <Text fontSize="$2" color="$placeholderColor" numberOfLines={1}>
                {target.milestoneTitle}
              </Text>
            </>
          )}
          {target.taskTitle && (
            <>
              <ChevronRight size={12} color={theme.textMuted} />
              <Text
                fontSize="$2"
                color="$color"
                fontWeight="600"
                numberOfLines={1}
                flexShrink={1}
              >
                {target.taskTitle}
              </Text>
            </>
          )}
        </>
      ) : (
        <Text fontSize="$3" color="$placeholderColor">
          {t('selectTarget')}
        </Text>
      )}
    </XStack>
  );
}
