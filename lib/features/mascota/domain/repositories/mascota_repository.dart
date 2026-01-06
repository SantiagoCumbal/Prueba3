import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mascota_entity.dart';

abstract class MascotaRepository {
  Future<Either<Failure, List<MascotaEntity>>> getMascotasByRefugioId(
    String refugioId,
  );
  Future<Either<Failure, List<MascotaEntity>>> getMascotasDisponibles({
    String? adoptanteId,
  });
  Future<Either<Failure, MascotaEntity>> createMascota(MascotaEntity mascota);
  Future<Either<Failure, MascotaEntity>> updateMascota(
    String id,
    Map<String, dynamic> updates,
  );
  Future<Either<Failure, void>> deleteMascota(String id);
}
