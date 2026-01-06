import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/solicitud_entity.dart';
import '../repositories/solicitud_repository.dart';

class CreateSolicitudUseCase {
  final SolicitudRepository repository;

  CreateSolicitudUseCase(this.repository);

  Future<Either<Failure, SolicitudEntity>> call({
    required String adoptanteId,
    required String mascotaId,
    required String refugioId,
    String? notasAprobacion,
  }) async {
    return await repository.createSolicitud(
      adoptanteId,
      mascotaId,
      refugioId,
      notasAprobacion,
    );
  }
}
