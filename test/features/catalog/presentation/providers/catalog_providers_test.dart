import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';

class InMemoryCatalogRepository implements CatalogRepository {
  int syncRequests = 0;

  @override
  Stream<List<Pokemon>> watchCatalog() {
    return Stream.value(const [
      Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/25.png',
        typeNames: ['electric'],
      ),
    ]);
  }

  @override
  Stream<CatalogSyncStatus> watchSyncStatus() {
    return Stream.value(const CatalogSyncInProgress());
  }

  @override
  Future<void> syncCatalog() async => syncRequests++;

  @override
  Future<DateTime?> getLastSyncedAt() async => null;
}

void main() {
  late InMemoryCatalogRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryCatalogRepository();
    container = ProviderContainer.test(
      overrides: [catalogRepositoryProvider.overrideWithValue(repository)],
    );
  });

  test('catalogProvider emite lo que entrega el repositorio', () async {
    container.listen(catalogProvider, (_, _) {});

    final catalog = await container.read(catalogProvider.future);

    expect([for (final pokemon in catalog) pokemon.name], ['pikachu']);
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
}
