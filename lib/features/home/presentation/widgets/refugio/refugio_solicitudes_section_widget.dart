import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../solicitud/presentation/providers/solicitud_providers.dart';

class RefugioSolicitudesSectionWidget extends ConsumerWidget {
  final String refugioId;
  final VoidCallback onVerTodas;

  const RefugioSolicitudesSectionWidget({
    super.key,
    required this.refugioId,
    required this.onVerTodas,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudesAsync = ref.watch(solicitudesByRefugioProvider(refugioId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solicitudes Recientes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onVerTodas,
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: Color(0xFF00BCD4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          solicitudesAsync.when(
            data: (solicitudes) {
              // Mostrar solo las 2 primeras solicitudes pendientes
              final solicitudesPendientes = solicitudes
                  .where((s) => s.estado == 'pendiente')
                  .take(2)
                  .toList();

              if (solicitudesPendientes.isEmpty) {
                return const Text(
                  'No hay solicitudes pendientes',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return Column(
                children: solicitudesPendientes
                    .map((s) => _buildSolicitudCard(context, ref, s))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudCard(
    BuildContext context,
    WidgetRef ref,
    dynamic solicitud,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        children: [
          // Imagen de la mascota
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: solicitud.mascotaFoto.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      solicitud.mascotaFoto,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.pets, color: Colors.orange);
                      },
                    ),
                  )
                : const Icon(Icons.pets, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitud para ${solicitud.mascotaNombre}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'De: ${solicitud.refugioNombre}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onVerTodas,
                icon: const Icon(Icons.check_circle, color: Colors.green),
                iconSize: 28,
              ),
              IconButton(
                onPressed: onVerTodas,
                icon: const Icon(Icons.cancel, color: Colors.red),
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
