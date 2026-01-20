import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  const SettingsState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({bool? isDarkMode, bool? notificationsEnabled}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final notif = prefs.getBool('notificationsEnabled') ?? true;
    state = state.copyWith(isDarkMode: isDark, notificationsEnabled: notif);
  }

  Future<void> toggleDarkMode() async {
    final newVal = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newVal);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newVal);
  }

  Future<void> toggleNotifications() async {
    final newVal = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: newVal);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', newVal);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
