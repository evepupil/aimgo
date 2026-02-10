import { useRef, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { YStack } from 'tamagui';

import { TabSwitcher } from '@/src/shared/components/ui';
import {
  FocusHeader,
  TimerRing,
  TimerDisplay,
  FocusControls,
  FocusContextPath,
  FocusTargetPicker,
  PomodoroPresetPicker,
} from '@/src/features/focus/components';
import type { FocusTargetPickerRef } from '@/src/features/focus/components';
import type { PomodoroPresetPickerRef } from '@/src/features/focus/components';
import { useTimer } from '@/src/features/focus/hooks';
import { useTimerStore } from '@/src/features/focus/store';
import type { FocusMode, FocusTarget } from '@/src/features/focus/types';

export default function FocusScreen() {
  const { t } = useTranslation('focus');

  // Store
  const mode = useTimerStore((s) => s.mode);
  const status = useTimerStore((s) => s.status);
  const elapsed = useTimerStore((s) => s.elapsed);
  const pomodoroDuration = useTimerStore((s) => s.pomodoroDuration);
  const target = useTimerStore((s) => s.target);
  const setMode = useTimerStore((s) => s.setMode);
  const setTarget = useTimerStore((s) => s.setTarget);
  const setPomodoroDuration = useTimerStore((s) => s.setPomodoroDuration);
  const start = useTimerStore((s) => s.start);
  const pause = useTimerStore((s) => s.pause);
  const resume = useTimerStore((s) => s.resume);
  const stop = useTimerStore((s) => s.stop);

  // 驱动计时器 tick
  useTimer();

  // Refs
  const targetPickerRef = useRef<FocusTargetPickerRef>(null);
  const presetPickerRef = useRef<PomodoroPresetPickerRef>(null);

  // 模式 Tab
  const modeTabs = [
    { key: 'pomodoro', label: t('pomodoro') },
    { key: 'free', label: t('freeMode') },
  ];

  // 计算展示时间和进度
  const isPomodoro = mode === 'pomodoro';
  const displaySeconds = isPomodoro
    ? Math.max(pomodoroDuration - elapsed, 0)
    : elapsed;
  const progress = isPomodoro
    ? Math.min(elapsed / pomodoroDuration, 1)
    : 0;
  const timeLabel = isPomodoro ? t('remaining') : t('elapsed');

  // 切换模式
  const handleModeChange = useCallback(
    (key: string) => {
      setMode(key as FocusMode);
    },
    [setMode],
  );

  // 选择目标回调
  const handleTargetSelect = useCallback(
    (newTarget: FocusTarget) => {
      setTarget(newTarget);
    },
    [setTarget],
  );

  // 时间预设回调
  const handleDurationSelect = useCallback(
    (seconds: number) => {
      setPomodoroDuration(seconds);
    },
    [setPomodoroDuration],
  );

  return (
    <YStack flex={1} backgroundColor="$background">
      <FocusHeader
        onHistoryPress={() => {
          // Phase 8：专注历史页
        }}
        onSettingsPress={() => {
          // Phase 6.2：设置页
        }}
      />

      {/* 模式切换 */}
      <YStack paddingHorizontal="$4" paddingTop="$2">
        <TabSwitcher
          tabs={modeTabs}
          activeKey={mode}
          onTabChange={handleModeChange}
        />
      </YStack>

      {/* 专注目标路径 */}
      <YStack paddingTop="$4">
        <FocusContextPath
          target={target}
          onPress={() => targetPickerRef.current?.open()}
        />
      </YStack>

      {/* 计时器区域 */}
      <YStack flex={1} alignItems="center" justifyContent="center" gap="$4">
        {/* Skia 圆环 */}
        <YStack
          alignItems="center"
          justifyContent="center"
          onPress={
            status === 'idle' && isPomodoro
              ? () => presetPickerRef.current?.open()
              : undefined
          }
        >
          <TimerRing progress={progress} />
          {/* 时间叠加在圆环中心 */}
          <YStack position="absolute">
            <TimerDisplay seconds={displaySeconds} label={timeLabel} />
          </YStack>
        </YStack>

        {/* 控制按钮 */}
        <FocusControls
          status={status}
          onStart={start}
          onPause={pause}
          onResume={resume}
          onStop={stop}
        />
      </YStack>

      {/* 底部弹出选择器 */}
      <FocusTargetPicker
        ref={targetPickerRef}
        currentTarget={target}
        onSelect={handleTargetSelect}
      />
      <PomodoroPresetPicker
        ref={presetPickerRef}
        currentDuration={pomodoroDuration}
        onSelect={handleDurationSelect}
      />
    </YStack>
  );
}
