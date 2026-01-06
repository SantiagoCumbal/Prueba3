import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/solicitud_entity.dart';

abstract class SolicitudRepository {
  Future<Either<Failure, SolicitudEntity>> createSolicitud(
    String adoptanteId,
    String mascotaId,
    String refugioId,
    String? notasAprobacion,
  );
  Future<Either<Failure, List<SolicitudEntity>>> getSolicitudesByAdoptante(
    String adoptanteId,
  );
  Future<Either<Failure, List<SolicitudEntity>>> getSolicitudesByRefugio(
    String refugioId,
  );
  Future<Either<Failure, void>> updateSolicitudEstado(
    String solicitudId,
    String nuevoEstado,
  );
}
