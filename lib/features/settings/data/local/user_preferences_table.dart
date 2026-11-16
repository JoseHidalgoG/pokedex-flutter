import 'package:drift/drift.dart';

@DataClassName('UserPreferenceRow')
class UserPreferencesTable extends Table {
  @override
  String get tableName => 'user_preferences';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
