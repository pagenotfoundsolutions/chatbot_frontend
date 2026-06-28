import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final storedVal = prefs.getString(AppConstants.themeModeKey);
    if (storedVal == 'light') return ThemeMode.light;
    if (storedVal == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void toggleTheme() {
    ThemeMode nextMode;
    // For simplicity, we toggle Light -> Dark -> System -> Light
    // or just Light <-> Dark. Let's do Light <-> Dark for chat UI simplicity.
    if (state == ThemeMode.light || state == ThemeMode.system) {
      nextMode = ThemeMode.dark;
    } else {
      nextMode = ThemeMode.light;
    }
    _setTheme(nextMode);
  }

  void setTheme(ThemeMode mode) => _setTheme(mode);

  Future<void> _setTheme(ThemeMode mode) async {
    await _prefs.setString(AppConstants.themeModeKey, mode.name);
    emit(mode);
  }
}
