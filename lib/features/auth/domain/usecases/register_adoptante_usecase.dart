import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterAdoptanteParams {
  final String email;
  final String password;
  final String nombre;
  final String? telefono;

  RegisterAdoptanteParams({
    required this.email,
    required this.password,
    required this.nombre,
    this.telefono,
  });
}

class RegisterAdoptanteUseCase
    implements UseCase<UserEntity, RegisterAdoptanteParams> {
  final AuthRepository repository;

  RegisterAdoptanteUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
    RegisterAdoptanteParams params,
  ) async {
    return await repository.registerAdoptante(
      email: params.email,
      password: params.password,
      nombre: params.nombre,
      telefono: params.telefono,
    );
  }
}
