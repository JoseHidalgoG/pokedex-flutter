import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pokedex_flutter/features/connectivity/connectivity_providers.dart';
import 'package:pokedex_flutter/features/connectivity/domain/connectivity_status.dart';

import 'package:pokedex_flutter/features/catalog/domain/entities/catalog_sync_status.dart';
import 'package:pokedex_flutter/features/catalog/presentation/providers/catalog_providers.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    final syncAsync = ref.watch(catalogSyncStatusProvider);

    return connectivityAsync.when(
      data: (connectivityStatus) {
        final syncStatus = syncAsync.asData?.value;

        late final String title;
        late String subtitle;
        late final IconData icon;
        late final Color backgroundColor;

        if (syncStatus is CatalogSyncInProgress) {
          title = 'Sincronizando…';
          subtitle = connectivityStatus == ConnectivityStatus.online
              ? 'En línea · puedes seguir navegando'
              : 'Actualizando información local';
          icon = Icons.sync;
          backgroundColor = Colors.blue.shade700;
        } else {
          switch (connectivityStatus) {
            case ConnectivityStatus.online:
              title = 'En línea';
              subtitle = 'Datos remotos · catálogo disponible';
              icon = Icons.cloud_done;
              backgroundColor = Colors.green.shade700;

            case ConnectivityStatus.offline:
              title = 'Sin conexión';
              subtitle = 'Datos locales · modo offline';
              icon = Icons.wifi_off;
              backgroundColor = Colors.grey.shade800;

            case ConnectivityStatus.serviceUnavailable:
              title = 'Servicio no disponible';
              subtitle = 'Red activa, API sin respuesta · datos locales';
              icon = Icons.cloud_off;
              backgroundColor = Colors.orange.shade800;
          }

          if (syncStatus is CatalogSyncFailed) {
            subtitle =
                syncStatus.reason == CatalogSyncFailureReason.noConnection
                ? 'No se pudo sincronizar · sin conexión'
                : 'No se pudo sincronizar · se conservan los datos locales';
          }
        }

        return Semantics(
          liveRegion: true,
          label: '$title. $subtitle',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: backgroundColor,
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
