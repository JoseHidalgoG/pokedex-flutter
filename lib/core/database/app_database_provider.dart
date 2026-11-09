import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.onDevice();
  ref.onDispose(database.close);
  return database;
});
