import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/refugio_map_entity.dart';
import 'package:geolocator/geolocator.dart';

/// Repository interface para el mapa
abstract class MapRepository {
  /// Obtener ubicación actual del usuario
  Future<Either<Failure, Position>> getUserLocation();

  /// Obtener refugios cercanos
  Future<Either<Failure, List<RefugioMapEntity>>> getNearbyRefugios({
    required double lat,
    required double lng,
    double radiusKm = 50,
  });
}
