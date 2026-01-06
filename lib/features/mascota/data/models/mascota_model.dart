import '../../domain/entities/mascota_entity.dart';

class MascotaModel extends MascotaEntity {
  const MascotaModel({
    required super.id,
    required super.refugioId,
    required super.nombre,
    required super.especie,
    required super.raza,
    super.tamano,
    super.edadMeses,
    super.genero,
    super.descripcion,
    super.fotoUrls,
    super.estadoSalud,
    super.rasgosPersonalidad,
    super.vacunado,
    super.esterilizado,
    super.requiereCuidadosEspeciales,
    super.notasAdicionales,
    super.estado,
    required super.createdAt,
  });

  factory MascotaModel.fromJson(Map<String, dynamic> json) {
    return MascotaModel(
      id: json['id'] as String,
      refugioId: json['refugio_id'] as String,
      nombre: json['nombre'] as String,
      especie: json['especie'] as String,
      raza: json['raza'] as String,
      tamano: json['tamano'] as String?,
      edadMeses: json['edad_meses'] as int?,
      genero: json['genero'] as String?,
      descripcion: json['descripcion'] as String?,
      fotoUrls: json['foto_urls'] != null
          ? List<String>.from(json['foto_urls'] as List)
          : [],
      estadoSalud: json['estado_salud'] != null
          ? List<String>.from(json['estado_salud'] as List)
          : [],
      rasgosPersonalidad: json['rasgos_personalidad'] != null
          ? List<String>.from(json['rasgos_personalidad'] as List)
          : [],
      vacunado: json['vacunado'] as bool? ?? false,
      esterilizado: json['esterilizado'] as bool? ?? false,
      requiereCuidadosEspeciales:
          json['requiere_cuidados_especiales'] as bool? ?? false,
      notasAdicionales: json['notas_adicionales'] as String?,
      estado: json['estado'] as String? ?? 'disponible',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refugio_id': refugioId,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'tamano': tamano,
      'edad_meses': edadMeses,
      'genero': genero,
      'descripcion': descripcion,
      'foto_urls': fotoUrls,
      'estado_salud': estadoSalud,
      'rasgos_personalidad': rasgosPersonalidad,
      'vacunado': vacunado,
      'esterilizado': esterilizado,
      'requiere_cuidados_especiales': requiereCuidadosEspeciales,
      'notas_adicionales': notasAdicionales,
      'estado': estado,
    };
  }
}
