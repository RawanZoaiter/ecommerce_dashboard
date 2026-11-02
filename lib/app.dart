import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'l10n/generated/app_localizations.dart';

class EcommerceDashboardApp extends StatelessWidget {
  const EcommerceDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(
          create: (_) => AuthCubit(sl<AuthRepository>())..restoreSession(),
        ),
        BlocProvider(
          create: (_) =>
              NotificationsCubit(sl<NotificationRepository>())..load(),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  /// Built once. Recreating the router on every rebuild would reset the
  /// navigation stack whenever the theme or language changes.
  late final GoRouter _router = createRouter(context.read<AuthCubit>());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          routerConfig: _router,
          locale: settings.locale,
          supportedLocales: SettingsCubit.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // The font differs per language, so the theme is rebuilt with the
          // locale rather than being a constant.
          theme: AppTheme.light(arabic: settings.isArabic),
          darkTheme: AppTheme.dark(arabic: settings.isArabic),
          themeMode: settings.themeMode,
        );
      },
    );
  }
}
