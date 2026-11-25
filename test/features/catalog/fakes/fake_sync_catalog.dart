import 'package:pokedex_flutter/features/catalog/domain/usecases/sync_catalog.dart';

class FakeSyncCatalog implements SyncCatalog {
  FakeSyncCatalog({this.onSync});

  final Future<void> Function(bool force)? onSync;

  final List<bool> requests = [];

  int get calls => requests.length;

  @override
  Future<void> call({bool force = false}) async {
    requests.add(force);

    final callback = onSync;

    if (callback != null) {
      await callback(force);
    }
  }
}
