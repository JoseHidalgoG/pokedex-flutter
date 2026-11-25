import 'dart:developer' as developer;

import 'package:pokedex_flutter/core/database/app_database.dart';
import 'package:pokedex_flutter/core/network/logging_link.dart';
import 'package:pokedex_flutter/core/sync/data/sync_metadata_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/local/catalog_dao.dart';
import 'package:pokedex_flutter/features/catalog/data/sync/catalog_sync_service.dart';

String interruptionMessageOf(SyncMetadataRow interrupted) {
  final key = interrupted.key;
  if (key != CatalogDao.catalogSyncKey) {
    return '$key: la sincronización anterior se interrumpió; '
        'se repite con su disparador habitual';
  }
  if (interrupted.isComplete) {
    return '$key: la pasada anterior se interrumpió antes de guardar '
        'su primer lote; el catálogo sigue completo';
  }
  if (interrupted.nextOffset == 0) {
    return '$key: la pasada anterior se interrumpió antes de guardar '
        'su primer lote; empieza desde 0';
  }
  final progress = catalogProgressText(
    interrupted.nextOffset,
    interrupted.totalCount,
  );
  return '$key: la pasada anterior se interrumpió en $progress; se reanuda';
}

void _writeToSyncLog(String message) {
  developer.log(message, name: 'sync');
}

class InterruptedSyncReport {
  InterruptedSyncReport({
    required this._syncMetadata,
    this._write = _writeToSyncLog,
  });

  final SyncMetadataDao _syncMetadata;
  final LogWriter _write;

  Future<void> reportAtStartup() async {
    final interruptedSyncs = await _syncMetadata.takeInterruptedSyncs();
    for (final interrupted in interruptedSyncs) {
      _write(interruptionMessageOf(interrupted));
    }
  }
}
