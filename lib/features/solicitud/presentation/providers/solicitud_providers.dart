import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/solicitud_datasource.dart';
import '../../data/repositories/solicitud_repository_impl.dart';
import '../../domain/repositories/solicitud_repository.dart';
import '../../domain/entities/solicitud_entity.dart';

final solicitudDataSourceProvider = Provider<SolicitudDataSource>((ref) {
  return SolicitudDataSourceImpl();
});

final solicitudRepositoryProvider = Provider<SolicitudRepository>((ref) {
  final dataSource = ref.read(solicitudDataSourceProvider);
  return SolicitudRepositoryImpl(dataSource);
});

// Provider para crear solicitud
final createSolicitudProvider =
    FutureProvider.family<SolicitudEntity, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repository = ref.read(solicitudRepositoryProvider);
      final result = await repository.createSolicitud(
        params['adoptanteId'] as String,
        params['mascotaId'] as String,
        params['refugioId'] as String,
        params['notasAprobacion'] as String?,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (solicitud) => solicitud,
      );
    });

// Provider para obtener solicitudes por adoptante
final solicitudesByAdoptanteProvider = FutureProvider.family
    .autoDispose<List<SolicitudEntity>, String>((ref, adoptanteId) async {
      print(
        '🔄 Provider solicitudesByAdoptanteProvider llamado con ID: $adoptanteId',
      );
      final repository = ref.read(solicitudRepositoryProvider);
      final result = await repository.getSolicitudesByAdoptante(adoptanteId);

      return result.fold(
        (failure) {
          print('❌ Error obteniendo solicitudes: ${failure.message}');
          return [];
        },
        (solicitudes) {
          print('✅ Provider devolviendo ${solicitudes.length} solicitudes');
          return solicitudes;
        },
      );
    });

// Provider para obtener solicitudes por refugio
final solicitudesByRefugioProvider = FutureProvider.family
    .autoDispose<List<SolicitudEntity>, String>((ref, refugioId) async {
      final repository = ref.read(solicitudRepositoryProvider);
      final result = await repository.getSolicitudesByRefugio(refugioId);

      return result.fold((failure) {
        print('❌ Error obteniendo solicitudes: ${failure.message}');
        return [];
      }, (solicitudes) => solicitudes);
    });

// Provider para contar solicitudes pendientes del adoptante
final solicitudesPendientesCountProvider = FutureProvider.family
    .autoDispose<int, String>((ref, adoptanteId) async {
      final solicitudes = await ref.watch(
        solicitudesByAdoptanteProvider(adoptanteId).future,
      );
      return solicitudes.where((s) => s.estado == 'pendiente').length;
    });
