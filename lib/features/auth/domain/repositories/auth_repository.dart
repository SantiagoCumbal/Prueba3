import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Repository abstracto (interface) - Domain Layer
/// Define QUÉ se puede hacer, NO CÓMO
abstract class AuthRepository {
  /// Login con email y contraseña
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registro de usuario adoptante
  Future<Either<Failure, UserEntity>> registerAdoptante({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
  });

  /// Registro de usuario refugio
  Future<Either<Failure, UserEntity>> registerRefugio({
    required String email,
    required String password,
    required String nombre,
    required String nombreRefugio,
    required String direccion,
    required double lat,
    required double lng,
    String? telefono,
    String? descripcion,
  });

  /// Login con Google (OAuth)
  Future<Either<Failure, UserEntity>> loginWithGoogle();

  /// Cerrar sesión
  Future<Either<Failure, void>> logout();

  /// Obtener usuario actual
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Recuperar contraseña
  Future<Either<Failure, void>> resetPassword({required String email});

  /// Verificar si hay sesión activa
  Future<bool> isLoggedIn();
}
