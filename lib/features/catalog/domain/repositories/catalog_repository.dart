import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon.dart';

abstract interface class CatalogRepository {
  Stream<List<Pokemon>> watchCatalog();

  Stream<CatalogSyncStatus> watchSyncStatus();

  Future<void> syncCatalog();
}
