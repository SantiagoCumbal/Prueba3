import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> registerAdoptante({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) async {
    try {
      final profile = await remoteDataSource.registerAdoptante(
        nombre: nombre,
        email: email,
        password: password,
        telefono: telefono,
      );
      return Right(profile.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerRefugio({
    required String nombre,
    required String email,
    required String password,
    required String nombreRefugio,
    required String direccion,
    required double lat,
    required double lng,
    String? telefono,
    String? descripcion,
  }) async {
    try {
      final profile = await remoteDataSource.registerRefugio(
        nombre: nombre,
        email: email,
        password: password,
        nombreRefugio: nombreRefugio,
        direccion: direccion,
        lat: lat,
        lng: lng,
        telefono: telefono,
      );
      return Right(profile.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final profile = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(profile.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      // TODO: Implementar Google OAuth
      throw UnimplementedError('Google OAuth no implementado aún');
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final profile = await remoteDataSource.getCurrentUser();
      return Right(profile?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final result = await getCurrentUser();
      return result.fold((failure) => false, (user) => user != null);
    } catch (e) {
      return false;
    }
  }
}
