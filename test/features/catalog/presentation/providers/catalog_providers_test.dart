import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';

class InMemoryCatalogRepository implements CatalogRepository {
  int syncRequests = 0;

  final List<Pokemon> _pokemon = List.generate(
    51,
        (index) => Pokemon(
      id: index + 1,
      name: 'pokemon${index + 1}',
      imageUrl: 'https://example.com/${index + 1}.png',
      typeNames: const ['normal'],
    ),
  );


  @override
  Stream<List<Pokemon>> watchCatalog() {
    return Stream.value(_pokemon);
  }

  @override
  Stream<List<Pokemon>> watchCatalogPage({
    required int page,
    required int pageSize,
  }) {
    final offset = page * pageSize;

    final pagePokemon = _pokemon
        .skip(offset)
        .take(pageSize)
        .toList();

    return Stream.value(pagePokemon);
  }

  @override
  Stream<int> watchCatalogCount() {
    return Stream.value(_pokemon.length);
  }

  @override
  Stream<CatalogSyncStatus> watchSyncStatus() {
    return Stream.value(const CatalogSyncInProgress());
  }

  @override
  Future<void> syncCatalog() async {
    syncRequests++;
  }

  @override
  Future<DateTime?> getLastSyncedAt() async => null;
}

void main() {
  late InMemoryCatalogRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryCatalogRepository();

    container = ProviderContainer.test(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  test('catalogProvider emite lo que entrega el repositorio', () async {
    container.listen(catalogProvider, (_, _) {});

    final catalog = await container.read(catalogProvider.future);

    expect(catalog, hasLength(51));
    expect(catalog.first.name, 'pokemon1');
    expect(catalog.last.name, 'pokemon51');
  });

  test('catalogPageProvider devuelve la primera página desde el índice 0', () async {
    container.listen(catalogPageProvider(0), (_, _) {});

    final catalog = await container.read(
      catalogPageProvider(0).future,
    );

    expect(catalog, hasLength(50));
    expect(catalog.first.id, 1);
    expect(catalog.last.id, 50);
  });

  test('catalogCountProvider emite el total de Pokémon', () async {
    container.listen(catalogCountProvider, (_, _) {});

    final count = await container.read(catalogCountProvider.future);

    expect(count, 51);
  });

  test('catalogSyncStatusProvider emite el estado del repositorio', () async {
    container.listen(catalogSyncStatusProvider, (_, _) {});

    final status = await container.read(catalogSyncStatusProvider.future);

    expect(status, isA<CatalogSyncInProgress>());
  });

  test('syncCatalogProvider llama a syncCatalog del repositorio', () async {
    await container.read(syncCatalogProvider)();

    expect(repository.syncRequests, 1);
  });


  test('la paginación divide 51 Pokémon en páginas de 50 y 1', () async {
    container.listen(catalogPageProvider(0), (_, _) {});
    container.listen(catalogPageProvider(1), (_, _) {});

    final firstPage = await container.read(
      catalogPageProvider(0).future,
    );

    final secondPage = await container.read(
      catalogPageProvider(1).future,
    );

    expect(firstPage.length, 50);
    expect(firstPage.first.id, 1);
    expect(firstPage.last.id, 50);

    expect(secondPage.length, 1);
    expect(secondPage.first.id, 51);
  });
}
