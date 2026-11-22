import 'dart:developer' as developer;
import 'dart:math';

import 'package:pokedex_flutter/core/sync/data/sync_failure_translator.dart';
import 'package:pokedex_flutter/core/sync/domain/call_budget.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_job.dart';
import 'package:pokedex_flutter/core/sync/domain/sync_status.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_differences.dart';
import 'package:pokedex_flutter/features/catalog/data/catalog_fingerprint.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_entry.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/catalog_remote_data_source.dart';
import 'package:pokedex_flutter/features/catalog/data/remote/pokemon_dto_mapper.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_constants.dart';

class CatalogRestorationService {
  CatalogRestorationService({
    required this._remoteDataSource,
    required this._catalogDao,
    this._now = DateTime.now,
  });

  final CatalogRemoteDataSource _remoteDataSource;
  final CatalogDao _catalogDao;
  final DateTime Function() _now;
  final _idsMissingFromPokeApi = <int>{};

  SyncJob restorationJob() {
    return SyncJob(
      key: restorationSyncKey,
      priority: CallPriority.restoration,
      runningStatus: const SyncRevalidating(),
      perform: restoreAlteredPokemon,
    );
  }

  Future<SyncOutcome> restoreAlteredPokemon() {
    return asSyncFailures(() async {
      final alteredPokemon = await _findAlteredPokemon();
      if (alteredPokemon.isEmpty) {
        return SyncOutcome.upToDate;
      }
      _log('${alteredPokemon.length} Pokémon con la huella alterada');
      for (
        var start = 0;
        start < alteredPokemon.length;
        start += catalogRemoteBatchSize
      ) {
        final end = min(start + catalogRemoteBatchSize, alteredPokemon.length);
        await _restore(alteredPokemon.sublist(start, end));
      }
      return SyncOutcome.revalidated;
    });
  }

  Future<List<CatalogEntry>> _findAlteredPokemon() async {
    final storedEntries = await _catalogDao.readEntriesWithFingerprint();
    await _catalogDao.recordFingerprintsVerified(at: _now());
    return [
      for (final (:entry, :storedFingerprint) in storedEntries)
        if (!_idsMissingFromPokeApi.contains(entry.id) &&
            differsFromStoredFingerprint(entry, stored: storedFingerprint))
          entry,
    ];
  }

  Future<void> _restore(List<CatalogEntry> alteredPokemon) async {
    final remotePokemon = await _remoteDataSource.fetchPokemonByIds([
      for (final entry in alteredPokemon) entry.id,
    ], priority: CallPriority.restoration);
    final remoteEntries = {
      for (final dto in remotePokemon) dto.id: dto.toCatalogEntry(),
    };
    for (final local in alteredPokemon) {
      final remote = remoteEntries[local.id];
      if (remote == null) {
        _idsMissingFromPokeApi.add(local.id);
        _log(
          'restauración #${local.id}: PokeAPI no lo devolvió, '
          'se deja como está',
        );
      } else {
        _log(
          'restauración #${local.id} '
          '${describedDifferencesBetween(local, remote)}',
        );
      }
    }
    await _catalogDao.saveRevalidated([
      ...remoteEntries.values,
    ], savedAt: _now());
  }

  static void _log(String message) {
    developer.log(message, name: 'sync');
  }
}
