import 'package:flutter/material.dart';
import 'pet_card_widget.dart';

class PetGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> pets;
  final Function(int) onFavoriteToggle;

  const PetGridWidget({
    super.key,
    required this.pets,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => PetCardWidget(
            pet: pets[index],
            onFavoriteToggle: () => onFavoriteToggle(index),
          ),
          childCount: pets.length,
        ),
      ),
    );
  }
}
