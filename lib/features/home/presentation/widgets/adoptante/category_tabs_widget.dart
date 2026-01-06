import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class CategoryTabsWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabsWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip('Todos', '🐾'),
          const SizedBox(width: 12),
          _buildCategoryChip('Perros', '🐕'),
          const SizedBox(width: 12),
          _buildCategoryChip('Gatos', '🐱'),
          const SizedBox(width: 12),
          _buildCategoryChip('Conejos', '🐰'),
          const SizedBox(width: 12),
          _buildCategoryChip('Aves', '🦜'),
          const SizedBox(width: 12),
          _buildCategoryChip('Otros', '🦎'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String emoji) {
    final isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => onCategorySelected(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
