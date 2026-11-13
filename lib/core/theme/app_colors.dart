import 'package:material_ui/material_ui.dart';

/// UI 2.0 semantic palette. Bank-card materials intentionally remain independent.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF26282B);
  static const scaffoldBackground = Color(0xFFF7F7F7);
  static const cardBackground = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF26282B);
  static const textSecondary = Color(0xFF66686C);
  static const textLight = Color(0xFF85888D);
  static const border = Color(0xFFDEDEDE);
  static const divider = border;
  static const success = Color(0xFF277045);
  static const error = Color(0xFFCF242C);
  static const warning = Color(0xFFE3A35C);
  static const info = Color(0xFF0066D6);

  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color field(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;
  static Color ink(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  static Color line(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;
  static Color focus(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  static Color trend(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;
  static Color income(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF8BD6A6)
      : success;
  static Color expense(BuildContext context) =>
      Theme.of(context).colorScheme.error;
}
