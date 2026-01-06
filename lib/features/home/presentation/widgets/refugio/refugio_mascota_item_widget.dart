import 'package:flutter/material.dart';
import '../../../../mascota/domain/entities/mascota_entity.dart';

class RefugioMascotaItemWidget extends StatelessWidget {
  final MascotaEntity mascota;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RefugioMascotaItemWidget({
    super.key,
    required this.mascota,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _getEstadoTexto() {
    switch (mascota.estado) {
      case 'disponible':
        return 'Disponible';
      case 'adoptado':
        return 'Adoptado';
      case 'en_proceso':
        return 'En Proceso';
      case 'no_disponible':
        return 'No Disponible';
      default:
        return 'Desconocido';
    }
  }

  Color _getEstadoColor() {
    switch (mascota.estado) {
      case 'disponible':
        return const Color(0xFF4CAF50);
      case 'adoptado':
        return const Color(0xFF9E9E9E);
      case 'en_proceso':
        return const Color(0xFFFFC107);
      case 'no_disponible':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoUrl = mascota.fotoUrls.isNotEmpty ? mascota.fotoUrls.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0B2),
              borderRadius: BorderRadius.circular(12),
              image: fotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(fotoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: fotoUrl == null
                ? const Icon(Icons.pets, color: Color(0xFFFF8A00), size: 32)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mascota.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getEstadoColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getEstadoTexto(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getEstadoColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.visibility),
            color: Colors.grey[600],
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            color: Colors.grey[600],
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            color: Colors.red[400],
          ),
        ],
      ),
    );
  }
}
