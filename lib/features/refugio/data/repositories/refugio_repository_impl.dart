import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/refugio_entity.dart';
import '../../domain/repositories/refugio_repository.dart';
import '../datasources/refugio_datasource.dart';

class RefugioRepositoryImpl implements RefugioRepository {
  final RefugioDataSource dataSource;

  RefugioRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, RefugioEntity>> getRefugioByUserId(
    String userId,
  ) async {
    try {
      final refugio = await dataSource.getRefugioByUserId(userId);
      return Right(refugio.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RefugioEntity>> updateRefugio({
    required String refugioId,
    String? nombreRefugio,
    String? descripcion,
    String? direccion,
    double? lat,
    double? lng,
    String? telefono,
    String? sitioWeb,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nombreRefugio != null) updates['nombre_refugio'] = nombreRefugio;
      if (descripcion != null) updates['descripcion'] = descripcion;
      if (direccion != null) updates['direccion'] = direccion;
      if (lat != null) updates['lat'] = lat;
      if (lng != null) updates['lng'] = lng;
      if (telefono != null) updates['telefono'] = telefono;
      if (sitioWeb != null) updates['sitio_web'] = sitioWeb;

      final refugio = await dataSource.updateRefugio(
        refugioId: refugioId,
        updates: updates,
      );

      return Right(refugio.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
