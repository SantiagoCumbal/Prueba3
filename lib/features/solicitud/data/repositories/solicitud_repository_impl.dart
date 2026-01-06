import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/solicitud_entity.dart';
import '../../domain/repositories/solicitud_repository.dart';
import '../datasources/solicitud_datasource.dart';

class SolicitudRepositoryImpl implements SolicitudRepository {
  final SolicitudDataSource dataSource;

  SolicitudRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, SolicitudEntity>> createSolicitud(
    String adoptanteId,
    String mascotaId,
    String refugioId,
    String? notasAprobacion,
  ) async {
    try {
      final solicitud = await dataSource.createSolicitud(
        adoptanteId,
        mascotaId,
        refugioId,
        notasAprobacion,
      );
      return Right(solicitud);
    } catch (e) {
      return Left(ServerFailure('Error al crear solicitud: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SolicitudEntity>>> getSolicitudesByAdoptante(
    String adoptanteId,
  ) async {
    try {
      print(
        '🏛️ Repository: Llamando dataSource.getSolicitudesByAdoptante($adoptanteId)',
      );
      final solicitudes = await dataSource.getSolicitudesByAdoptante(
        adoptanteId,
      );
      print(
        '🏛️ Repository: Recibidas ${solicitudes.length} solicitudes del datasource',
      );
      return Right(solicitudes);
    } catch (e) {
      print('🏛️ Repository: Error - $e');
      return Left(ServerFailure('Error al obtener solicitudes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SolicitudEntity>>> getSolicitudesByRefugio(
    String refugioId,
  ) async {
    try {
      final solicitudes = await dataSource.getSolicitudesByRefugio(refugioId);
      return Right(solicitudes);
    } catch (e) {
      return Left(ServerFailure('Error al obtener solicitudes: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSolicitudEstado(
    String solicitudId,
    String nuevoEstado,
  ) async {
    try {
      await dataSource.updateSolicitudEstado(solicitudId, nuevoEstado);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar solicitud: $e'));
    }
  }
}
