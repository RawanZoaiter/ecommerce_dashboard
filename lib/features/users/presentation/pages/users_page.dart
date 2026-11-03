import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_paginator.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../cubit/users_cubit.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsersCubit(sl<UserRepository>())..fetch(),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatelessWidget {
  const _UsersView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        final cubit = context.read<UsersCubit>();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            PageHeader(title: l10n.usersTitle, subtitle: l10n.usersSubtitle),
            const SizedBox(height: AppSpacing.xl),

            // Waiting on GET /users: the guide names Users as one of the four
            // modules but documents only register, login and user-info.
            InfoBanner(
              message: l10n.mockBannerMessage,
              tone: BannerTone.warning,
              icon: Icons.construction_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),

            AppCard(
              clipBody: true,
              padding: EdgeInsets.zero,
              child: switch (state.status) {
                UsersStatus.failure => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ErrorStateView(
                    failure: state.failure!,
                    onRetry: cubit.fetch,
                  ),
                ),
                UsersStatus.initial ||
                UsersStatus.loading => const TableSkeleton(columns: 4),
                UsersStatus.loaded when state.page.isEmpty => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: EmptyStateView(
                    title: l10n.emptyTitle,
                    message: l10n.emptyMessage,
                    icon: Icons.people_outline,
                  ),
                ),
                UsersStatus.loaded => Column(
                  children: [
                    _UsersTable(users: state.page.items),
                    const Divider(),
                    AppPaginator(
                      meta: state.page.meta,
                      onPageChanged: (page) => cubit.fetch(page: page),
                    ),
                  ],
                ),
              },
            ),
          ],
        );
      },
    );
  }
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppTable(
      minWidth: 640,
      columns: [
        AppTableColumn(label: l10n.usersColumnName, flex: 3),
        AppTableColumn(label: l10n.usersColumnEmail, flex: 3),
        AppTableColumn(label: l10n.usersColumnRole, width: 140),
        AppTableColumn(label: l10n.usersColumnJoined, flex: 2),
      ],
      rows: [
        for (final user in users)
          AppTableRow(
            cells: [
              Row(
                children: [
                  UserAvatar(
                    initials: user.initials,
                    seed: user.email,
                    size: 30,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      user.name,
                      style: context.text.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                user.email,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              _RoleChip(role: user.role),
              Text(
                user.createdAt == null
                    ? '—'
                    : DateFormatter.date(user.createdAt!, context.localeName),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.isAdmin;
    final color = isAdmin
        ? context.colors.primary
        : context.colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        isAdmin
            ? context.l10n.accountRoleAdmin
            : context.l10n.accountRoleCustomer,
        style: context.text.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
