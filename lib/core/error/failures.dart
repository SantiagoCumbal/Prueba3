import 'package:equatable/equatable.dart';

/// Clase base para todos los errores
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Errores de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Errores de red
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Errores de caché
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Error genérico
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
