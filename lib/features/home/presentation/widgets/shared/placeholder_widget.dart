import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class PlaceholderWidget extends StatelessWidget {
  final String title;
  final IconData iconData;

  const PlaceholderWidget({
    super.key,
    required this.title,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 80, color: AppColors.primaryOrange),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente',
            style: TextStyle(fontSize: 16, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}
