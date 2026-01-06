import '../../../../core/config/supabase_config.dart';
import '../models/mascota_model.dart';

abstract class MascotaDataSource {
  Future<List<MascotaModel>> getMascotasByRefugioId(String refugioId);
  Future<List<MascotaModel>> getMascotasDisponibles({String? adoptanteId});
  Future<MascotaModel> createMascota(MascotaModel mascota);
  Future<MascotaModel> updateMascota(String id, Map<String, dynamic> updates);
  Future<void> deleteMascota(String id);
}

class MascotaDataSourceImpl implements MascotaDataSource {
  final supabase = SupabaseConfig.client;

  @override
  Future<List<MascotaModel>> getMascotasByRefugioId(String refugioId) async {
    try {
      print('🐕 Obteniendo mascotas para refugio: $refugioId');

      final response = await supabase
          .from('mascotas')
          .select()
          .eq('refugio_id', refugioId)
          .order('created_at', ascending: false);

      print('✅ ${response.length} mascotas encontradas');
      return (response as List)
          .map((json) => MascotaModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo mascotas: $e');
      throw Exception('Error al obtener mascotas: $e');
    }
  }

  @override
  Future<List<MascotaModel>> getMascotasDisponibles({
    String? adoptanteId,
  }) async {
    try {
      print('🐕 Obteniendo mascotas disponibles para adoptante: $adoptanteId');

      if (adoptanteId == null) {
        // Si no hay adoptante, devolver todas las disponibles
        final response = await supabase
            .from('mascotas')
            .select()
            .eq('estado', 'disponible')
            .order('created_at', ascending: false);

        print('✅ ${response.length} mascotas disponibles encontradas');
        return (response as List)
            .map((json) => MascotaModel.fromJson(json))
            .toList();
      }

      // Obtener IDs de mascotas que ya tienen solicitud del adoptante
      final solicitudesResponse = await supabase
          .from('solicitudes')
          .select('mascota_id')
          .eq('adoptante_id', adoptanteId);

      final mascotasConSolicitud = (solicitudesResponse as List)
          .map((s) => s['mascota_id'] as String)
          .toSet();

      print(
        '🚫 Mascotas con solicitud del usuario: ${mascotasConSolicitud.length}',
      );

      // Obtener mascotas disponibles
      final mascotasResponse = await supabase
          .from('mascotas')
          .select()
          .eq('estado', 'disponible')
          .order('created_at', ascending: false);

      // Filtrar las que ya tienen solicitud
      final mascotasFiltradas = (mascotasResponse as List)
          .map((json) => MascotaModel.fromJson(json))
          .where((mascota) => !mascotasConSolicitud.contains(mascota.id))
          .toList();

      print(
        '✅ ${mascotasFiltradas.length} mascotas disponibles (sin solicitudes previas)',
      );
      return mascotasFiltradas;
    } catch (e) {
      print('❌ Error obteniendo mascotas disponibles: $e');
      throw Exception('Error al obtener mascotas disponibles: $e');
    }
  }

  @override
  Future<MascotaModel> createMascota(MascotaModel mascota) async {
    try {
      print('📝 Creando mascota: ${mascota.nombre}');

      final response = await supabase
          .from('mascotas')
          .insert(mascota.toJson())
          .select()
          .single();

      print('✅ Mascota creada con ID: ${response['id']}');
      return MascotaModel.fromJson(response);
    } catch (e) {
      print('❌ Error creando mascota: $e');
      throw Exception('Error al crear mascota: $e');
    }
  }

  @override
  Future<MascotaModel> updateMascota(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('📝 Actualizando mascota: $id');

      await supabase.from('mascotas').update(updates).eq('id', id);

      final response = await supabase
          .from('mascotas')
          .select()
          .eq('id', id)
          .single();

      print('✅ Mascota actualizada');
      return MascotaModel.fromJson(response);
    } catch (e) {
      print('❌ Error actualizando mascota: $e');
      throw Exception('Error al actualizar mascota: $e');
    }
  }

  @override
  Future<void> deleteMascota(String id) async {
    try {
      print('🗑️ Eliminando mascota: $id');

      await supabase.from('mascotas').delete().eq('id', id);

      print('✅ Mascota eliminada');
    } catch (e) {
      print('❌ Error eliminando mascota: $e');
      throw Exception('Error al eliminar mascota: $e');
    }
  }
}
