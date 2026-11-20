import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/database/app_database_provider.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex_flutter/core/network/pokeapi_graphql_client_provider.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_data_providers.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

import '../../../fixtures/catalog_batch_fixture.dart';

class SavedBatchPokeApiLink extends Link {
  SavedBatchPokeApiLink({this.unreachableRequests = 0});

  int unreachableRequests;
  var requests = 0;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    requests++;
    if (unreachableRequests > 0) {
      unreachableRequests--;
      return Stream.error(const SocketException('Failed host lookup'));
    }
    final savedResponse = savedCatalogBatchResponse();
    return Stream.value(
      Response(
        data: savedResponse['data'] as Map<String, Object?>?,
        response: savedResponse,
      ),
    );
  }
}

void main() {
  late AppDatabase database;
  late StreamController<ConnectivityStatus> connectivity;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    connectivity = StreamController<ConnectivityStatus>();
  });

  tearDown(() async {
    await connectivity.close();
    await database.close();
  });

  ProviderContainer startAppOver(SavedBatchPokeApiLink pokeApi) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        connectivityStatusProvider.overrideWith((ref) => connectivity.stream),
        pokeApiGraphQLClientProvider.overrideWithValue(
          createPokeApiGraphQLClient(link: pokeApi),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(catalogFullPassTriggersProvider, (_, _) {});
    return container;
  }

  Stream<SyncStatus> catalogStatusIn(ProviderContainer container) {
    return container
        .read(offlineFirstCatalogRepositoryProvider)
        .watchSyncStatus();
  }

  test('al arrancar descarga el catálogo sin esperar a la conexión', () async {
    final pokeApi = SavedBatchPokeApiLink();

    final container = startAppOver(pokeApi);

    await expectLater(database.catalogDao.watchCatalogCount(), emitsThrough(4));
    await expectLater(
      catalogStatusIn(container),
      emitsThrough(isA<SyncRevalidated>()),
    );
    expect(pokeApi.requests, 1);
  });

  test(
    'si al arrancar no hay conexión, repite la pasada al pasar a en línea',
    () async {
      final pokeApi = SavedBatchPokeApiLink(unreachableRequests: 1);

      final container = startAppOver(pokeApi);
      await expectLater(
        catalogStatusIn(container),
        emitsThrough(
          isA<SyncFailed>().having(
            (status) => status.failure,
            'failure',
            const NoConnection(),
          ),
        ),
      );
      connectivity.add(ConnectivityStatus.offline);
      connectivity.add(ConnectivityStatus.online);

      await expectLater(
        database.catalogDao.watchCatalogCount(),
        emitsThrough(4),
      );
      expect(pokeApi.requests, 2);
    },
  );

  test('una reconexión con el catálogo fresco no llama a PokeAPI', () async {
    final pokeApi = SavedBatchPokeApiLink();
    final container = startAppOver(pokeApi);
    await expectLater(
      catalogStatusIn(container),
      emitsThrough(isA<SyncRevalidated>()),
    );

    connectivity
      ..add(ConnectivityStatus.serviceUnavailable)
      ..add(ConnectivityStatus.online);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(pokeApi.requests, 1);
    expect(await catalogStatusIn(container).first, isA<SyncRevalidated>());
  });
}
