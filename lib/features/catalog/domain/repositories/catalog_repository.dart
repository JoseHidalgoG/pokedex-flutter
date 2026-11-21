import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_progress.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';

abstract interface class CatalogRepository {
  Stream<List<Pokemon>> watchCatalog();

  Stream<List<Pokemon>> watchCatalogPage({
    required int page,
    required int pageSize,
  });

  Stream<int> watchCatalogCount();

  Stream<CatalogProgress> watchCatalogProgress();

  Stream<List<Pokemon>> watchPokemonByIds(List<int> ids);

  Stream<SyncStatus> watchSyncStatus();

  Future<void> syncCatalog({bool force = false});

  Future<void> revalidatePokemon(List<int> ids, {bool force = false});

  Future<DateTime?> getLastSyncedAt();
}
