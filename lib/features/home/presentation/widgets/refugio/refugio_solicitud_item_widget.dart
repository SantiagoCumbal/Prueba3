import 'package:flutter/material.dart';

class RefugioSolicitudItemWidget extends StatelessWidget {
  final String mascotaNombre;
  final String adoptanteNombre;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const RefugioSolicitudItemWidget({
    super.key,
    required this.mascotaNombre,
    required this.adoptanteNombre,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
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
            ),
            child: const Icon(
              Icons.pets,
              color: Color(0xFFFF8A00),
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitud para $mascotaNombre',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'De: $adoptanteNombre',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onApprove,
            icon: const Icon(Icons.check_circle),
            color: Colors.green,
            iconSize: 28,
          ),
          IconButton(
            onPressed: onReject,
            icon: const Icon(Icons.cancel),
            color: Colors.red,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}
