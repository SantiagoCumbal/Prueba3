import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/mascota_entity.dart';
import '../../domain/repositories/mascota_repository.dart';
import '../datasources/mascota_datasource.dart';

class MascotaRepositoryImpl implements MascotaRepository {
  final MascotaDataSource dataSource;

  MascotaRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<MascotaEntity>>> getMascotasByRefugioId(
    String refugioId,
  ) async {
    try {
      final mascotas = await dataSource.getMascotasByRefugioId(refugioId);
      return Right(mascotas);
    } catch (e) {
      return Left(ServerFailure('Error al obtener mascotas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MascotaEntity>>> getMascotasDisponibles({
    String? adoptanteId,
  }) async {
    try {
      final mascotas = await dataSource.getMascotasDisponibles(
        adoptanteId: adoptanteId,
      );
      return Right(mascotas);
    } catch (e) {
      return Left(ServerFailure('Error al obtener mascotas disponibles: $e'));
    }
  }

  @override
  Future<Either<Failure, MascotaEntity>> createMascota(
    MascotaEntity mascota,
  ) async {
    try {
      final mascotaModel = await dataSource.createMascota(mascota as dynamic);
      return Right(mascotaModel);
    } catch (e) {
      return Left(ServerFailure('Error al crear mascota: $e'));
    }
  }

  @override
  Future<Either<Failure, MascotaEntity>> updateMascota(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final mascotaModel = await dataSource.updateMascota(id, updates);
      return Right(mascotaModel);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar mascota: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMascota(String id) async {
    try {
      await dataSource.deleteMascota(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar mascota: $e'));
    }
  }
}
