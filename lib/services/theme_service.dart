import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeService extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.integra;

  AppThemeMode get mode => _mode;
  ThemeData get theme => AppTheme.getTheme(_mode);

  void setTheme(AppThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  String get nombreTema {
    switch (_mode) {
      case AppThemeMode.oscuro:
        return 'Oscuro';
      case AppThemeMode.integra:
      default:
        return 'Integra';
    }
  }
}