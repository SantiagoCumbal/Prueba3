import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class StorageService {
  final supabase = SupabaseConfig.client;
  final ImagePicker _picker = ImagePicker();

  Future<String?> subirFotoMascota(File imageFile, String mascotaId) async {
    try {
      print('📤 Subiendo foto para mascota: $mascotaId');
      print('📁 Ruta del archivo: ${imageFile.path}');

      final fileName =
          '${mascotaId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'mascotas/$fileName';

      // Leer los bytes del archivo
      print('📖 Leyendo bytes del archivo...');
      final bytes = await imageFile.readAsBytes();
      print('✅ Bytes leídos: ${bytes.length} bytes');

      print('⬆️ Subiendo a Supabase: bucket=fotos-mascotas, path=$path');
      final response = await supabase.storage
          .from('fotos-mascotas')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/jpeg',
              cacheControl: '3600',
              upsert: false,
            ),
          );

      print('🔍 Respuesta de Supabase: $response');

      final url = supabase.storage.from('fotos-mascotas').getPublicUrl(path);

      print('✅ Foto subida exitosamente: $url');
      return url;
    } catch (e, stackTrace) {
      print('❌ Error subiendo foto: $e');
      print('📋 StackTrace: $stackTrace');
      return null;
    }
  }

  Future<List<File>> seleccionarFotosGaleria({int maxImagenes = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isEmpty) {
        return [];
      }

      // Limitar a maxImagenes
      final imagenesSeleccionadas = images.take(maxImagenes).toList();

      return imagenesSeleccionadas.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('❌ Error seleccionando fotos: $e');
      return [];
    }
  }

  Future<File?> tomarFotoCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      print('❌ Error tomando foto: $e');
      return null;
    }
  }

  Future<bool> eliminarFotoMascota(String url) async {
    try {
      print('🗑️ Eliminando foto: $url');

      // Extraer path del URL
      final uri = Uri.parse(url);
      final path = uri.pathSegments.last;

      await supabase.storage.from('fotos-mascotas').remove(['mascotas/$path']);

      print('✅ Foto eliminada');
      return true;
    } catch (e) {
      print('❌ Error eliminando foto: $e');
      return false;
    }
  }
}
