import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/local/type_efficacy_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/pokemon_detail_sync_service.dart';

import '../../fakes/poke_api_details.dart';

void main() {
  late AppDatabase database;
  late PokeApiDetails pokeApi;
  late PokemonDetailSyncService service;
  late DateTime now;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    pokeApi = PokeApiDetails();
    now = DateTime(2026, 11, 24, 10);
    service = PokemonDetailSyncService(
      remoteDataSource: pokeApi,
      detailDao: database.pokemonDetailDao,
      catalogDao: database.catalogDao,
      now: () => now,
    );
  });

  tearDown(() => database.close());

  void advance(Duration duration) => now = now.add(duration);

  group('detalle bajo demanda', () {
    test('descarga al abrir, no a los 4 min y otra vez a los 6 min', () async {
      expect(await service.syncDetail(25), SyncOutcome.revalidated);

      advance(const Duration(minutes: 4));
      expect(await service.syncDetail(25), SyncOutcome.upToDate);

      advance(const Duration(minutes: 2));
      expect(await service.syncDetail(25), SyncOutcome.revalidated);

      expect(pokeApi.detailRequests, [25, 25]);
    });

    test('guarda el detalle con la fecha de la descarga', () async {
      await service.syncDetail(25);

      final saved = await database.pokemonDetailDao.readDetail(25);
      expect(saved!.detailSyncedAt, now);
      expect(saved.moveVersionGroup, 'scarlet-violet');
      expect(await database.pokemonDetailDao.readDetailSyncedAt(25), now);
    });

    test('force se salta la ventana de 5 min', () async {
      await service.syncDetail(25);
      advance(const Duration(minutes: 1));

      expect(
        await service.syncDetail(25, force: true),
        SyncOutcome.revalidated,
      );
      expect(pokeApi.detailRequests, [25, 25]);
    });

    test(
      'una huella alterada descarga dentro de la ventana y restaura el dato',
      () async {
        await service.syncDetail(25);
        await database.customStatement(
          "UPDATE pokemon SET name = 'pikachux' WHERE id = 25",
        );
        advance(const Duration(minutes: 1));

        expect(await service.needsDetailDownload(25), isTrue);
        expect(await service.syncDetail(25), SyncOutcome.revalidated);

        expect(pokeApi.detailRequests, [25, 25]);
        final restored = await database.catalogDao.readEntry(25);
        expect(restored!.name, 'pikachu');
      },
    );

    test('needsDetailDownload sigue la misma regla que la descarga', () async {
      expect(await service.needsDetailDownload(25), isTrue);

      await service.syncDetail(25);
      advance(const Duration(minutes: 4));
      expect(await service.needsDetailDownload(25), isFalse);

      advance(const Duration(minutes: 1));
      expect(await service.needsDetailDownload(25), isTrue);
    });

    test('si PokeAPI no tiene ese id no guarda nada', () async {
      expect(await service.syncDetail(99999), SyncOutcome.upToDate);

      expect(pokeApi.detailRequests, [99999]);
      expect(await database.pokemonDetailDao.readDetail(99999), isNull);
      expect(await database.pokemonDetailDao.readDetailSyncedAt(99999), isNull);
    });

    test(
      'detailJob usa la clave del Pokémon, prioridad de usuario y force',
      () {
        final job = service.detailJob(25, force: true);

        expect(job.key, 'detail:25');
        expect(job.priority, CallPriority.user);
        expect(job.runningStatus, isA<SyncRevalidating>());
        expect(job.force, isTrue);
      },
    );
  });

  group('tabla de tipos', () {
    Future<int> storedTypeRows() async {
      return (await database.pokemonDetailDao.watchTypeEfficacy().first).length;
    }

    test('si falta la descarga con la prioridad pedida', () async {
      expect(await service.isTypeEfficacyMissing(), isTrue);

      final outcome = await service.syncTypeEfficacy(
        priority: CallPriority.user,
      );

      expect(outcome, SyncOutcome.revalidated);
      expect(pokeApi.typeTableRequests, [CallPriority.user]);
      expect(await storedTypeRows(), 324);
      expect(await service.isTypeEfficacyMissing(), isFalse);
    });

    test('no la vuelve a pedir antes de 24 h y sí después', () async {
      await service.syncTypeEfficacy();

      advance(const Duration(hours: 23));
      expect(await service.syncTypeEfficacy(), SyncOutcome.upToDate);

      advance(const Duration(hours: 2));
      expect(await service.syncTypeEfficacy(), SyncOutcome.revalidated);

      expect(pokeApi.typeTableRequests, [
        CallPriority.background,
        CallPriority.background,
      ]);
    });

    test(
      'una respuesta incompleta es inválida y conserva la tabla guardada',
      () async {
        await service.syncTypeEfficacy();
        advance(const Duration(hours: 25));
        pokeApi.typeTable = pokeApi.typeTable.sublist(0, 300);

        await expectLater(
          service.syncTypeEfficacy(),
          throwsA(isA<InvalidResponse>()),
        );
        expect(await storedTypeRows(), 324);
      },
    );

    test(
      'una respuesta vacía es inválida y la tabla sigue pendiente',
      () async {
        pokeApi.typeTable = const [];

        await expectLater(
          service.syncTypeEfficacy(),
          throwsA(isA<InvalidResponse>()),
        );
        expect(await service.isTypeEfficacyMissing(), isTrue);
      },
    );

    test('typeEfficacyJob es de fondo salvo que se pida otra prioridad', () {
      expect(service.typeEfficacyJob().key, 'type_efficacy');
      expect(service.typeEfficacyJob().priority, CallPriority.background);
      expect(
        service.typeEfficacyJob(priority: CallPriority.user).priority,
        CallPriority.user,
      );
    });
  });

  group('isCompleteTypeTable', () {
    final savedRows = [
      for (final dto in PokeApiDetails.savedTypeTable())
        dto.toTypeEfficacyEntry(),
    ];

    test('acepta la tabla de 18 × 18 tipos', () {
      expect(isCompleteTypeTable(savedRows), isTrue);
    });

    test('rechaza una fila de menos o una repetida', () {
      final withoutLast = savedRows.sublist(0, savedRows.length - 1);

      expect(isCompleteTypeTable(withoutLast), isFalse);
      expect(isCompleteTypeTable([...withoutLast, savedRows.first]), isFalse);
    });

    test('rechaza una tabla cuadrada con menos de 18 tipos', () {
      final firstTypes = {
        for (final row in savedRows.take(17 * 18)) row.attackingType,
      };
      final smallerTable = [
        for (final row in savedRows)
          if (firstTypes.contains(row.attackingType) &&
              firstTypes.contains(row.defendingType))
            row,
      ];

      expect(smallerTable, hasLength(17 * 17));
      expect(isCompleteTypeTable(smallerTable), isFalse);
    });

    test('acepta un tipo nuevo si la tabla sigue completa', () {
      final types = {for (final row in savedRows) row.attackingType};
      final withStellar = [
        ...savedRows,
        for (final type in types) ...[
          TypeEfficacyEntry(
            attackingType: 'stellar',
            defendingType: type,
            damageFactor: 100,
          ),
          TypeEfficacyEntry(
            attackingType: type,
            defendingType: 'stellar',
            damageFactor: 100,
          ),
        ],
        const TypeEfficacyEntry(
          attackingType: 'stellar',
          defendingType: 'stellar',
          damageFactor: 100,
        ),
      ];

      expect(isCompleteTypeTable(withStellar), isTrue);
    });
  });
}
