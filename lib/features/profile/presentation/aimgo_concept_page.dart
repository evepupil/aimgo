import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AimGoConceptPage extends StatelessWidget {
  const AimGoConceptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = _conceptSteps(l10n);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.conceptTitle),
              ),
            ],
        body: ListView(
          padding: LayoutTokens.listPagePadding,
          children: [
            _ConceptHeroCard(steps: steps),
            const SizedBox(height: LayoutTokens.sectionGapLarge),
            _ConceptFlowCard(steps: steps),
            const SizedBox(height: LayoutTokens.sectionGapLarge),
            _SectionLabel(label: l10n.conceptDetailSectionTitle),
            const SizedBox(height: 10),
            for (var i = 0; i < steps.length; i++) ...[
              _ConceptStepCard(step: steps[i]),
              if (i < steps.length - 1)
                const SizedBox(height: LayoutTokens.sectionGapLarge),
            ],
            const SizedBox(height: LayoutTokens.sectionGapLarge),
            _ConceptActionCard(onOpenGoals: () => context.go(RoutePaths.goals)),
          ],
        ),
      ),
    );
  }

  List<_ConceptStepData> _conceptSteps(AppLocalizations l10n) {
    return [
      _ConceptStepData(
        number: 1,
        icon: Icons.flag_outlined,
        title: l10n.conceptStepGoalTitle,
        summary: l10n.conceptStepGoalSummary,
        body: l10n.conceptStepGoalBody,
        rule: l10n.conceptStepGoalRule,
        visual: _ConceptGoalVisual(l10n: l10n),
      ),
      _ConceptStepData(
        number: 2,
        icon: Icons.account_tree_outlined,
        title: l10n.conceptStepMilestoneTitle,
        summary: l10n.conceptStepMilestoneSummary,
        body: l10n.conceptStepMilestoneBody,
        rule: l10n.conceptStepMilestoneRule,
        visual: _ConceptMilestoneVisual(l10n: l10n),
      ),
      _ConceptStepData(
        number: 3,
        icon: Icons.checklist_outlined,
        title: l10n.conceptStepTaskTitle,
        summary: l10n.conceptStepTaskSummary,
        body: l10n.conceptStepTaskBody,
        rule: l10n.conceptStepTaskRule,
        visual: _ConceptTaskVisual(l10n: l10n),
      ),
      _ConceptStepData(
        number: 4,
        icon: Icons.timer_outlined,
        title: l10n.conceptStepFocusTitle,
        summary: l10n.conceptStepFocusSummary,
        body: l10n.conceptStepFocusBody,
        rule: l10n.conceptStepFocusRule,
        visual: _ConceptFocusVisual(l10n: l10n),
      ),
      _ConceptStepData(
        number: 5,
        icon: Icons.speed_outlined,
        title: l10n.conceptStepReviewTitle,
        summary: l10n.conceptStepReviewSummary,
        body: l10n.conceptStepReviewBody,
        rule: l10n.conceptStepReviewRule,
        visual: _ConceptReviewVisual(l10n: l10n),
      ),
      _ConceptStepData(
        number: 6,
        icon: Icons.insights_outlined,
        title: l10n.conceptStepAnalyticsTitle,
        summary: l10n.conceptStepAnalyticsSummary,
        body: l10n.conceptStepAnalyticsBody,
        rule: l10n.conceptStepAnalyticsRule,
        visual: _ConceptAnalyticsVisual(l10n: l10n),
      ),
    ];
  }
}

class _ConceptStepData {
  const _ConceptStepData({
    required this.number,
    required this.icon,
    required this.title,
    required this.summary,
    required this.body,
    required this.rule,
    required this.visual,
  });

  final int number;
  final IconData icon;
  final String title;
  final String summary;
  final String body;
  final String rule;
  final Widget visual;
}

class _ConceptHeroCard extends StatelessWidget {
  const _ConceptHeroCard({required this.steps});

  final List<_ConceptStepData> steps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    color: theme.colorScheme.primary,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.conceptHeadline,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.conceptSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final step in steps)
                  _ConceptChip(icon: step.icon, label: step.title),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConceptChip extends StatelessWidget {
  const _ConceptChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.34,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptFlowCard extends StatelessWidget {
  const _ConceptFlowCard({required this.steps});

  final List<_ConceptStepData> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          children: [
            for (var i = 0; i < steps.length; i++)
              _FlowStepTile(step: steps[i], isLast: i == steps.length - 1),
          ],
        ),
      ),
    );
  }
}

class _FlowStepTile extends StatelessWidget {
  const _FlowStepTile({required this.step, required this.isLast});

  final _ConceptStepData step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.icon,
                    size: 19,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: _DottedLinePainter(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.28,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    var y = 5.0;
    while (y < size.height - 1) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + 3),
        paint,
      );
      y += 8;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ConceptStepCard extends StatelessWidget {
  const _ConceptStepCard({required this.step});

  final _ConceptStepData step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _StepBadge(label: l10n.conceptStepLabel(step.number)),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                step.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              step.body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 14),
            step.visual,
            const SizedBox(height: 14),
            _RuleNote(text: step.rule),
          ],
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class _RuleNote extends StatelessWidget {
  const _RuleNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 17, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConceptVisualFrame extends StatelessWidget {
  const _ConceptVisualFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(LayoutTokens.radiusSmall),
      ),
      child: child,
    );
  }
}

class _ConceptGoalVisual extends StatelessWidget {
  const _ConceptGoalVisual({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ConceptVisualFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VisualHeader(
            icon: Icons.flag_outlined,
            label: l10n.conceptVisualGoalName,
          ),
          const SizedBox(height: 12),
          _VisualMetricRow(label: l10n.conceptVisualPlanTime, value: '80h'),
          const SizedBox(height: 8),
          const _MiniProgressBar(value: 0),
          const SizedBox(height: 8),
          _VisualMetricRow(label: l10n.conceptVisualTimeProgress, value: '0%'),
        ],
      ),
    );
  }
}

class _ConceptMilestoneVisual extends StatelessWidget {
  const _ConceptMilestoneVisual({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ConceptVisualFrame(
      child: Column(
        children: [
          _VisualTreeRow(
            icon: Icons.flag_outlined,
            label: l10n.conceptVisualGoalName,
          ),
          const _VisualTreeLine(),
          _VisualTreeRow(
            icon: Icons.book_outlined,
            label: l10n.conceptVisualMilestoneVocabulary,
          ),
          const _VisualTreeLine(),
          _VisualTreeRow(
            icon: Icons.menu_book_outlined,
            label: l10n.conceptVisualMilestoneReading,
          ),
          const _VisualTreeLine(),
          _VisualTreeRow(
            icon: Icons.assignment_outlined,
            label: l10n.conceptVisualMilestoneMock,
          ),
        ],
      ),
    );
  }
}

class _ConceptTaskVisual extends StatelessWidget {
  const _ConceptTaskVisual({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ConceptVisualFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VisualHeader(
            icon: Icons.today_outlined,
            label: l10n.conceptVisualTodayTasks,
          ),
          const SizedBox(height: 10),
          _TaskLine(text: l10n.conceptVisualTaskWords),
          _TaskLine(text: l10n.conceptVisualTaskReading),
          _TaskLine(text: l10n.conceptVisualTaskListening),
        ],
      ),
    );
  }
}

class _ConceptFocusVisual extends StatelessWidget {
  const _ConceptFocusVisual({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ConceptVisualFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VisualHeader(
            icon: Icons.timer_outlined,
            label: l10n.conceptVisualCurrentFocus,
          ),
          const SizedBox(height: 12),
          Text(
            '25:00',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _VisualMetricRow(
            label: l10n.conceptVisualBoundTarget,
            value: l10n.conceptVisualTaskReading,
          ),
        ],
      ),
    );
  }
}

class _ConceptReviewVisual extends StatelessWidget {
  const _ConceptReviewVisual({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ConceptVisualFrame(
      child: Column(
        children: [
          _VisualMetricRow(
            label: l10n.conceptVisualFocusDuration,
            value: '60m',
          ),
          const SizedBox(height: 10),
          _VisualMetricRow(label: l10n.conceptVisualEfficiency, value: '80%'),
          const SizedBox(height: 10),
          const _MiniProgressBar(value: 0.8),
          const SizedBox(height: 10),
          _VisualMetricRow(
            label: l10n.conceptVisualEffectiveFocus,
            value: '48m',
          ),
        ],
      ),
    );
  }
}

class _ConceptAnalyticsVisual extends StatelessWidget {
  const _ConceptAnalyticsVisual({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ConceptVisualFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VisualMetricRow(label: l10n.conceptVisualPlanTime, value: '80h'),
          const SizedBox(height: 10),
          _VisualMetricRow(
            label: l10n.conceptVisualEffectiveFocus,
            value: '92h',
          ),
          const SizedBox(height: 10),
          const _OverflowProgressBar(),
          const SizedBox(height: 10),
          _VisualMetricRow(
            label: l10n.conceptVisualTimeProgress,
            value: '115%',
          ),
        ],
      ),
    );
  }
}

class _VisualHeader extends StatelessWidget {
  const _VisualHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _VisualMetricRow extends StatelessWidget {
  const _VisualMetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _VisualTreeRow extends StatelessWidget {
  const _VisualTreeRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.11),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _VisualTreeLine extends StatelessWidget {
  const _VisualTreeLine();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 1,
          height: 12,
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            size: 17,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  const _MiniProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _OverflowProgressBar extends StatelessWidget {
  const _OverflowProgressBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 6,
        child: Row(
          children: [
            Expanded(
              flex: 87,
              child: DecoratedBox(
                decoration: BoxDecoration(color: theme.colorScheme.primary),
              ),
            ),
            Expanded(
              flex: 13,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      const Color(0xFFF57C00),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConceptActionCard extends StatelessWidget {
  const _ConceptActionCard({required this.onOpenGoals});

  final VoidCallback onOpenGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.conceptActionTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.conceptActionBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenGoals,
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: Text(l10n.conceptOpenGoalsAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
