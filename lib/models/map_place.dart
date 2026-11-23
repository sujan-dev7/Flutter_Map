import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum PlaceCategory {
  landmark,
  park,
  museum,
  restaurant,
  custom,
}

class MapPlace {
  final String id;
  final String title;
  final String description;
  final LatLng location;
  final PlaceCategory category;
  final double rating;

  const MapPlace({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    this.rating = 4.5,
  });

  IconData get icon {
    switch (category) {
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

  Color get color {
    switch (category) {
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
