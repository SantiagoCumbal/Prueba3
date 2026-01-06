import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/mascota_datasource.dart';
import '../../data/repositories/mascota_repository_impl.dart';
import '../../domain/repositories/mascota_repository.dart';
import '../../domain/entities/mascota_entity.dart';

final mascotaDataSourceProvider = Provider<MascotaDataSource>((ref) {
  return MascotaDataSourceImpl();
});

final mascotaRepositoryProvider = Provider<MascotaRepository>((ref) {
  final dataSource = ref.read(mascotaDataSourceProvider);
  return MascotaRepositoryImpl(dataSource);
});

// Provider para obtener mascotas por refugio ID
final mascotasByRefugioProvider =
    FutureProvider.family<List<MascotaEntity>, String>((ref, refugioId) async {
      final repository = ref.read(mascotaRepositoryProvider);
      final result = await repository.getMascotasByRefugioId(refugioId);

      return result.fold((failure) {
        print('❌ Error obteniendo mascotas: ${failure.message}');
        return [];
      }, (mascotas) => mascotas);
    });

// Provider para contar mascotas por estado
final mascotasCountProvider = FutureProvider.family<Map<String, int>, String>((
  ref,
  refugioId,
) async {
  final mascotasAsync = await ref.watch(
    mascotasByRefugioProvider(refugioId).future,
  );

  final total = mascotasAsync.length;
  final disponibles = mascotasAsync
      .where((m) => m.estado == 'disponible')
      .length;
  final adoptadas = mascotasAsync.where((m) => m.estado == 'adoptado').length;
  final enProceso = mascotasAsync.where((m) => m.estado == 'en_proceso').length;

  return {
    'total': total,
    'disponibles': disponibles,
    'adoptadas': adoptadas,
    'en_proceso': enProceso,
  };
});

// Provider para obtener todas las mascotas disponibles (para adoptantes)
// Filtra las mascotas que ya tienen solicitud del usuario actual
final mascotasDisponiblesProvider = FutureProvider.family
    .autoDispose<List<MascotaEntity>, String?>((ref, adoptanteId) async {
      print('🔄 Cargando mascotas disponibles (siempre busca datos frescos)');
      final repository = ref.read(mascotaRepositoryProvider);
      final result = await repository.getMascotasDisponibles(
        adoptanteId: adoptanteId,
      );

      return result.fold(
        (failure) {
          print('❌ Error obteniendo mascotas disponibles: ${failure.message}');
          return [];
        },
        (mascotas) {
          print('✅ ${mascotas.length} mascotas disponibles cargadas');
          return mascotas;
        },
      );
    });
