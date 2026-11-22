import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/features/settings/data/local/user_preferences_dao.dart';
import 'package:pokedex_flutter/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:pokedex_flutter/features/settings/domain/repositories/settings_repository.dart';

final userPreferencesDaoProvider = Provider<UserPreferencesDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return UserPreferencesDao(database);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dao = ref.watch(userPreferencesDaoProvider);
  return SettingsRepositoryImpl(dao);
});

final languageProvider = StreamProvider<String>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchLanguage();
});

final themeProvider = StreamProvider<String>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchTheme();
});

final setLanguageProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.setLanguage;
});

final setThemeProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.setTheme;
});
