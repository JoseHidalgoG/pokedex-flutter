import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/sync_scheduler.dart';
import 'package:pokedex_flutter/features/catalog/data/local/detail_entry_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/local/pokemon_detail_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/type_efficacy_entry_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/pokemon_detail_sync_service.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/detail_freshness.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/pokemon_detail.dart';
import 'package:pokedex_flutter/features/catalog/domain/entities/type_matchups.dart';
import 'package:pokedex_flutter/features/catalog/domain/repositories/pokemon_detail_repository.dart';

class OfflineFirstPokemonDetailRepository implements PokemonDetailRepository {
  OfflineFirstPokemonDetailRepository({
    required this._detailDao,
    required this._syncService,
    required this._scheduler,
  });

  final PokemonDetailDao _detailDao;
  final PokemonDetailSyncService _syncService;
  final SyncScheduler _scheduler;

  @override
  Stream<PokemonDetail?> watchPokemonDetail(int pokemonId) {
    return _detailDao
        .watchDetail(pokemonId)
        .map((detail) => detail?.toPokemonDetail());
  }

  @override
  Stream<DetailFreshness> watchPokemonDetailFreshness(int pokemonId) {
    final key = detailSyncKey(pokemonId);
    return _scheduler
        .watchStatus(key)
        .asyncMap(
          (_) async => detailFreshnessOf(
            revalidatedThisSessionAt: _scheduler.lastRevalidationOf(key),
            savedAt: await _detailDao.readDetailSyncedAt(pokemonId),
          ),
        )
        .distinct();
  }

  @override
  Stream<List<TypeEfficacy>> watchTypeEfficacy() {
    return _detailDao.watchTypeEfficacy().map(
      (rows) => [for (final row in rows) row.toTypeEfficacy()],
    );
  }

  @override
  Future<void> revalidatePokemonDetail(
    int pokemonId, {
    bool force = false,
  }) async {
    _scheduler.runOnEachReconnect(_syncService.detailJob(pokemonId));
    if (!_scheduler.isOnline) {
      return;
    }
    await Future.wait([
      _downloadTypeEfficacyIfMissing(),
      _revalidateDetail(pokemonId, force: force),
    ]);
  }

  @override
  void stopRevalidatingPokemonDetail(int pokemonId) {
    _scheduler.stopRunningOnReconnect(detailSyncKey(pokemonId));
  }

  @override
  Future<void> saveDetailForOffline(int pokemonId) async {
    if (!await _syncService.isDetailMissing(pokemonId)) {
      return;
    }
    await _scheduler.runWhenOnline(_syncService.detailJob(pokemonId));
  }

  Future<void> _revalidateDetail(int pokemonId, {required bool force}) async {
    if (!force && !await _syncService.needsDetailDownload(pokemonId)) {
      return;
    }
    await _scheduler.runLatest(_syncService.detailJob(pokemonId, force: force));
  }

  Future<void> _downloadTypeEfficacyIfMissing() async {
    if (!await _syncService.isTypeEfficacyMissing()) {
      return;
    }
    await _scheduler.run(
      _syncService.typeEfficacyJob(priority: CallPriority.user),
    );
  }
}
