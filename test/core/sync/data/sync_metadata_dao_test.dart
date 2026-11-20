import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/data/sync_metadata_dao.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';

void main() {
  late AppDatabase database;
  late SyncMetadataDao syncMetadataDao;
  const key = CatalogDao.catalogSyncKey;
  final retryAt = DateTime(2026, 11, 20, 10, 0, 8);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    syncMetadataDao = database.syncMetadataDao;
  });

  tearDown(() => database.close());

  Future<SyncMetadataRow> savedRow() async =>
      (await syncMetadataDao.readByKey(key))!;

  test('marca in_progress al empezar', () async {
    await syncMetadataDao.recordStarted(key);

    expect((await savedRow()).status, 'in_progress');
  });

  test(
    'guarda el reintento con su número, su hora y el tipo de fallo',
    () async {
      await syncMetadataDao.recordWaitingRetry(
        key,
        attempt: 3,
        retryAt: retryAt,
        failure: const ServerError(503),
      );
      final row = await savedRow();

      expect(row.status, 'waiting_retry');
      expect(row.attempt, 3);
      expect(row.nextRetryAt, retryAt);
      expect(row.lastErrorKind, 'server_error');
      expect(row.lastError, 'ServerError(503)');
    },
  );

  test('guarda hasta cuándo queda en pausa por presupuesto', () async {
    await syncMetadataDao.recordPaused(key, until: retryAt);
    final row = await savedRow();

    expect(row.status, 'paused');
    expect(row.nextRetryAt, retryAt);
  });

  test('pending guarda el tipo de fallo sin hora de reintento', () async {
    await syncMetadataDao.recordWaitingRetry(
      key,
      attempt: 1,
      retryAt: retryAt,
      failure: const RequestTimeout(),
    );

    await syncMetadataDao.recordPending(key, failure: const NoConnection());
    final row = await savedRow();

    expect(row.status, 'pending');
    expect(row.nextRetryAt, isNull);
    expect(row.lastErrorKind, 'no_connection');
  });

  test('failed guarda el último reintento y el fallo', () async {
    await syncMetadataDao.recordFailed(
      key,
      attempt: 5,
      failure: const InvalidResponse(),
    );
    final row = await savedRow();

    expect(row.status, 'failed');
    expect(row.attempt, 5);
    expect(row.lastErrorKind, 'invalid_response');
  });

  test('al terminar bien vuelve a idle y borra reintento y error', () async {
    await syncMetadataDao.recordWaitingRetry(
      key,
      attempt: 2,
      retryAt: retryAt,
      failure: const ServerError(502),
    );

    await syncMetadataDao.recordSucceeded(key);
    final row = await savedRow();

    expect(row.status, 'idle');
    expect(row.attempt, 0);
    expect(row.nextRetryAt, isNull);
    expect(row.lastErrorKind, isNull);
    expect(row.lastError, isNull);
  });

  test('no toca el progreso del catálogo ni sus Pokémon', () async {
    await database.catalogDao.saveCatalogPage(
      entries: const [
        CatalogEntry(
          id: 25,
          name: 'pikachu',
          imageUrl: 'https://example.com/25.png',
          typeNames: ['electric'],
        ),
      ],
      nextOffset: 100,
      isComplete: false,
      savedAt: DateTime(2026, 11, 20, 9),
      totalCount: 1025,
    );

    await syncMetadataDao.recordFailed(
      key,
      attempt: 5,
      failure: const ServerError(503),
    );
    final row = await savedRow();
    final pokemon = await database.select(database.pokemonTable).get();

    expect(row.nextOffset, 100);
    expect(row.totalCount, 1025);
    expect(row.isComplete, isFalse);
    expect(pokemon, hasLength(1));
  });
}
