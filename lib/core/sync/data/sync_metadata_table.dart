import 'package:drift/drift.dart';

@DataClassName('SyncMetadataRow')
class SyncMetadataTable extends Table {
  @override
  String get tableName => 'sync_metadata';

  TextColumn get key => text()();
  IntColumn get nextOffset => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().nullable()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('idle'))();
  IntColumn get attempt => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();
  TextColumn get lastErrorKind => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
