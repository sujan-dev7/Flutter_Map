import 'package:flutter/material.dart';
import '../models/map_place.dart';

class FavoritesSheet extends StatelessWidget {
  final List<MapPlace> favoritePlaces;
  final ValueChanged<MapPlace> onPlaceSelected;
  final ValueChanged<MapPlace> onToggleFavorite;

  const FavoritesSheet({
    super.key,
    required this.favoritePlaces,
    required this.onPlaceSelected,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(
                'Saved Places (${favoritePlaces.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: favoritePlaces.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 54, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          'No saved places yet!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap the heart icon in any place details card to bookmark it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: favoritePlaces.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final place = favoritePlaces[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: place.color.withValues(alpha: 0.15),
                          child: Icon(place.icon, color: place.color, size: 20),
                        ),
                        title: Text(
                          place.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          place.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.redAccent),
                          onPressed: () => onToggleFavorite(place),
                          tooltip: 'Remove from saved',
                        ),
                        onTap: () {
                          onPlaceSelected(place);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
