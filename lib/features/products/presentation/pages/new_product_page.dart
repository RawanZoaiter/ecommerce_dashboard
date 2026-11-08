import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import '../cubit/new_product_cubit.dart';
import '../widgets/image_drop_zone.dart';

class NewProductPage extends StatelessWidget {
  const NewProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewProductCubit(sl<ProductRepository>())..loadCategories(),
      child: const _NewProductView(),
    );
  }
}

class _NewProductView extends StatefulWidget {
  const _NewProductView();

  @override
  State<_NewProductView> createState() => _NewProductViewState();
}

class _NewProductViewState extends State<_NewProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  int? _categoryId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: NewProductCubit.allowedExtensions,
    );

    final file = files.firstOrNull;
    if (file == null) return;

    // On web there is no file path to upload from, so the bytes themselves are
    // what the multipart request will carry.
    final bytes = await file.readAsBytes();
    if (!mounted) return;

    context.read<NewProductCubit>().pickImage(
      bytes: bytes,
      fileName: file.name,
    );
  }

  void _submit() {
    final cubit = context.read<NewProductCubit>();
    final isFormValid = _formKey.currentState!.validate();

    // The image lives in the cubit, not the form, so both have to pass before
    // anything is sent.
    if (!isFormValid || !cubit.state.hasImage || _categoryId == null) {
      setState(() {}); // Surfaces the image and category messages.
      return;
    }

    cubit.submit(
      name: _nameController.text,
      description: _descriptionController.text,
      price: _priceController.text,
      categoryId: _categoryId!,
      initialQuantity: int.parse(_quantityController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<NewProductCubit, NewProductState>(
      listenWhen: (previous, current) =>
          current.status == NewProductStatus.success,
      listener: (context, state) {
        context
          ..showSnack(l10n.productFormSuccess)
          ..go(Routes.products);
      },
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => context.go(Routes.products),
                icon: Icon(
                  context.isRtl ? Icons.arrow_forward : Icons.arrow_back,
                  size: 16,
                ),
                label: Text(l10n.productsTitle),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PageHeader(
              title: l10n.productFormTitle,
              subtitle: l10n.productFormSubtitle,
            ),
            const SizedBox(height: AppSpacing.xl),

            if (state.status == NewProductStatus.failure &&
                state.fieldErrors.isEmpty) ...[
              InfoBanner(message: l10n.errorGeneric, tone: BannerTone.danger),
              const SizedBox(height: AppSpacing.xl),
            ],

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Form(
                key: _formKey,
                // Same reason as the login form: without this, a message from
                // one failed attempt stays under a field the user has since
                // fixed.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: _FormBody(
                  state: state,
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  priceController: _priceController,
                  quantityController: _quantityController,
                  categoryId: _categoryId,
                  onCategoryChanged: (value) =>
                      setState(() => _categoryId = value),
                  onPickImage: _pickImage,
                  onSubmit: _submit,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.state,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.quantityController,
    required this.categoryId,
    required this.onCategoryChanged,
    required this.onPickImage,
    required this.onSubmit,
  });

  final NewProductState state;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final int? categoryId;
  final ValueChanged<int?> onCategoryChanged;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;

  /// Server-side message for a field, which wins over the local rule because
  /// the server is the authority (guide §3).
  String? _serverError(String field) => state.fieldErrors[field]?.firstOrNull;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          title: l10n.productFormImage,
          subtitle: l10n.productFormImageRules,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ImageDropZone(
              bytes: state.imageBytes,
              fileName: state.imageFileName,
              rejection: state.imageRejection,
              onPick: onPickImage,
              onRemove: context.read<NewProductCubit>().removeImage,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.productFormName,
                  hintText: l10n.productFormNameHint,
                  errorText: _serverError('name'),
                ),
                maxLength: 255,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.productName(value, l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.productFormDescription,
                  hintText: l10n.productFormDescriptionHint,
                  errorText: _serverError('description'),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 5000,
                validator: (value) =>
                    Validators.productDescription(value, l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: l10n.productFormPrice,
                        hintText: l10n.productFormPriceHint,
                        errorText: _serverError('price'),
                        prefixIcon: const Icon(Icons.attach_money, size: 20),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => Validators.price(value, l10n),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: categoryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.productFormCategory,
                        hintText: l10n.productFormCategoryHint,
                        errorText:
                            _serverError('category_id') ??
                            (categoryId == null && state.fieldErrors.isNotEmpty
                                ? l10n.productFormErrorCategory
                                : null),
                      ),
                      items: [
                        for (final Category category in state.categories)
                          DropdownMenuItem(
                            value: category.id,
                            child: Text(
                              category.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: onCategoryChanged,
                      validator: (value) =>
                          value == null ? l10n.productFormErrorCategory : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: l10n.productFormQuantity,
                  hintText: l10n.productFormQuantityHint,
                  helperText: l10n.productFormQuantityHelp,
                  errorText: _serverError('initial_quantity'),
                  prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
                ),
                keyboardType: TextInputType.number,
                // Digits only: the server takes a whole number, and letting a
                // decimal point in only earns a 422 after the upload.
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return l10n.productFormErrorQuantity;
                  final parsed = int.tryParse(text);
                  if (parsed == null || parsed < 0) {
                    return l10n.productFormErrorQuantityInvalid;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => context.go(Routes.products),
              child: Text(l10n.actionCancel),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.icon(
              onPressed: state.isSubmitting ? null : onSubmit,
              icon: state.isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add, size: 18),
              label: Text(l10n.productFormSubmit),
            ),
          ],
        ),
      ],
    );
  }
}
