import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Clase base para todos los UseCases
/// T = Tipo de retorno
/// Params = Parámetros de entrada
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Para UseCases sin parámetros
class NoParams {}
