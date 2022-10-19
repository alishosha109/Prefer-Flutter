part of 'theme_cubit.dart';

@immutable
abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeChanged extends ThemeState {
  final ThemeMode themeMode;
  ThemeChanged(this.themeMode);
}

class ChangeLocaleState extends ThemeState {
  final Locale locale;
  ChangeLocaleState({
    required this.locale,
  });
}
