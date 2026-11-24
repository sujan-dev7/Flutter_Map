import 'package:flutter/material.dart';
import '../models/map_place.dart';

class CategoryFilterBar extends StatelessWidget {
  final PlaceCategory? selectedCategory;
  final bool showFavoritesOnly;
  final ValueChanged<PlaceCategory?> onCategorySelected;
  final ValueChanged<bool> onToggleFavorites;
  final List<MapPlace> allPlaces;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.showFavoritesOnly,
    required this.onCategorySelected,
    required this.onToggleFavorites,
    required this.allPlaces,
  });

  int _getCategoryCount(PlaceCategory? cat) {
    if (cat == null) return allPlaces.length;
    return allPlaces.where((p) => p.category == cat).length;
  }

  int get _favoritesCount => allPlaces.where((p) => p.isFavorite).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Favorites Filter Chip
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              avatar: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: showFavoritesOnly ? Colors.white : Colors.red,
              ),
              label: Text('Saved ($_favoritesCount)'),
              selected: showFavoritesOnly,
              selectedColor: Colors.redAccent,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: showFavoritesOnly ? Colors.white : Colors.black87,
                fontWeight: showFavoritesOnly ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (selected) {
                onToggleFavorites(selected);
              },
            ),
          ),

          // "All" Category Filter Chip
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text('All (${_getCategoryCount(null)})'),
              selected: !showFavoritesOnly && selectedCategory == null,
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: (!showFavoritesOnly && selectedCategory == null)
                    ? Colors.white
                    : Colors.black87,
                fontWeight: (!showFavoritesOnly && selectedCategory == null)
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (_) {
                if (showFavoritesOnly) onToggleFavorites(false);
                onCategorySelected(null);
              },
            ),
          ),

          // Enum Categories Chips
          ...PlaceCategory.values.map((cat) {
            final isSelected = !showFavoritesOnly && selectedCategory == cat;
            final count = _getCategoryCount(cat);

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                avatar: Icon(
                  _getCategoryIcon(cat),
                  size: 16,
                  color: isSelected ? Colors.white : _getCategoryColor(cat),
                ),
                label: Text('${cat.name[0].toUpperCase()}${cat.name.substring(1)} ($count)'),
                selected: isSelected,
                selectedColor: _getCategoryColor(cat),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (_) {
                  if (showFavoritesOnly) onToggleFavorites(false);
                  onCategorySelected(cat);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.landmark:
        return Icons.location_city;
      case PlaceCategory.park:
        return Icons.park;
      case PlaceCategory.museum:
        return Icons.museum;
      case PlaceCategory.restaurant:
        return Icons.restaurant;
      case PlaceCategory.custom:
        return Icons.pin_drop;
    }
  }

  Color _getCategoryColor(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.landmark:
        return Colors.redAccent;
      case PlaceCategory.park:
        return Colors.green;
      case PlaceCategory.museum:
        return Colors.purpleAccent;
      case PlaceCategory.restaurant:
        return Colors.orangeAccent;
      case PlaceCategory.custom:
        return Colors.blueAccent;
    }
  }
}
