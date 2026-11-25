import 'dart:async';

import 'package:async/async.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/retry_policy.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/offline_first_pokemon_detail_repository.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/pokemon_detail_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';

import '../../../fixtures/pokemon_detail_fixture.dart';
import '../fakes/poke_api_details.dart';

const pikachuFromCatalog = CatalogEntry(
  id: 25,
  name: 'pikachu',
  imageUrl: 'https://example.com/25.png',
  typeNames: ['electric'],
);

void main() {
  late AppDatabase database;
  late PokeApiDetails pokeApi;
  late SyncScheduler scheduler;
  late OfflineFirstPokemonDetailRepository repository;
  late DateTime now;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    pokeApi = PokeApiDetails();
    now = DateTime(2026, 11, 24, 10);
    scheduler = SyncScheduler(
      budget: CallBudget(now: () => now),
      retryPolicy: RetryPolicy(),
      store: database.syncMetadataDao,
      now: () => now,
    );
    repository = OfflineFirstPokemonDetailRepository(
      detailDao: database.pokemonDetailDao,
      syncService: PokemonDetailSyncService(
        remoteDataSource: pokeApi,
        detailDao: database.pokemonDetailDao,
        catalogDao: database.catalogDao,
        now: () => now,
      ),
      scheduler: scheduler,
    );
  });

  tearDown(() async {
    await scheduler.dispose();
    await database.close();
  });

  Future<void> revalidated(int pokemonId) {
    return scheduler
        .watchStatus('detail:$pokemonId')
        .firstWhere((status) => status is SyncRevalidated);
  }

  group('revalidar al abrir', () {
    test('sin conexión no llama a PokeAPI y al reconectar descarga el detalle abierto', () async {
      await repository.revalidatePokemonDetail(25);
      expect(pokeApi.detailRequests, isEmpty);

      scheduler.connectivityChanged(isOnline: true);
      await revalidated(25);

      expect(pokeApi.detailRequests, [25]);
      expect(pokeApi.typeTableRequests, isEmpty);
    });

    test('dos aperturas a la vez comparten una sola descarga', () async {
      scheduler.connectivityChanged(isOnline: true);
      final heldDetails = Completer<void>();
      pokeApi.heldDetails = heldDetails;

      final firstOpen = repository.revalidatePokemonDetail(25);
      final secondOpen = repository.revalidatePokemonDetail(25);
      await pumpEventQueue();
      heldDetails.complete();
      await Future.wait([firstOpen, secondOpen]);

      expect(pokeApi.detailRequests, [25]);
    });

    test(
      'dentro de los 5 min no vuelve a llamar ni a publicar que revalida',
      () async {
        scheduler.connectivityChanged(isOnline: true);
        await repository.revalidatePokemonDetail(25);
        final statuses = <SyncStatus>[];
        final subscription = scheduler
            .watchStatus('detail:25')
            .listen(statuses.add);
        addTearDown(subscription.cancel);

        now = now.add(const Duration(minutes: 4));
        await repository.revalidatePokemonDetail(25);
        await pumpEventQueue();

        expect(pokeApi.detailRequests, [25]);
        expect(statuses, [isA<SyncRevalidated>()]);
      },
    );

    test('force descarga aunque el detalle esté fresco', () async {
      scheduler.connectivityChanged(isOnline: true);
      await repository.revalidatePokemonDetail(25);

      await repository.revalidatePokemonDetail(25, force: true);

      expect(pokeApi.detailRequests, [25, 25]);
    });

    test('al cerrar el detalle deja de pedirlo en cada reconexión', () async {
      await repository.revalidatePokemonDetail(25);

      repository.stopRevalidatingPokemonDetail(25);
      scheduler.connectivityChanged(isOnline: true);
      await pumpEventQueue();

      expect(pokeApi.detailRequests, isEmpty);
    });

    test('con la tabla de tipos vacía la pide con prioridad de usuario una sola vez', () async {
      scheduler.connectivityChanged(isOnline: true);

      await repository.revalidatePokemonDetail(25);
      await repository.revalidatePokemonDetail(133);

      expect(pokeApi.typeTableRequests, [CallPriority.user]);
      expect(await repository.watchTypeEfficacy().first, hasLength(324));
    });
  });

  group('guardar para usar sin conexión', () {
    test('con conexión descarga un detalle que nunca se bajó', () async {
      scheduler.connectivityChanged(isOnline: true);

      await repository.saveDetailForOffline(25);

      expect(pokeApi.detailRequests, [25]);
      expect(await database.pokemonDetailDao.readDetailSyncedAt(25), now);
    });

    test(
      'un detalle ya descargado no se vuelve a pedir aunque tenga días',
      () async {
        await database.pokemonDetailDao.saveDetail(
          PokemonDetailDto.fromJson(savedPokemonDetailJson('pikachu'))
              .toDetailEntry(),
          savedAt: now.subtract(const Duration(days: 3)),
        );
        scheduler.connectivityChanged(isOnline: true);

        await repository.saveDetailForOffline(25);

        expect(pokeApi.detailRequests, isEmpty);
      },
    );

    test('sin conexión lo descarga en la próxima reconexión y no en las siguientes', () async {
      await repository.saveDetailForOffline(25);
      expect(pokeApi.detailRequests, isEmpty);

      scheduler.connectivityChanged(isOnline: true);
      await revalidated(25);
      expect(pokeApi.detailRequests, [25]);

      now = now.add(const Duration(minutes: 10));
      scheduler
        ..connectivityChanged(isOnline: false)
        ..connectivityChanged(isOnline: true);
      await pumpEventQueue();

      expect(pokeApi.detailRequests, [25]);
    });

    test(
      'cerrar el detalle sin conexión no cancela lo pedido por el favorito',
      () async {
        await repository.revalidatePokemonDetail(25);
        await repository.saveDetailForOffline(25);
        repository.stopRevalidatingPokemonDetail(25);

        scheduler.connectivityChanged(isOnline: true);
        await revalidated(25);

        expect(pokeApi.detailRequests, [25]);
      },
    );
  });

  group('lectura local', () {
    test('emite el Pokémon del catálogo sin detalle y después el detalle descargado', () async {
      await database.catalogDao.saveRevalidated(const [
        pikachuFromCatalog,
      ], savedAt: now);
      final details = StreamQueue(repository.watchPokemonDetail(25));
      addTearDown(details.cancel);

      final fromCatalog = (await details.next)!;
      expect(fromCatalog.pokemon.name, 'pikachu');
      expect(fromCatalog.hasStoredDetail, isFalse);
      expect(fromCatalog.evolutionTree, isNull);

      scheduler.connectivityChanged(isOnline: true);
      await repository.revalidatePokemonDetail(25);

      await expectLater(
        details,
        emitsThrough(
          isA<PokemonDetail>()
              .having((detail) => detail.detailSyncedAt, 'savedAt', now)
              .having((detail) => detail.moves, 'moves', isNotEmpty),
        ),
      );
    });

    test('un Pokémon que no está guardado emite null', () async {
      expect(await repository.watchPokemonDetail(25).first, isNull);
    });

    test('la tabla de tipos llega como entidades del dominio', () async {
      scheduler.connectivityChanged(isOnline: true);
      await repository.revalidatePokemonDetail(25);

      final typeTable = await repository.watchTypeEfficacy().first;
      final fireOnGrass = typeTable.singleWhere(
        (row) => row.attackingType == 'fire' && row.defendingType == 'grass',
      );

      expect(fireOnGrass, isA<TypeEfficacy>());
      expect(fireOnGrass.multiplier, 2);
    });
  });

  group('vigencia', () {
    test('sin detalle guardado es dato local sin fecha', () async {
      expect(
        await repository.watchPokemonDetailFreshness(25).first,
        const LocalData(),
      );
    });

    test('un detalle de otra sesión es dato local con su fecha', () async {
      final savedAt = DateTime(2026, 11, 10, 9, 15);
      await database.pokemonDetailDao.saveDetail(
        PokemonDetailDto.fromJson(savedPokemonDetailJson('pikachu'))
            .toDetailEntry(),
        savedAt: savedAt,
      );

      expect(
        await repository.watchPokemonDetailFreshness(25).first,
        LocalData(savedAt: savedAt),
      );
    });

    test('tras revalidar en esta sesión pasa a dato fresco de PokeAPI y lo conserva en la siguiente descarga', () async {
      final freshness = StreamQueue(repository.watchPokemonDetailFreshness(25));
      addTearDown(freshness.cancel);
      expect(await freshness.next, const LocalData());

      scheduler.connectivityChanged(isOnline: true);
      await repository.revalidatePokemonDetail(25);
      expect(await freshness.next, FreshFromPokeApi(now));

      now = now.add(const Duration(minutes: 6));
      final heldDetails = Completer<void>();
      pokeApi.heldDetails = heldDetails;
      final secondOpen = repository.revalidatePokemonDetail(25);
      await pumpEventQueue();
      expect(scheduler.statusOf('detail:25'), isA<SyncRevalidating>());
      heldDetails.complete();
      await secondOpen;

      expect(await freshness.next, FreshFromPokeApi(now));
    });
  });
}
