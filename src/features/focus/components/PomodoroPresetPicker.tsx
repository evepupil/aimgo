import { useRef, useImperativeHandle, forwardRef } from 'react';
import { useTranslation } from 'react-i18next';
import { useColorScheme } from 'react-native';
import { Check } from 'lucide-react-native';
import { YStack, XStack, Text } from 'tamagui';
import GorhomBottomSheet from '@gorhom/bottom-sheet';

import { BottomSheet } from '@/src/shared/components/ui';
import { colors } from '@/src/constants/theme';
import { POMODORO_PRESETS } from '../types';

type PomodoroPresetPickerProps = {
  currentDuration: number;
  onSelect: (seconds: number) => void;
};

export type PomodoroPresetPickerRef = {
  open: () => void;
  close: () => void;
};

// 番茄钟时间预设选择器
export const PomodoroPresetPicker = forwardRef<PomodoroPresetPickerRef, PomodoroPresetPickerProps>(
  function PomodoroPresetPicker({ currentDuration, onSelect }, ref) {
    const { t } = useTranslation('focus');
    const colorScheme = useColorScheme();
    const theme = colorScheme === 'dark' ? colors.dark : colors.light;

    const sheetRef = useRef<GorhomBottomSheet>(null);

    useImperativeHandle(ref, () => ({
      open: () => sheetRef.current?.snapToIndex(0),
      close: () => sheetRef.current?.close(),
    }));

    return (
      <BottomSheet sheetRef={sheetRef} snapPoints={['35%']}>
        <YStack paddingHorizontal="$4" paddingTop="$2" gap="$2">
          <Text fontSize="$5" fontWeight="bold" marginBottom="$2">
            {t('selectDuration')}
          </Text>

          {POMODORO_PRESETS.map((preset) => {
            const isSelected = preset.value === currentDuration;
            return (
              <XStack
                key={preset.value}
                paddingVertical="$3"
                paddingHorizontal="$3"
                borderRadius="$3"
                backgroundColor={isSelected ? '$backgroundHover' : 'transparent'}
                alignItems="center"
                onPress={() => {
                  onSelect(preset.value);
                  sheetRef.current?.close();
                }}
                pressStyle={{ opacity: 0.7 }}
              >
                <Text flex={1} fontSize="$4" color="$color">
                  {preset.label}
                </Text>
                {isSelected && <Check size={18} color={theme.accent} />}
              </XStack>
            );
          })}
        </YStack>
      </BottomSheet>
    );
  },
);
