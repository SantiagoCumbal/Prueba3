import 'package:flutter/material.dart';
import '../../domain/entities/mascota_entity.dart';

class MascotaDetailScreen extends StatelessWidget {
  final MascotaEntity mascota;

  const MascotaDetailScreen({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(mascota.nombre),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de fotos
            if (mascota.fotoUrls.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: mascota.fotoUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      mascota.fotoUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.pets, size: 100),
                        );
                      },
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica
                  _buildSection('Información Básica', [
                    _buildInfoRow('Especie', _capitalize(mascota.especie)),
                    _buildInfoRow('Raza', mascota.raza ?? 'No especificada'),
                    _buildInfoRow(
                      'Tamaño',
                      mascota.tamano != null
                          ? _capitalize(mascota.tamano!)
                          : 'No especificado',
                    ),
                    _buildInfoRow(
                      'Género',
                      mascota.genero != null
                          ? _capitalize(mascota.genero!)
                          : 'No especificado',
                    ),
                    _buildInfoRow('Edad', '${mascota.edadMeses ?? 0} meses'),
                  ]),

                  const SizedBox(height: 24),

                  // Descripción
                  if (mascota.descripcion != null &&
                      mascota.descripcion!.isNotEmpty)
                    _buildSection('Descripción', [
                      Text(
                        mascota.descripcion!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ]),

                  const SizedBox(height: 24),

                  // Rasgos de personalidad
                  if (mascota.rasgosPersonalidad.isNotEmpty)
                    _buildSection('Personalidad', [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mascota.rasgosPersonalidad.map((rasgo) {
                          return Chip(
                            label: Text(rasgo),
                            backgroundColor: const Color(0xFFE0F7FA),
                            labelStyle: const TextStyle(
                              color: Color(0xFF00BCD4),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ]),

                  const SizedBox(height: 24),

                  // Estado de salud
                  _buildSection('Estado de Salud', [
                    _buildHealthStatus('Vacunado', mascota.vacunado),
                    _buildHealthStatus('Esterilizado', mascota.esterilizado),
                    _buildHealthStatus(
                      'Requiere cuidados especiales',
                      mascota.requiereCuidadosEspeciales,
                    ),
                    if (mascota.estadoSalud.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Condiciones:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...mascota.estadoSalud.map(
                        (condicion) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Color(0xFF4CAF50),
                              ),
                              const SizedBox(width: 8),
                              Text(condicion),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ]),

                  // Notas adicionales
                  if (mascota.notasAdicionales != null &&
                      mascota.notasAdicionales!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection('Notas Adicionales', [
                      Text(
                        mascota.notasAdicionales!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildHealthStatus(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? const Color(0xFF4CAF50) : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: value ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
