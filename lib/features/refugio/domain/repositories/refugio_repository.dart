import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/refugio_entity.dart';

abstract class RefugioRepository {
  Future<Either<Failure, RefugioEntity>> getRefugioByUserId(String userId);
  Future<Either<Failure, RefugioEntity>> updateRefugio({
    required String refugioId,
    String? nombreRefugio,
    String? descripcion,
    String? direccion,
    double? lat,
    double? lng,
    String? telefono,
    String? sitioWeb,
  });
}
