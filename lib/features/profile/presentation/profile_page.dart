import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/profile/application/profile_dashboard_provider.dart';
import 'package:aimgo/features/goals/presentation/widgets/time_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncData = ref.watch(profileDashboardProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(l10n.profileTitle),
              ),
            ],
        body: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Text(error.toString(), textAlign: TextAlign.center),
              ),
          data:
              (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(profileDashboardProvider);
                  await ref.read(profileDashboardProvider.future);
                },
                child: ListView(
                  padding: LayoutTokens.listPagePadding,
                  children: [
                    _ProfileHeroCard(
                      name: l10n.profileDefaultName,
                      signature: l10n.profileWelcome,
                      streakDays: data.streakDays,
                      activeGoalCount: data.activeGoalCount,
                      onTap: () => context.go(RoutePaths.goals),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),
                    _ProfileSummaryCard(data: data),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),
                    _ProfileSection(
                      title: l10n.profileSectionQuickAccess,
                      child: _ProfileGroupCard(
                        children: [
                          _ProfileNavRow(
                            icon: Icons.history,
                            title: l10n.historyTitle,
                            onTap: () => context.push(RoutePaths.history),
                          ),
                          _ProfileNavRow(
                            icon: Icons.analytics_outlined,
                            title: l10n.profileAnalytics,
                            onTap: () => context.push(RoutePaths.analytics),
                          ),
                          _ProfileNavRow(
                            icon: Icons.alt_route,
                            title: l10n.goalsMilestoneProgress,
                            onTap: () => context.push(RoutePaths.goalMilestones),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),
                    _ProfileSection(
                      title: l10n.profileSectionData,
                      child: _ProfileGroupCard(
                        children: [
                          _ProfileNavRow(
                            icon: Icons.flag_outlined,
                            title: l10n.profileActiveGoals(''),
                            value: data.activeGoalCount.toString(),
                            onTap: () => context.go(RoutePaths.goals),
                          ),
                          _ProfileNavRow(
                            icon: Icons.checklist_outlined,
                            title: l10n.profilePendingItems,
                            value:
                                data.pendingTaskCount == 0
                                    ? l10n.profilePendingNone
                                    : data.pendingTaskCount.toString(),
                            onTap: () => context.go(RoutePaths.goals),
                          ),
                          _ProfileNavRow(
                            icon: Icons.local_fire_department_outlined,
                            title: l10n.profileStreakDays(''),
                            value: data.streakDays.toString(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),
                    _ProfileSection(
                      title: l10n.profileSectionPreferences,
                      child: _ProfileGroupCard(
                        children: [
                          _ProfileNavRow(
                            icon: Icons.settings_outlined,
                            title: l10n.settingsTitle,
                            onTap: () => context.push(RoutePaths.settings),
                          ),
                          _ProfileNavRow(
                            icon: Icons.shield_outlined,
                            title: l10n.settingsBackupRestore,
                            onTap: () => context.push(RoutePaths.settings),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),
                    _ProfileSection(
                      title: l10n.profileSectionAbout,
                      child: _ProfileGroupCard(
                        children: [
                          _ProfileNavRow(
                            icon: Icons.info_outline,
                            title: l10n.profileAbout,
                            onTap: () => context.push(RoutePaths.about),
                          ),
                          _ProfileNavRow(
                            icon: Icons.tag_outlined,
                            title: l10n.profileVersionLabel,
                            value: l10n.aboutVersion,
                          ),
                        ],
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

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.name,
    required this.signature,
    required this.streakDays,
    required this.activeGoalCount,
    required this.onTap,
  });

  final String name;
  final String signature;
  final int streakDays;
  final int activeGoalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LayoutTokens.radiusCard),
        child: DecoratedBox(
          decoration: LayoutTokens.tainCardDecoration(theme),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            signature,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.52,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroMetaChip(
                      icon: Icons.local_fire_department_outlined,
                      label: '$streakDays',
                    ),
                    _HeroMetaChip(
                      icon: Icons.flag_outlined,
                      label: '$activeGoalCount',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroMetaChip extends StatelessWidget {
  const _HeroMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.data});

  final ProfileDashboardData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final secondaryLabelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final estimatedCompletionDays =
        data.totalEstimateMinutes > 0
            ? (data.totalEstimateMinutes / 120).ceil().clamp(1, 999)
            : 0;
    final hasEstimate = data.totalEstimateMinutes > 0;
    final progressRatio =
        hasEstimate ? data.focusDurationMinutes / data.totalEstimateMinutes : 0.0;
    final progressPercent = hasEstimate ? (progressRatio * 100).round() : 0;

    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatMinutes(data.focusDurationMinutes),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.profileOverviewMilestonesDone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hasEstimate ? formatMinutes(data.totalEstimateMinutes) : '--',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            hasEstimate
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.profileOverviewWeekFocus,
                      style: secondaryLabelStyle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  hasEstimate ? '$progressPercent%' : '--',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                hasEstimate
                    ? Text.rich(
                      TextSpan(
                        style: secondaryLabelStyle,
                        children: [
                          const TextSpan(text: '预计仍需'),
                          TextSpan(
                            text: estimatedCompletionDays.toString(),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: '天'),
                        ],
                      ),
                    )
                    : Text(
                      '--',
                      style: secondaryLabelStyle,
                    )
              ],
            ),
            const SizedBox(height: 10),
            TimeProgressBar(progressRatio: progressRatio),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ProfileGroupCard extends StatelessWidget {
  const _ProfileGroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: LayoutTokens.tainCardDecoration(theme),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.24),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileNavRow extends StatelessWidget {
  const _ProfileNavRow({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.76),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                value!,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.42),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(LayoutTokens.radiusCard),
      onTap: onTap,
      child: content,
    );
  }
}
