import 'package:pokedex_flutter/core/preferences/domain/preferences_store.dart';
import 'package:pokedex_flutter/features/catalog/data/mappers/catalog_query_codec.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_query_state.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/catalog_query_repository.dart';

class CatalogQueryRepositoryImpl implements CatalogQueryRepository {
  CatalogQueryRepositoryImpl(
    this._preferencesStore, {
    this._codec = const CatalogQueryCodec(),
  });

  static const preferenceKey = 'catalog_query';

  final PreferencesStore _preferencesStore;
  final CatalogQueryCodec _codec;

  @override
  Future<CatalogQueryState> load() async {
    final value = await _preferencesStore.getPreference(preferenceKey);

    return _codec.decode(value);
  }

  @override
  Future<void> save(CatalogQueryState state) async {
    final value = _codec.encode(state);

    await _preferencesStore.setPreference(preferenceKey, value);
  }

  @override
  Future<void> clear() {
    return _preferencesStore.deletePreference(preferenceKey);
  }
}
