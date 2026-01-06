import '../../domain/entities/refugio_map_entity.dart';

/// Modelo de datos para refugios en el mapa
class RefugioMapModel extends RefugioMapEntity {
  const RefugioMapModel({
    required super.id,
    required super.nombre,
    required super.direccion,
    required super.lat,
    required super.lng,
    required super.totalMascotas,
    super.logoUrl,
    super.telefono,
  });

  /// Factory desde JSON (de Supabase)
  factory RefugioMapModel.fromJson(Map<String, dynamic> json) {
    return RefugioMapModel(
      id: json['id'] as String,
      nombre: json['nombre_refugio'] as String,
      direccion: json['direccion'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      totalMascotas: json['total_mascotas'] as int? ?? 0,
      logoUrl: json['logo_url'] as String?,
      telefono: json['telefono'] as String?,
    );
  }

  /// Convertir a entidad
  RefugioMapEntity toEntity() {
    return RefugioMapEntity(
      id: id,
      nombre: nombre,
      direccion: direccion,
      lat: lat,
      lng: lng,
      totalMascotas: totalMascotas,
      logoUrl: logoUrl,
      telefono: telefono,
    );
  }
}
