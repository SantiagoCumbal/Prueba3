import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mascota_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../solicitud/presentation/providers/solicitud_state_provider.dart';
import '../../../solicitud/presentation/providers/solicitud_providers.dart';

class MascotaDetailAdoptanteScreen extends ConsumerWidget {
  final MascotaEntity mascota;

  const MascotaDetailAdoptanteScreen({super.key, required this.mascota});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudState = ref.watch(solicitudNotifierProvider);

    // Listener para mostrar mensajes
    ref.listen<SolicitudState>(solicitudNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      } else if (next.solicitud != null && !next.isLoading) {
        // Invalidar el provider de solicitudes para forzar refresh
        ref.invalidate(solicitudesByAdoptanteProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Solicitud de adopción enviada! 🧡'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () {
              // TODO: Agregar a favoritos
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de la mascota
                  _buildImageSection(),
                  const SizedBox(height: 16),

                  // Información principal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                mascota.nombre,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BCD4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Disponible',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mascota.especie == 'perro' ? 'Perro' : 'Gato',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        if (mascota.raza.isNotEmpty)
                          Text(
                            mascota.raza,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Datos principales
                        Row(
                          children: [
                            _buildInfoChip(
                              '${_getEdadTexto(mascota.edadMeses ?? 0)}',
                              'Edad',
                            ),
                            const SizedBox(width: 16),
                            _buildInfoChip(
                              _capitalize(mascota.genero ?? 'No especificado'),
                              'Sexo',
                            ),
                            const SizedBox(width: 16),
                            _buildInfoChip(
                              _capitalize(mascota.tamano ?? 'mediano'),
                              'Tamaño',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Información del refugio
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFE3F2FD),
                                child: Icon(
                                  Icons.home_outlined,
                                  color: Colors.blue[700],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Refugio Patitas Felices',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '2.5 km de distancia',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.phone,
                                  color: Colors.blue[700],
                                ),
                                onPressed: () {
                                  // TODO: Llamar al refugio
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Descripción
                        const Text(
                          'Sobre ${'' /* mascota.nombre */}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mascota.descripcion ?? 'Sin descripción',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 100), // Espacio para el botón
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: solicitudState.isLoading
                ? null
                : () => _onSolicitarAdopcion(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F3C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey,
            ),
            child: solicitudState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Solicitar Adopción',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('🧡', style: TextStyle(fontSize: 20)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSolicitarAdopcion(BuildContext context, WidgetRef ref) async {
    // Obtener usuario actual
    final authRepository = ref.read(authRepositoryProvider);
    final userResult = await authRepository.getCurrentUser();

    final userId = userResult.fold((failure) => null, (user) => user?.id);

    if (userId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Usar el StateNotifier para crear la solicitud
    await ref
        .read(solicitudNotifierProvider.notifier)
        .createSolicitud(
          adoptanteId: userId,
          mascotaId: mascota.id,
          refugioId: mascota.refugioId,
        );
  }

  Widget _buildImageSection() {
    if (mascota.fotoUrls.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
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
                child: const Center(child: Icon(Icons.error, size: 50)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6F3C),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  String _getEdadTexto(int edadMeses) {
    if (edadMeses < 12) {
      return '$edadMeses ${edadMeses == 1 ? 'mes' : 'meses'}';
    } else {
      final anos = (edadMeses / 12).floor();
      final meses = edadMeses % 12;
      if (meses == 0) {
        return '$anos ${anos == 1 ? 'año' : 'años'}';
      } else {
        return '$anos ${anos == 1 ? 'año' : 'años'}';
      }
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
