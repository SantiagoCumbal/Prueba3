import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../mascota/presentation/providers/mascota_providers.dart';
import '../../../../mascota/domain/entities/mascota_entity.dart';
import '../../../../mascota/presentation/pages/mascota_detail_screen.dart';
import '../../../../mascota/presentation/pages/edit_mascota_screen.dart';
import 'refugio_mascota_item_widget.dart';

class RefugioMascotasSectionWidget extends ConsumerWidget {
  final VoidCallback onAddMascota;
  final String refugioId;

  const RefugioMascotasSectionWidget({
    super.key,
    required this.onAddMascota,
    required this.refugioId,
  });

  Future<void> _deleteMascota(
    BuildContext context,
    WidgetRef ref,
    MascotaEntity mascota,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mascota'),
        content: Text('¿Estás seguro de eliminar a ${mascota.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final repository = ref.read(mascotaRepositoryProvider);
      final result = await repository.deleteMascota(mascota.id);

      result.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (_) {
          ref.invalidate(mascotasByRefugioProvider(refugioId));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mascota eliminada correctamente')),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mascotasAsync = ref.watch(mascotasByRefugioProvider(refugioId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Mascotas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ref.invalidate(mascotasByRefugioProvider(refugioId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recargando mascotas...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Recargar',
                  ),
                  ElevatedButton.icon(
                    onPressed: onAddMascota,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          mascotasAsync.when(
            data: (mascotas) {
              if (mascotas.isEmpty) {
                return const Text(
                  'No hay mascotas registradas',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mascotas.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final mascota = mascotas[index];
                  return RefugioMascotaItemWidget(
                    mascota: mascota,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MascotaDetailScreen(mascota: mascota),
                        ),
                      );
                    },
                    onEdit: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditMascotaScreen(mascota: mascota),
                        ),
                      );

                      if (result == true) {
                        ref.invalidate(mascotasByRefugioProvider(refugioId));
                      }
                    },
                    onDelete: () => _deleteMascota(context, ref, mascota),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
              ),
            ),
            error: (error, stack) => Text(
              'Error cargando mascotas: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
