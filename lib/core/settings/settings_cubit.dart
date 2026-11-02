import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.locale = const Locale('ar'),
    this.themeMode = ThemeMode.system,
  });

  final Locale locale;
  final ThemeMode themeMode;

  bool get isArabic => locale.languageCode == 'ar';

  SettingsState copyWith({Locale? locale, ThemeMode? themeMode}) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode];
}

/// Language and theme for the whole app.
///
/// Kept in memory for now: the choice lasts the session but not a reload.
/// Persisting it needs a key-value store the project does not have yet, and
/// storing a UI preference in the secure token store would be a misuse of it.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const supportedLocales = [Locale('ar'), Locale('en')];

  void setLocale(Locale locale) => emit(state.copyWith(locale: locale));

  void toggleLocale() {
    emit(
      state.copyWith(
        locale: state.isArabic ? const Locale('en') : const Locale('ar'),
      ),
    );
  }

  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));

  void toggleThemeMode() {
    emit(
      state.copyWith(
        themeMode: state.themeMode == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark,
      ),
    );
  }
}
