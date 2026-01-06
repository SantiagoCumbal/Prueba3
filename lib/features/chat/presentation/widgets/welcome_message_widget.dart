import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WelcomeMessageWidget extends StatelessWidget {
  const WelcomeMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.pets, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Hola! 👋',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Soy tu asistente de mascotas',
              style: TextStyle(fontSize: 18, color: AppColors.textGray),
            ),
            const SizedBox(height: 32),
            _buildSuggestionChip('🐕 ¿Cómo cuido a mi perro?'),
            const SizedBox(height: 12),
            _buildSuggestionChip('🐱 Consejos para gatos'),
            const SizedBox(height: 12),
            _buildSuggestionChip('🏥 Señales de alerta en mascotas'),
            const SizedBox(height: 12),
            _buildSuggestionChip('🍖 Alimentación saludable'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryOrange,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
