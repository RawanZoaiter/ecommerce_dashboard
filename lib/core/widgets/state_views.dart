import 'package:flutter/material.dart';

import '../error/failure.dart';
import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// Shown when a request succeeded and simply returned nothing.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      icon: icon,
      iconColor: context.colors.onSurfaceVariant,
      iconBackground: context.semantic.surfaceSunken,
      title: title,
      message: message,
      action: action,
    );
  }
}

/// Shown when a request failed. Renders localized copy chosen from the typed
/// [Failure]; the API's English `message` is never shown to the user.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final (title, message) = switch (failure) {
      NetworkFailure() => (l10n.errorTitle, l10n.errorNetwork),
      TimeoutFailure() => (l10n.errorTitle, l10n.errorTimeout),
      UnauthenticatedFailure() => (l10n.errorTitle, l10n.errorUnauthenticated),
      ForbiddenFailure() => (l10n.errorTitle, l10n.errorForbidden),
      NotFoundFailure() => (l10n.errorNotFound, l10n.emptyNoResultsMessage),
      ValidationFailure() => (l10n.errorTitle, l10n.errorGeneric),
      ThrottledFailure(:final retryAfter) => (
        l10n.errorTitle,
        l10n.loginErrorThrottled(retryAfter.inSeconds),
      ),
      StatusTransitionFailure() => (
        l10n.orderActionFinalTitle,
        l10n.orderActionFinalMessage,
      ),
      InsufficientStockFailure() => (
        l10n.orderErrorInsufficientTitle,
        l10n.orderErrorInsufficientMessage,
      ),
      ProductsUnavailableFailure() => (
        l10n.orderErrorUnavailableTitle,
        l10n.orderErrorUnavailableMessage,
      ),
      InventoryConflictFailure() => (
        l10n.errorTitle,
        l10n.errorInventoryConflict,
      ),
      InventoryUnavailableFailure() => (
        l10n.orderErrorInventoryDownTitle,
        l10n.orderErrorInventoryDownMessage,
      ),
      ServerFailure() ||
      UnknownFailure() => (l10n.errorTitle, l10n.errorGeneric),
    };

    return _CenteredMessage(
      icon: Icons.error_outline,
      iconColor: context.semantic.danger,
      iconBackground: context.semantic.dangerContainer,
      title: title,
      message: message,
      // The backend team asks for X-Request-ID when reporting a problem, so it
      // is shown rather than only logged.
      footnote: failure.requestId == null
          ? null
          : 'X-Request-ID: ${failure.requestId}',
      action: onRetry == null
          ? null
          : FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.actionRetry),
            ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    this.footnote,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final String? footnote;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: context.text.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (footnote != null) ...[
                const SizedBox(height: AppSpacing.md),
                SelectableText(
                  footnote!,
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
