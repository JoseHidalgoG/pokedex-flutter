import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_flutter/core/preferences/preferences_providers.dart';
import 'package:pokedex_flutter/features/catalog/data/repositories/catalog_query_repository_impl.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_query_repository.dart';

final catalogQueryRepositoryProvider = Provider<CatalogQueryRepository>((ref) {
  final preferencesStore = ref.watch(preferencesStoreProvider);

  return CatalogQueryRepositoryImpl(preferencesStore);
});
