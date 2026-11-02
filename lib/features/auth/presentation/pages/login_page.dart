import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(sl<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) =>
            current.status == LoginStatus.success,
        listener: (context, state) {
          final user = state.user;
          // The router redirects on its own once the session lands, so there
          // is no navigation to do here.
          if (user != null) context.read<AuthCubit>().onSignedIn(user);
        },
        child: Row(
          children: [
            // The brand panel is decoration, so it is the first thing dropped
            // when the window cannot afford it.
            if (context.isExpanded) const Expanded(child: _BrandPanel()),
            const Expanded(child: _LoginForm()),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            context.colors.primary,
            Color.lerp(context.colors.primary, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.giant),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.colors.onPrimary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                Icons.storefront,
                size: 27,
                color: context.colors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              context.l10n.appTitle,
              style: context.text.displaySmall?.copyWith(
                color: context.colors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                context.l10n.loginSubtitle,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onPrimary.withValues(alpha: 0.82),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().submit(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Align(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: context.read<SettingsCubit>().toggleLocale,
                    child: Text(
                      context.watch<SettingsCubit>().state.isArabic
                          ? l10n.prefsLanguageEnglish
                          : l10n.prefsLanguageArabic,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.loginTitle, style: context.text.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.loginSubtitle,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const _LoginError(),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.loginEmail,
                    hintText: l10n.loginEmailHint,
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.email(value, l10n),
                  onChanged: (_) => context.read<LoginCubit>().clearError(),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.loginPassword,
                    hintText: l10n.loginPasswordHint,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? l10n.loginShowPassword
                          : l10n.loginHidePassword,
                      onPressed: () => setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.password(value, l10n),
                  onChanged: (_) => context.read<LoginCubit>().clearError(),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.xxl),
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) => FilledButton(
                    onPressed: state.isSubmitting ? null : _submit,
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.loginSubmit),
                  ),
                ),
                if (AppConfig.usesMockData) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  InfoBanner(
                    message:
                        '${l10n.mockBannerMessageAll}\n'
                        'admin@example.com · 123456789',
                    icon: Icons.science_outlined,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The failure message above the fields.
///
/// A wrong password is reported here rather than under a single field,
/// because the API deliberately does not say which of the two was wrong.
class _LoginError extends StatelessWidget {
  const _LoginError();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        if (state.status != LoginStatus.failure) {
          return const SizedBox.shrink();
        }

        final l10n = context.l10n;
        final message = state.notAdmin
            ? l10n.loginErrorNotAdmin
            : switch (state.failure) {
                UnauthenticatedFailure() => l10n.loginErrorInvalidCredentials,
                ThrottledFailure(:final retryAfter) => l10n.loginErrorThrottled(
                  retryAfter.inSeconds,
                ),
                NetworkFailure() => l10n.errorNetwork,
                ValidationFailure() => l10n.errorGeneric,
                _ => l10n.errorGeneric,
              };

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: InfoBanner(message: message, tone: BannerTone.danger),
        );
      },
    );
  }
}
