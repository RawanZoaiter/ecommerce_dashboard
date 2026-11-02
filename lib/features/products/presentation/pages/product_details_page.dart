import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/product_thumbnail.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../cubit/product_details_cubit.dart';
import '../widgets/availability_badge.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductDetailsCubit(sl<ProductRepository>(), productId)..load(),
      child: const _ProductDetailsView(),
    );
  }
}

class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            _BackLink(label: context.l10n.productsTitle),
            const SizedBox(height: AppSpacing.lg),
            switch (state.status) {
              ProductDetailsStatus.failure => ErrorStateView(
                failure: state.failure!,
                onRetry: context.read<ProductDetailsCubit>().load,
              ),
              ProductDetailsStatus.initial ||
              ProductDetailsStatus.loading => const _DetailsSkeleton(),
              ProductDetailsStatus.loaded => _Details(product: state.product!),
            },
          ],
        );
      },
    );
  }
}

class _BackLink extends StatelessWidget {
  const _BackLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: () => context.go(Routes.products),
        icon: Icon(
          context.isRtl ? Icons.arrow_forward : Icons.arrow_back,
          size: 16,
        ),
        label: Text(label),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final image = AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: AspectRatio(
        aspectRatio: 1,
        child: ProductThumbnail(
          imageUrl: product.imageUrl,
          name: product.name,
          size: double.infinity,
          radius: AppRadius.md,
        ),
      ),
    );

    final info = _Info(product: product);

    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          image,
          const SizedBox(height: AppSpacing.xl),
          info,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 320, child: image),
        const SizedBox(width: AppSpacing.xl),
        Expanded(child: info),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(product.name, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text(product.category.name),
                backgroundColor: context.colors.secondaryContainer,
                visualDensity: VisualDensity.compact,
              ),
              AvailabilityBadge(availability: product.availability),
            ],
          ),
          AvailabilityHint(availability: product.availability),
          const SizedBox(height: AppSpacing.xl),
          Text(
            product.price.format(locale: context.localeName),
            style: context.text.displaySmall?.copyWith(
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Divider(),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.productDetailsDescription, style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            product.description,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          if (product.createdAt != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 15,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm - 2),
                Text(
                  '${l10n.commonCreatedAt}: '
                  '${DateFormatter.dateTime(product.createdAt!, context.localeName)}',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 240, height: 24),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(width: 140),
          SizedBox(height: AppSpacing.xxl),
          SkeletonBox(width: 180, height: 32),
          SizedBox(height: AppSpacing.xxl),
          SkeletonBox(height: 12),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(height: 12),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 220, height: 12),
        ],
      ),
    );
  }
}
