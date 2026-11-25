import 'package:drift/drift.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/preferences/domain/preferences_store.dart';
import 'package:pokedex_flutter/features/settings/data/local/user_preferences_table.dart';

part 'user_preferences_dao.g.dart';

@DriftAccessor(tables: [UserPreferencesTable])
class UserPreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$UserPreferencesDaoMixin
    implements PreferencesStore {
  UserPreferencesDao(super.db);

  @override
  Future<String?> getPreference(String key) async {
    final row = await (select(
      userPreferencesTable,
    )..where((table) => table.key.equals(key))).getSingleOrNull();

    return row?.value;
  }

  @override
  Stream<String?> watchPreference(String key) {
    final query = select(userPreferencesTable)
      ..where((table) => table.key.equals(key));

    return query.watchSingleOrNull().map((row) => row?.value);
  }

  @override
  Future<void> setPreference(String key, String value) async {
    await into(userPreferencesTable).insertOnConflictUpdate(
      UserPreferencesTableCompanion.insert(key: key, value: value),
    );
  }

  @override
  Future<void> deletePreference(String key) async {
    await (delete(
      userPreferencesTable,
    )..where((table) => table.key.equals(key))).go();
  }
}
