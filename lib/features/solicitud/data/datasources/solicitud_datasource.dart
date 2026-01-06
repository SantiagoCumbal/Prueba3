import '../../../../core/config/supabase_config.dart';
import '../models/solicitud_model.dart';

abstract class SolicitudDataSource {
  Future<SolicitudModel> createSolicitud(
    String adoptanteId,
    String mascotaId,
    String refugioId,
    String? notasAprobacion,
  );
  Future<List<SolicitudModel>> getSolicitudesByAdoptante(String adoptanteId);
  Future<List<SolicitudModel>> getSolicitudesByRefugio(String refugioId);
  Future<void> updateSolicitudEstado(String solicitudId, String nuevoEstado);
}

class SolicitudDataSourceImpl implements SolicitudDataSource {
  final supabase = SupabaseConfig.client;

  @override
  Future<SolicitudModel> createSolicitud(
    String adoptanteId,
    String mascotaId,
    String refugioId,
    String? notasAprobacion,
  ) async {
    try {
      print('📝 Creando solicitud de adopción');

      final response = await supabase
          .from('solicitudes')
          .insert({
            'adoptante_id': adoptanteId,
            'mascota_id': mascotaId,
            'refugio_id': refugioId,
            'estado': 'pendiente',
            'notas_aprobacion': notasAprobacion,
          })
          .select()
          .single();

      print('✅ Solicitud creada con ID: ${response['id']}');
      return SolicitudModel.fromJson(response);
    } catch (e) {
      print('❌ Error creando solicitud: $e');
      throw Exception('Error al crear solicitud: $e');
    }
  }

  @override
  Future<List<SolicitudModel>> getSolicitudesByAdoptante(
    String adoptanteId,
  ) async {
    try {
      print('📋 Obteniendo solicitudes del adoptante: $adoptanteId');

      final response = await supabase
          .from('solicitudes')
          .select()
          .eq('adoptante_id', adoptanteId)
          .order('created_at', ascending: false);

      print('✅ ${response.length} solicitudes encontradas');
      print('🔍 Datos recibidos: $response');

      // Obtener los nombres de mascotas y refugios separadamente
      List<SolicitudModel> solicitudes = [];

      for (var json in (response as List)) {
        print('📦 Procesando solicitud: ${json['id']}');

        // Obtener nombre y foto de mascota
        String mascotaNombre = '';
        String mascotaFoto = '';
        try {
          final mascotaResponse = await supabase
              .from('mascotas')
              .select('nombre, foto_urls')
              .eq('id', json['mascota_id'])
              .single();
          mascotaNombre = mascotaResponse['nombre'] ?? '';
          final fotoUrls = mascotaResponse['foto_urls'] as List?;
          mascotaFoto = (fotoUrls != null && fotoUrls.isNotEmpty)
              ? fotoUrls[0]
              : '';
        } catch (e) {
          print('⚠️ Error obteniendo mascota: $e');
        }

        // Obtener nombre de refugio
        String refugioNombre = '';
        try {
          final refugioResponse = await supabase
              .from('refugios')
              .select('nombre_refugio')
              .eq('id', json['refugio_id'])
              .single();
          refugioNombre = refugioResponse['nombre_refugio'] ?? '';
        } catch (e) {
          print('⚠️ Error obteniendo refugio: $e');
        }

        solicitudes.add(
          SolicitudModel.fromJson({
            ...json,
            'mascota_nombre': mascotaNombre,
            'refugio_nombre': refugioNombre,
            'mascota_foto': mascotaFoto,
          }),
        );
      }

      print('✅ ${solicitudes.length} solicitudes procesadas con nombres');
      return solicitudes;
    } catch (e, stackTrace) {
      print('❌ Error obteniendo solicitudes: $e');
      print('❌ StackTrace: $stackTrace');
      throw Exception('Error al obtener solicitudes: $e');
    }
  }

  @override
  Future<List<SolicitudModel>> getSolicitudesByRefugio(String refugioId) async {
    try {
      print('📋 Obteniendo solicitudes del refugio: $refugioId');

      final response = await supabase
          .from('solicitudes')
          .select()
          .eq('refugio_id', refugioId)
          .order('created_at', ascending: false);

      print('✅ ${response.length} solicitudes encontradas');

      // Obtener los nombres de mascotas y adoptantes separadamente
      List<SolicitudModel> solicitudes = [];

      for (var json in (response as List)) {
        // Obtener nombre de mascota
        String mascotaNombre = '';
        try {
          final mascotaResponse = await supabase
              .from('mascotas')
              .select('nombre')
              .eq('id', json['mascota_id'])
              .single();
          mascotaNombre = mascotaResponse['nombre'] ?? '';
        } catch (e) {
          print('⚠️ Error obteniendo mascota: $e');
        }

        // Obtener nombre de adoptante
        String adoptanteNombre = '';
        try {
          final adoptanteResponse = await supabase
              .from('profiles')
              .select('nombre')
              .eq('id', json['adoptante_id'])
              .single();
          adoptanteNombre = adoptanteResponse['nombre'] ?? '';
        } catch (e) {
          print('⚠️ Error obteniendo adoptante: $e');
        }

        solicitudes.add(
          SolicitudModel.fromJson({
            ...json,
            'mascota_nombre': mascotaNombre,
            'refugio_nombre':
                adoptanteNombre, // En este caso es el nombre del adoptante
          }),
        );
      }

      return solicitudes;
    } catch (e) {
      print('❌ Error obteniendo solicitudes: $e');
      throw Exception('Error al obtener solicitudes: $e');
    }
  }

  @override
  Future<void> updateSolicitudEstado(
    String solicitudId,
    String nuevoEstado,
  ) async {
    try {
      print('📝 Actualizando solicitud $solicitudId a estado: $nuevoEstado');

      await supabase
          .from('solicitudes')
          .update({
            'estado': nuevoEstado,
            'fecha_aprobacion': nuevoEstado == 'aprobada'
                ? DateTime.now().toIso8601String()
                : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', solicitudId);

      print('✅ Solicitud actualizada correctamente');
    } catch (e) {
      print('❌ Error actualizando solicitud: $e');
      throw Exception('Error al actualizar solicitud: $e');
    }
  }
}
