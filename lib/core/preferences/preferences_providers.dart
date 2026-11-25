import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/preferences/domain/preferences_store.dart';

final preferencesStoreProvider = Provider<PreferencesStore>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return database.userPreferencesDao;
});
