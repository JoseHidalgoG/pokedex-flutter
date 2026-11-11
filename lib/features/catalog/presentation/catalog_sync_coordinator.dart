import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

class CatalogSyncCoordinator extends ConsumerStatefulWidget {
  const CatalogSyncCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CatalogSyncCoordinator> createState() =>
      _CatalogSyncCoordinatorState();
}

class _CatalogSyncCoordinatorState
    extends ConsumerState<CatalogSyncCoordinator> {
  @override
  void initState() {
    super.initState();

    Future.microtask(_syncCatalog);
  }

  Future<void> _syncCatalog() async {
    if (!mounted) return;

    try {
      await ref.read(syncCatalogProvider)();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ConnectivityStatus>>(connectivityStatusProvider, (
      previous,
      next,
    ) {
      final previousStatus = previous?.asData?.value;
      final nextStatus = next.asData?.value;

      if (previousStatus != null &&
          previousStatus != ConnectivityStatus.online &&
          nextStatus == ConnectivityStatus.online) {
        _syncCatalog();
      }
    });

    return widget.child;
  }
}
