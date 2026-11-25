import 'dart:developer' as developer;

import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_failure.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_differences.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/pokemon_detail_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/type_efficacy_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_detail_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/type_efficacy_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';

class PokemonDetailSyncService {
  PokemonDetailSyncService({
    required this._remoteDataSource,
    required this._detailDao,
    required this._catalogDao,
    this._now = DateTime.now,
  });

  final CatalogRemoteDataSource _remoteDataSource;
  final PokemonDetailDao _detailDao;
  final CatalogDao _catalogDao;
  final DateTime Function() _now;

  SyncJob detailJob(int pokemonId, {bool force = false}) {
    return SyncJob(
      key: detailSyncKey(pokemonId),
      priority: CallPriority.user,
      runningStatus: const SyncRevalidating(),
      force: force,
      perform: () => syncDetail(pokemonId, force: force),
    );
  }

  SyncJob typeEfficacyJob({CallPriority priority = CallPriority.background}) {
    return SyncJob(
      key: typeEfficacySyncKey,
      priority: priority,
      runningStatus: const SyncRevalidating(),
      perform: () => syncTypeEfficacy(priority: priority),
    );
  }

  Future<bool> isDetailMissing(int pokemonId) async {
    return await _detailDao.readDetailSyncedAt(pokemonId) == null;
  }

  Future<bool> needsDetailDownload(int pokemonId) async {
    final stored = await _catalogDao.readStoredEntry(pokemonId);
    return _isAltered(stored) || !await _isDetailFresh(pokemonId);
  }

  Future<SyncOutcome> syncDetail(int pokemonId, {bool force = false}) {
    return asSyncFailures(() async {
      final stored = await _catalogDao.readStoredEntry(pokemonId);
      final isAltered = _isAltered(stored);
      if (!force && !isAltered && await _isDetailFresh(pokemonId)) {
        return SyncOutcome.upToDate;
      }
      final remoteDetail = await _remoteDataSource.fetchPokemonDetail(
        pokemonId,
      );
      if (remoteDetail == null) {
        _log('detalle #$pokemonId: PokeAPI no lo devolvió, se deja como está');
        return SyncOutcome.upToDate;
      }
      final detail = remoteDetail.toDetailEntry();
      if (stored != null && isAltered) {
        _log(
          'detalle #$pokemonId restaurado '
          '${describedDifferencesBetween(stored.entry, detail.pokemon)}',
        );
      }
      await _detailDao.saveDetail(detail, savedAt: _now());
      return SyncOutcome.revalidated;
    });
  }

  Future<bool> isTypeEfficacyMissing() => _detailDao.isTypeEfficacyEmpty();

  Future<SyncOutcome> syncTypeEfficacy({
    CallPriority priority = CallPriority.background,
  }) {
    return asSyncFailures(() async {
      if (await _isTypeEfficacyFresh()) {
        return SyncOutcome.upToDate;
      }
      final remoteRows = await _remoteDataSource.fetchTypeEfficacy(
        priority: priority,
      );
      final rows = [for (final row in remoteRows) row.toTypeEfficacyEntry()];
      if (!isCompleteTypeTable(rows)) {
        _log(
          'tabla de tipos incompleta (${rows.length} filas), '
          'se conserva la guardada',
        );
        throw const InvalidResponse();
      }
      await _detailDao.replaceTypeEfficacy(rows, savedAt: _now());
      return SyncOutcome.revalidated;
    });
  }

  Future<bool> _isDetailFresh(int pokemonId) async {
    final savedAt = await _detailDao.readDetailSyncedAt(pokemonId);
    return savedAt != null &&
        _now().difference(savedAt) < detailFreshnessWindow;
  }

  Future<bool> _isTypeEfficacyFresh() async {
    if (await _detailDao.isTypeEfficacyEmpty()) {
      return false;
    }
    final savedAt = await _detailDao.readTypeEfficacySyncedAt();
    return savedAt != null &&
        _now().difference(savedAt) < typeEfficacyFreshness;
  }

  static bool _isAltered(StoredCatalogEntry? stored) {
    return stored != null &&
        differsFromStoredFingerprint(
          stored.entry,
          stored: stored.storedFingerprint,
        );
  }

  static void _log(String message) {
    developer.log(message, name: 'sync');
  }
}

bool isCompleteTypeTable(List<TypeEfficacyEntry> rows) {
  final attackingTypes = {for (final row in rows) row.attackingType};
  final defendingTypes = {for (final row in rows) row.defendingType};
  final pairs = {
    for (final row in rows) (row.attackingType, row.defendingType),
  };
  final typeCount = attackingTypes.length;
  return typeCount >= minimumTypeCount &&
      defendingTypes.length == typeCount &&
      attackingTypes.containsAll(defendingTypes) &&
      pairs.length == rows.length &&
      rows.length == typeCount * typeCount;
}
