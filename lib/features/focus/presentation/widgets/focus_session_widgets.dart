import 'dart:math' as math;

import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/core/utils/duration_formatter.dart';
import 'package:aimgo/features/focus/application/focus_models.dart';
import 'package:flutter/material.dart';

final class FocusSessionLayoutMetrics {
  const FocusSessionLayoutMetrics({
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.modeToTargetSpacing,
    required this.targetToTimerSpacing,
    required this.timerToControlSpacing,
    required this.timerSize,
    required this.timerStrokeWidth,
    required this.timerTextSize,
    required this.timerLabelSpacing,
  });

  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double modeToTargetSpacing;
  final double targetToTimerSpacing;
  final double timerToControlSpacing;
  final double timerSize;
  final double timerStrokeWidth;
  final double timerTextSize;
  final double timerLabelSpacing;

  factory FocusSessionLayoutMetrics.fromSize(Size size) {
    final compactWidth = size.width <= 360;
    final compactHeight = size.height <= 720;
    final widthBasedTimer = size.width - (compactWidth ? 30 : 44);
    final targetTimer = compactHeight ? 182.0 : 224.0;
    final timerSize = math.max(164.0, math.min(widthBasedTimer, targetTimer));

    return FocusSessionLayoutMetrics(
      horizontalPadding: compactWidth ? 12 : 16,
      topPadding: compactHeight ? 10 : 14,
      bottomPadding: 30,
      modeToTargetSpacing: compactHeight ? 18 : 24,
      targetToTimerSpacing: compactHeight ? 30 : 40,
      timerToControlSpacing: compactHeight ? 28 : 42,
      timerSize: timerSize,
      timerStrokeWidth: compactWidth ? 8 : 10,
      timerTextSize: compactWidth ? 32 : 36,
      timerLabelSpacing: compactHeight ? 4 : 6,
    );
  }
}

final class FocusSessionHeroTags {
  const FocusSessionHeroTags._();

  static const targetEntry = 'focusSessionTargetEntry';
  static const timerRing = 'focusSessionTimerRing';
  static const controls = 'focusSessionControls';
}

class FocusSessionModeTabs extends StatelessWidget {
  const FocusSessionModeTabs({
    required this.mode,
    required this.pomodoroLabel,
    required this.freeLabel,
    this.onChange,
    this.enabled = true,
    super.key,
  });

  final FocusMode mode;
  final String pomodoroLabel;
  final String freeLabel;
  final ValueChanged<FocusMode>? onChange;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _FocusModeTabItem(
                label: pomodoroLabel,
                selected: mode == FocusMode.pomodoro,
                inactiveColor: inactiveColor,
                enabled: enabled,
                onTap:
                    onChange == null
                        ? null
                        : () => onChange!(FocusMode.pomodoro),
              ),
            ),
            Expanded(
              child: _FocusModeTabItem(
                label: freeLabel,
                selected: mode == FocusMode.free,
                inactiveColor: inactiveColor,
                enabled: enabled,
                onTap:
                    onChange == null ? null : () => onChange!(FocusMode.free),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusModeTabItem extends StatelessWidget {
  const _FocusModeTabItem({
    required this.label,
    required this.selected,
    required this.inactiveColor,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color inactiveColor;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color:
                selected
                    ? theme.colorScheme.primary
                    : inactiveColor.withValues(alpha: enabled ? 1 : 0.72),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class FocusSessionTargetEntry extends StatelessWidget {
  const FocusSessionTargetEntry({
    required this.enabled,
    required this.hasSelection,
    required this.pathText,
    required this.onTap,
    super.key,
  });

  final bool enabled;
  final bool hasSelection;
  final String pathText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        hasSelection
            ? theme.colorScheme.onSurface.withValues(alpha: 0.86)
            : theme.colorScheme.onSurfaceVariant;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child:
                      hasSelection
                          ? _FocusTargetBreadcrumb(
                            pathText: pathText,
                            color: theme.colorScheme.onSurface,
                            separatorColor: theme.colorScheme.onSurfaceVariant,
                          )
                          : Text(
                            pathText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.56,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusTargetBreadcrumb extends StatelessWidget {
  const _FocusTargetBreadcrumb({
    required this.pathText,
    required this.color,
    required this.separatorColor,
  });

  final String pathText;
  final Color color;
  final Color separatorColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts =
        pathText
            .split('>')
            .map((segment) => segment.trim())
            .where((segment) => segment.isNotEmpty)
            .toList();

    if (parts.isEmpty) {
      return Text(
        pathText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          color: separatorColor.withValues(alpha: 0.82),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            TextSpan(
              text: parts[i],
              style:
                  i == parts.length - 1
                      ? theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      )
                      : theme.textTheme.titleMedium?.copyWith(
                        color: color.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w500,
                      ),
            ),
            if (i != parts.length - 1)
              TextSpan(
                text: '  >  ',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: separatorColor.withValues(alpha: 0.56),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class FocusSessionTimerRing extends StatelessWidget {
  const FocusSessionTimerRing({
    required this.state,
    required this.metrics,
    required this.l10n,
    super.key,
  });

  final FocusTimerState state;
  final FocusSessionLayoutMetrics metrics;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerTextStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: metrics.timerTextSize,
      height: 1.05,
    );
    return Center(
      child: SizedBox(
        width: metrics.timerSize,
        height: metrics.timerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: metrics.timerStrokeWidth,
                backgroundColor: Colors.transparent,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            if (state.mode == FocusMode.pomodoro)
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: state.progressRatio,
                  strokeWidth: metrics.timerStrokeWidth,
                  backgroundColor: Colors.transparent,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (state.mode == FocusMode.free &&
                state.status != FocusTimerStatus.idle)
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: metrics.timerStrokeWidth,
                  backgroundColor: Colors.transparent,
                  color: theme.colorScheme.primary,
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.mode == FocusMode.pomodoro
                      ? formatClockFromSeconds(state.remainingSeconds)
                      : formatClockFromSeconds(state.displayElapsedSeconds),
                  style: timerTextStyle,
                ),
                SizedBox(height: metrics.timerLabelSpacing),
                Text(
                  state.mode == FocusMode.pomodoro
                      ? (state.status == FocusTimerStatus.paused
                          ? l10n.focusPause
                          : l10n.focusRemaining)
                      : (state.status == FocusTimerStatus.paused
                          ? l10n.focusPause
                          : l10n.focusElapsed),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FocusSessionControls extends StatelessWidget {
  const FocusSessionControls({
    required this.state,
    required this.canStart,
    required this.onStart,
    required this.onPause,
    required this.onTerminate,
    required this.l10n,
    super.key,
  });

  final FocusTimerState state;
  final bool canStart;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onTerminate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case FocusTimerStatus.idle:
        return Center(
          child: SizedBox(
            width: 196,
            height: 46,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                elevation: 0,
                shadowColor: Colors.transparent,
                textStyle: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              onPressed: canStart ? onStart : null,
              child: Text(l10n.focusStart),
            ),
          ),
        );
      case FocusTimerStatus.running:
        return _FocusRunningControlRow(
          centerIcon: Icons.pause_rounded,
          centerTooltip: l10n.focusPause,
          onCenterTap: onPause,
          onSideTap: onTerminate,
          sideTooltip: l10n.focusTerminate,
        );
      case FocusTimerStatus.paused:
        return _FocusRunningControlRow(
          centerIcon: Icons.play_arrow_rounded,
          centerTooltip: l10n.focusResume,
          onCenterTap: onStart,
          onSideTap: onTerminate,
          sideTooltip: l10n.focusTerminate,
        );
    }
  }
}

class _FocusRunningControlRow extends StatelessWidget {
  const _FocusRunningControlRow({
    required this.centerIcon,
    required this.centerTooltip,
    required this.onCenterTap,
    required this.onSideTap,
    required this.sideTooltip,
  });

  final IconData centerIcon;
  final String centerTooltip;
  final VoidCallback onCenterTap;
  final VoidCallback onSideTap;
  final String sideTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FocusPrimaryCircleButton(
          icon: centerIcon,
          tooltip: centerTooltip,
          onPressed: onCenterTap,
          size: 84,
        ),
        const SizedBox(width: 18),
        _FocusOutlineCircleButton(
          icon: Icons.stop_rounded,
          tooltip: sideTooltip,
          onPressed: onSideTap,
          size: 58,
          activeIconColor: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}

class _FocusPrimaryCircleButton extends StatelessWidget {
  const _FocusPrimaryCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Tooltip(
        message: tooltip,
        child: FilledButton(
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          onPressed: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: size * 0.40),
          ),
        ),
      ),
    );
  }
}

class _FocusOutlineCircleButton extends StatelessWidget {
  const _FocusOutlineCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.size,
    this.activeIconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final Color? activeIconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final accentColor = activeIconColor ?? theme.colorScheme.onSurface;
    final iconColor = accentColor.withValues(alpha: enabled ? 0.84 : 0.32);
    final backgroundColor =
        activeIconColor != null
            ? accentColor.withValues(alpha: enabled ? 0.08 : 0.04)
            : theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: enabled ? 0.42 : 0.22,
            );
    final borderColor =
        activeIconColor != null
            ? accentColor.withValues(alpha: enabled ? 0.22 : 0.12)
            : theme.colorScheme.outlineVariant.withValues(
              alpha: enabled ? 0.22 : 0.10,
            );
    return SizedBox(
      width: size,
      height: size,
      child: Tooltip(
        message: tooltip,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            backgroundColor: backgroundColor,
            side: BorderSide(color: borderColor),
          ),
          onPressed: onPressed,
          child: Icon(icon, size: size * 0.36, color: iconColor),
        ),
      ),
    );
  }
}

class FocusSessionNoteEntry extends StatelessWidget {
  const FocusSessionNoteEntry({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
