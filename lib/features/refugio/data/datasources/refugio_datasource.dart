import '../../../../core/config/supabase_config.dart';
import '../models/refugio_model.dart';

abstract class RefugioDataSource {
  Future<RefugioModel> getRefugioByUserId(String userId);
  Future<RefugioModel> updateRefugio({
    required String refugioId,
    Map<String, dynamic> updates,
  });
}

class RefugioDataSourceImpl implements RefugioDataSource {
  final supabase = SupabaseConfig.client;

  @override
  Future<RefugioModel> getRefugioByUserId(String userId) async {
    try {
      print('🏠 Obteniendo refugio para userId: $userId');

      final response = await supabase
          .from('refugios')
          .select()
          .eq('user_id', userId)
          .single();

      print('✅ Refugio obtenido: ${response['nombre_refugio']}');
      return RefugioModel.fromJson(response);
    } catch (e) {
      print('❌ Error obteniendo refugio: $e');
      throw Exception('Error al obtener datos del refugio: $e');
    }
  }

  @override
  Future<RefugioModel> updateRefugio({
    required String refugioId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      print('📝 Actualizando refugio: $refugioId');

      if (updates != null && updates.isNotEmpty) {
        await supabase.from('refugios').update(updates).eq('id', refugioId);
      }

      final response = await supabase
          .from('refugios')
          .select()
          .eq('id', refugioId)
          .single();

      print('✅ Refugio actualizado');
      return RefugioModel.fromJson(response);
    } catch (e) {
      print('❌ Error actualizando refugio: $e');
      throw Exception('Error al actualizar refugio: $e');
    }
  }
}
