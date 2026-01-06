import 'package:geolocator/geolocator.dart';
import '../models/refugio_map_model.dart';

abstract class MapDataSource {
  Future<Position> getUserLocation();
  Future<List<RefugioMapModel>> getNearbyRefugios({
    required double lat,
    required double lng,
    double radiusKm = 50,
  });
}

class MapDataSourceImpl implements MapDataSource {
  @override
  Future<Position> getUserLocation() async {
    try {
      print('📍 Verificando permisos de ubicación...');

      // Verificar si el servicio está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados');
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permisos de ubicación denegados permanentemente. '
          'Habilita los permisos en configuración.',
        );
      }

      print('✅ Permisos OK, obteniendo ubicación...');

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
        '✅ Ubicación obtenida: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      rethrow;
    }
  }

  @override
  Future<List<RefugioMapModel>> getNearbyRefugios({
    required double lat,
    required double lng,
    double radiusKm = 50,
  }) async {
    try {
      print('🏠 Obteniendo refugios cercanos...');

      // TODO: Cuando haya refugios reales en Supabase, descomentar esto:
      /*
      final supabase = SupabaseConfig.client;
      final response = await supabase
          .from('refugios')
          .select('id, nombre_refugio, direccion, lat, lng, total_mascotas, logo_url, telefono')
          .gte('lat', lat - (radiusKm / 111)) // Aproximación: 1 grado ≈ 111 km
          .lte('lat', lat + (radiusKm / 111))
          .gte('lng', lng - (radiusKm / 111))
          .lte('lng', lng + (radiusKm / 111));

      final refugios = (response as List)
          .map((json) => RefugioMapModel.fromJson(json))
          .toList();
      
      return refugios;
      */

      // Por ahora: Datos mock de 2 refugios
      await Future.delayed(const Duration(milliseconds: 500));

      final mockRefugios = [
        RefugioMapModel(
          id: 'mock-1',
          nombre: 'Patitas Felices',
          direccion: 'Av. Principal #123, Quito',
          lat: lat + 0.01, // ~1km al norte
          lng: lng + 0.01,
          totalMascotas: 15,
          telefono: '+593 99 123 4567',
        ),
        RefugioMapModel(
          id: 'mock-2',
          nombre: 'Amigos Peludos',
          direccion: 'Calle Secundaria #456, Quito',
          lat: lat - 0.015, // ~1.5km al sur
          lng: lng + 0.02,
          totalMascotas: 23,
          telefono: '+593 98 765 4321',
        ),
      ];

      print('✅ ${mockRefugios.length} refugios encontrados');
      return mockRefugios;
    } catch (e) {
      print('❌ Error obteniendo refugios: $e');
      rethrow;
    }
  }
}
