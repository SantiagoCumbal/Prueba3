import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../refugio/domain/entities/refugio_entity.dart';
import '../../../../mascota/presentation/providers/mascota_providers.dart';
import '../../../../solicitud/presentation/providers/solicitud_providers.dart';
import 'refugio_stats_card_widget.dart';

class RefugioStatsSectionWidget extends ConsumerWidget {
  final RefugioEntity refugio;

  const RefugioStatsSectionWidget({super.key, required this.refugio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mascotasCountAsync = ref.watch(mascotasCountProvider(refugio.id));
    final solicitudesAsync = ref.watch(
      solicitudesByRefugioProvider(refugio.id),
    );

    return mascotasCountAsync.when(
      data: (counts) {
        final pendientesCount = solicitudesAsync.maybeWhen(
          data: (solicitudes) =>
              solicitudes.where((s) => s.estado == 'pendiente').length,
          orElse: () => 0,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: RefugioStatsCardWidget(
                  value: counts['total'].toString(),
                  label: 'Mascotas',
                  color: const Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RefugioStatsCardWidget(
                  value: pendientesCount.toString(),
                  label: 'Pendientes',
                  color: const Color(0xFFFF8A00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RefugioStatsCardWidget(
                  value: counts['adoptadas'].toString(),
                  label: 'Adoptadas',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: RefugioStatsCardWidget(
                value: refugio.totalMascotas.toString(),
                label: 'Mascotas',
                color: const Color(0xFF00BCD4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RefugioStatsCardWidget(
                value: refugio.solicitudesPendientes.toString(),
                label: 'Pendientes',
                color: const Color(0xFFFF8A00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RefugioStatsCardWidget(
                value: refugio.mascotasAdoptadas.toString(),
                label: 'Adoptadas',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: RefugioStatsCardWidget(
                value: '0',
                label: 'Mascotas',
                color: const Color(0xFF00BCD4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RefugioStatsCardWidget(
                value: '0',
                label: 'Pendientes',
                color: const Color(0xFFFF8A00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RefugioStatsCardWidget(
                value: '0',
                label: 'Adoptadas',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
