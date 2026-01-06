import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

class ProfileModel extends Equatable {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String? telefono;
  final String? direccion;
  final double? lat;
  final double? lng;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
    this.direccion,
    this.lat,
    this.lng,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir ProfileModel a UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      nombre: nombre,
      rol: rol,
      telefono: telefono,
      direccion: direccion,
      lat: lat,
      lng: lng,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      lat: json['lat'] as double?,
      lng: json['lng'] as double?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'telefono': telefono,
      'direccion': direccion,
      'lat': lat,
      'lng': lng,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    email,
    rol,
    telefono,
    direccion,
    lat,
    lng,
    avatarUrl,
    createdAt,
    updatedAt,
  ];
}
