import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/refugio_map_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapDataSource dataSource;

  MapRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Position>> getUserLocation() async {
    try {
      final position = await dataSource.getUserLocation();
      return Right(position);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RefugioMapEntity>>> getNearbyRefugios({
    required double lat,
    required double lng,
    double radiusKm = 50,
  }) async {
    try {
      final refugios = await dataSource.getNearbyRefugios(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );
      return Right(refugios.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
