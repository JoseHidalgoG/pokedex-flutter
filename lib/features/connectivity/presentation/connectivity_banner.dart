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
    final lastSyncAsync = ref.watch(lastCatalogSyncProvider);

    final lastSyncAt = lastSyncAsync.asData?.value;

    final lastSyncText = lastSyncAt == null
        ? 'Sin sincronizaciones anteriores'
        : 'Última sync: ${_formatDateTime(lastSyncAt)}';

    return connectivityAsync.when(
      data: (connectivityStatus) {
        final syncStatus = syncAsync.asData?.value;
        final isSyncing = syncStatus is CatalogSyncInProgress;

        late final String title;
        late String subtitle;
        late final IconData icon;
        late final Color color;
        late final Color backgroundColor;

        if (isSyncing) {
          title = 'Sincronizando...';
          subtitle = connectivityStatus == ConnectivityStatus.online
              ? 'En línea · Puedes seguir navegando'
              : 'Actualizando información local';

          icon = Icons.sync;
          color = const Color(0xFF2453A6);
          backgroundColor = const Color(0xFFE6EDF8);
        } else {
          switch (connectivityStatus) {
            case ConnectivityStatus.online:
              title = 'En línea';
              subtitle = 'API disponible · datos locales · $lastSyncText';
              icon = Icons.cloud_done;
              color = const Color(0xFF245B38);
              backgroundColor = const Color(0xFFE5F1E8);

            case ConnectivityStatus.offline:
              title = 'Sin conexión';
              subtitle = 'Datos locales · $lastSyncText';
              icon = Icons.cloud_off;
              color = const Color(0xFF47505E);
              backgroundColor = const Color(0xFFE5E7EB);

            case ConnectivityStatus.serviceUnavailable:
              title = 'Servicio no disponible';
              subtitle =
              'Red activa, API sin respuesta · datos locales · $lastSyncText';

              icon = Icons.warning_amber_rounded;
              color = const Color(0xFF805300);
              backgroundColor = const Color(0xFFFFF1D6);
          }

          if (syncStatus is CatalogSyncFailed) {
            subtitle =
            syncStatus.reason == CatalogSyncFailureReason.noConnection
                ? 'No se pudo sincronizar · Sin conexión'
                : 'No se pudo sincronizar · Se conservan los datos locales';
          }
        }

        return Semantics(
          liveRegion: true,
          label: '$title. $subtitle',
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFDCE0E7),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado
                const Text(
                  'Pokédex',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202939),
                  ),
                ),

                const SizedBox(height: 8),

                // Indicador de conectividad
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Icon(
                          icon,
                          color: color,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Progreso de sincronización
                if (isSyncing) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Color(0xFFE6EAF0),
                      color: Color(0xFF2453A6),
                    ),
                  ),
                ],
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

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');

  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$day/$month · $hour:$minute';
}