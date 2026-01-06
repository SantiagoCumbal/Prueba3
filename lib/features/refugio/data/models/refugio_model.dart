import '../../domain/entities/refugio_entity.dart';

class RefugioModel extends RefugioEntity {
  const RefugioModel({
    required super.id,
    required super.userId,
    required super.nombreRefugio,
    super.descripcion,
    required super.direccion,
    required super.lat,
    required super.lng,
    super.telefono,
    super.email,
    super.sitioWeb,
    super.logoUrl,
    required super.totalMascotas,
    required super.mascotasAdoptadas,
    required super.solicitudesPendientes,
  });

  factory RefugioModel.fromJson(Map<String, dynamic> json) {
    return RefugioModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nombreRefugio: json['nombre_refugio'] as String,
      descripcion: json['descripcion'] as String?,
      direccion: json['direccion'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      sitioWeb: json['sitio_web'] as String?,
      logoUrl: json['logo_url'] as String?,
      totalMascotas: json['total_mascotas'] as int? ?? 0,
      mascotasAdoptadas: json['mascotas_adoptadas'] as int? ?? 0,
      solicitudesPendientes: json['solicitudes_pendientes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nombre_refugio': nombreRefugio,
      'descripcion': descripcion,
      'direccion': direccion,
      'lat': lat,
      'lng': lng,
      'telefono': telefono,
      'email': email,
      'sitio_web': sitioWeb,
      'logo_url': logoUrl,
      'total_mascotas': totalMascotas,
      'mascotas_adoptadas': mascotasAdoptadas,
      'solicitudes_pendientes': solicitudesPendientes,
    };
  }

  RefugioEntity toEntity() {
    return RefugioEntity(
      id: id,
      userId: userId,
      nombreRefugio: nombreRefugio,
      descripcion: descripcion,
      direccion: direccion,
      lat: lat,
      lng: lng,
      telefono: telefono,
      email: email,
      sitioWeb: sitioWeb,
      logoUrl: logoUrl,
      totalMascotas: totalMascotas,
      mascotasAdoptadas: mascotasAdoptadas,
      solicitudesPendientes: solicitudesPendientes,
    );
  }
}
