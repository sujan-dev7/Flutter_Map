import 'package:latlong2/latlong.dart';
import '../models/map_place.dart';

class LocationService {
  static final List<MapPlace> samplePlaces = [
    MapPlace(
      id: '1',
      title: 'Eiffel Tower',
      description: 'Iconic 19th-century iron lattice tower on the Champ de Mars in Paris, France.',
      location: const LatLng(48.8584, 2.2945),
      category: PlaceCategory.landmark,
      rating: 4.8,
      ticketPriceNpr: 1500.0,
    ),
    MapPlace(
      id: '2',
      title: 'Louvre Museum',
      description: 'The world\'s largest art museum and a historic monument in Paris.',
      location: const LatLng(48.8606, 2.3376),
      category: PlaceCategory.museum,
      rating: 4.7,
      ticketPriceNpr: 1200.0,
    ),
    MapPlace(
      id: '3',
      title: 'Colosseum',
      description: 'An ancient amphitheatre located in the center of the city of Rome, Italy.',
      location: const LatLng(41.8902, 12.4922),
      category: PlaceCategory.landmark,
      rating: 4.9,
      ticketPriceNpr: 1800.0,
    ),
    MapPlace(
      id: '4',
      title: 'Central Park',
      description: 'An urban park in New York City located between the Upper West and Upper East Sides.',
      location: const LatLng(40.7851, -73.9683),
      category: PlaceCategory.park,
      rating: 4.8,
      ticketPriceNpr: 500.0,
    ),
    MapPlace(
      id: '5',
      title: 'Sydney Opera House',
      description: 'A multi-venue performing arts centre at Sydney Harbour in Sydney, Australia.',
      location: const LatLng(-33.8568, 151.2153),
      category: PlaceCategory.landmark,
      rating: 4.9,
      ticketPriceNpr: 2000.0,
    ),
    MapPlace(
      id: '6',
      title: 'Le Procope Restaurant',
      description: 'Historic restaurant in Paris known as the oldest cafe of Paris in continuous operation.',
      location: const LatLng(48.8530, 2.3388),
      category: PlaceCategory.restaurant,
      rating: 4.5,
      ticketPriceNpr: 850.0,
    ),
  ];

  static double calculateDistanceInKm(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, p1, p2);
  }

  static double calculateDistanceInMiles(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Mile, p1, p2);
  }

  static List<MapPlace> searchPlaces(String query) {
    if (query.trim().isEmpty) return samplePlaces;
    final lower = query.toLowerCase();
    return samplePlaces.where((place) {
      return place.title.toLowerCase().contains(lower) ||
          place.description.toLowerCase().contains(lower);
    }).toList();
  }
}
