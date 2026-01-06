import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/solicitud_repository.dart';
import '../../../mascota/domain/repositories/mascota_repository.dart';
import './solicitud_providers.dart';
import '../../../mascota/presentation/providers/mascota_providers.dart';

final updateSolicitudStateProvider =
    StateNotifierProvider<UpdateSolicitudStateNotifier, AsyncValue<void>>((
      ref,
    ) {
      return UpdateSolicitudStateNotifier(
        ref.read(solicitudRepositoryProvider),
        ref.read(mascotaRepositoryProvider),
      );
    });

class UpdateSolicitudStateNotifier extends StateNotifier<AsyncValue<void>> {
  final SolicitudRepository solicitudRepository;
  final MascotaRepository mascotaRepository;

  UpdateSolicitudStateNotifier(this.solicitudRepository, this.mascotaRepository)
    : super(const AsyncValue.data(null));

  Future<void> updateEstado(
    String solicitudId,
    String nuevoEstado,
    String? mascotaId,
  ) async {
    state = const AsyncValue.loading();

    try {
      // Actualizar estado de la solicitud
      print('🔄 Actualizando solicitud $solicitudId a estado: $nuevoEstado');

      await solicitudRepository.updateSolicitudEstado(solicitudId, nuevoEstado);

      // Si se aprobó, cambiar el estado de la mascota a "adoptado"
      if (nuevoEstado == 'aprobada' && mascotaId != null) {
        print('🐕 Marcando mascota $mascotaId como adoptada');
        await mascotaRepository.updateMascota(mascotaId, {
          'estado': 'adoptado',
        });
      }

      print('✅ Solicitud actualizada correctamente');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      print('❌ Error actualizando solicitud: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
