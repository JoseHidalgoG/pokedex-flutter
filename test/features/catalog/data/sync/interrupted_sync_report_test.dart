import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/interrupted_sync_report.dart';

SyncMetadataRow interruptedRow(
  String key, {
  int nextOffset = 0,
  int? totalCount,
  bool isComplete = false,
}) {
  return SyncMetadataRow(
    key: key,
    nextOffset: nextOffset,
    totalCount: totalCount,
    isComplete: isComplete,
    status: 'in_progress',
    attempt: 0,
  );
}

void main() {
  group('el mensaje de una sincronización interrumpida', () {
    test('la pasada del catálogo dice dónde se cortó y que se reanuda', () {
      final row = interruptedRow(
        CatalogDao.catalogSyncKey,
        nextOffset: 400,
        totalCount: 1025,
      );

      expect(
        interruptionMessageOf(row),
        'catalog: la pasada anterior se interrumpió en 400 de 1025; '
        'se reanuda',
      );
    });

    test('sin total guardado muestra solo cuántos se guardaron', () {
      final row = interruptedRow(CatalogDao.catalogSyncKey, nextOffset: 100);

      expect(
        interruptionMessageOf(row),
        'catalog: la pasada anterior se interrumpió en 100; se reanuda',
      );
    });

    test('cortada antes del primer lote empieza desde 0', () {
      final row = interruptedRow(CatalogDao.catalogSyncKey);

      expect(
        interruptionMessageOf(row),
        'catalog: la pasada anterior se interrumpió antes de guardar '
        'su primer lote; empieza desde 0',
      );
    });

    test('con el catálogo completo no queda nada por reanudar', () {
      final row = interruptedRow(
        CatalogDao.catalogSyncKey,
        nextOffset: 1025,
        totalCount: 1025,
        isComplete: true,
      );

      expect(
        interruptionMessageOf(row),
        'catalog: la pasada anterior se interrumpió antes de guardar '
        'su primer lote; el catálogo sigue completo',
      );
    });

    test('otra clave dice que se repite con su disparador habitual', () {
      final row = interruptedRow(detailSyncKey(25));

      expect(
        interruptionMessageOf(row),
        'detail:25: la sincronización anterior se interrumpió; '
        'se repite con su disparador habitual',
      );
    });
  });

  group('el informe al arrancar', () {
    late AppDatabase database;
    late List<String> logs;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      logs = [];
    });

    tearDown(() => database.close());

    InterruptedSyncReport reportOver(AppDatabase database) {
      return InterruptedSyncReport(
        syncMetadata: database.syncMetadataDao,
        write: logs.add,
      );
    }

    test(
      'escribe una línea por cada clave interrumpida y las deja pending',
      () async {
        await database.catalogDao.saveCatalogPage(
          entries: const [],
          nextOffset: 400,
          isComplete: false,
          savedAt: DateTime(2026, 11, 26, 9),
          totalCount: 1025,
        );
        await database.syncMetadataDao.recordStarted(CatalogDao.catalogSyncKey);
        await database.syncMetadataDao.recordStarted(detailSyncKey(25));
        await database.syncMetadataDao.recordSucceeded(restorationSyncKey);

        await reportOver(database).reportAtStartup();
        final statuses = {
          for (final row
              in await database.select(database.syncMetadataTable).get())
            row.key: row.status,
        };

        expect(logs, [
          'catalog: la pasada anterior se interrumpió en 400 de 1025; '
              'se reanuda',
          'detail:25: la sincronización anterior se interrumpió; '
              'se repite con su disparador habitual',
        ]);
        expect(statuses, {
          'catalog': 'pending',
          'detail:25': 'pending',
          'catalog:restore': 'idle',
        });
      },
    );

    test('sin claves interrumpidas no escribe nada', () async {
      await database.syncMetadataDao.recordSucceeded(CatalogDao.catalogSyncKey);

      await reportOver(database).reportAtStartup();

      expect(logs, isEmpty);
    });

    test(
      'la misma interrupción no se informa en el siguiente arranque',
      () async {
        await database.syncMetadataDao.recordStarted(detailSyncKey(25));

        await reportOver(database).reportAtStartup();
        await reportOver(database).reportAtStartup();

        expect(logs, hasLength(1));
      },
    );
  });
}
