import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterRefugioParams {
  final String email;
  final String password;
  final String nombre;
  final String nombreRefugio;
  final String direccion;
  final double lat;
  final double lng;
  final String? telefono;
  final String? descripcion;

  RegisterRefugioParams({
    required this.email,
    required this.password,
    required this.nombre,
    required this.nombreRefugio,
    required this.direccion,
    required this.lat,
    required this.lng,
    this.telefono,
    this.descripcion,
  });
}

class RegisterRefugioUseCase
    implements UseCase<UserEntity, RegisterRefugioParams> {
  final AuthRepository repository;

  RegisterRefugioUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterRefugioParams params) async {
    return await repository.registerRefugio(
      email: params.email,
      password: params.password,
      nombre: params.nombre,
      nombreRefugio: params.nombreRefugio,
      direccion: params.direccion,
      lat: params.lat,
      lng: params.lng,
      telefono: params.telefono,
      descripcion: params.descripcion,
    );
  }
}
