import 'package:aimgo/app/l10n/generated/app_localizations.dart';
import 'package:aimgo/app/router/route_paths.dart';
import 'package:aimgo/core/constants/layout_tokens.dart';
import 'package:aimgo/core/utils/time_formatter.dart';
import 'package:aimgo/features/profile/application/profile_dashboard_provider.dart';
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
                    // ── Identity card ──
                    _IdentityCard(
                      name: l10n.profileDefaultName,
                      signature: l10n.profileWelcome,
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),

                    // ── Profile info rows (like Tain's 我的目标 / 高级版) ──
                    _ProfileCard(
                      children: [
                        _ProfileNavRow(
                          icon: Icons.flag_outlined,
                          title: l10n.profileActiveGoals(''),
                          value: data.activeGoalCount.toString(),
                          onTap: () => context.go(RoutePaths.goals),
                        ),
                        _ProfileNavRow(
                          icon: Icons.local_fire_department_outlined,
                          title: l10n.profileStreakDays(''),
                          value: data.streakDays.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),

                    // ── Overview strip ──
                    _OverviewStrip(
                      items: [
                        _OverviewItem(
                          title: l10n.profileOverviewWeekFocus,
                          value: formatMinutes(data.totalEstimateMinutes),
                        ),
                        _OverviewItem(
                          title: l10n.profileOverviewTasksDone,
                          value: data.focusSessionCount.toString(),
                        ),
                        _OverviewItem(
                          title: l10n.profileOverviewMilestonesDone,
                          value: formatMinutes(data.focusDurationMinutes),
                        ),
                      ],
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),

                    // ── Quick access section ──
                    _ProfileSection(
                      title: l10n.profileSectionQuickAccess,
                      child: _ProfileCard(
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
                            onTap:
                                () =>
                                    context.push(RoutePaths.goalMilestones),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),

                    // ── Data section ──
                    _ProfileSection(
                      title: l10n.profileSectionData,
                      child: _ProfileCard(
                        children: [
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
                            icon: Icons.shield_outlined,
                            title: l10n.settingsBackupRestore,
                            onTap: () => context.push(RoutePaths.settings),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),

                    // ── Settings & About section ──
                    _ProfileSection(
                      title: l10n.profileSectionPreferences,
                      child: _ProfileCard(
                        children: [
                          _ProfileNavRow(
                            icon: Icons.settings_outlined,
                            title: l10n.settingsTitle,
                            onTap: () => context.push(RoutePaths.settings),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LayoutTokens.sectionGapLarge),

                    // ── About section ──
                    _ProfileSection(
                      title: l10n.profileSectionAbout,
                      child: _ProfileCard(
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

// ---------------------------------------------------------------------------
// Identity card — avatar left, name + signature right (Tain style)
// ---------------------------------------------------------------------------

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.name, required this.signature});

  final String name;
  final String signature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 30,
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
                    style: theme.textTheme.titleMedium?.copyWith(
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
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// White card group (same style as settings page)
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.28),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title (small gray label above card)
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Nav row: icon + label + value + chevron (Tain style)
// ---------------------------------------------------------------------------

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium,
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
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: content,
    );
  }
}

// ---------------------------------------------------------------------------
// Overview strip — 3-column metrics
// ---------------------------------------------------------------------------

class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({required this.items});

  final List<_OverviewItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    Text(
                      items[i].value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (i != items.length - 1)
                Container(
                  width: 1,
                  height: 28,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.35,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverviewItem {
  const _OverviewItem({required this.title, required this.value});

  final String title;
  final String value;
}
