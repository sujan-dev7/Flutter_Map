import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_result.dart';
import 'location_service.dart';

class RoutingService {
  /// Fetches the shortest driving route using OpenStreetMap OSRM Routing API.
  /// If the API is unreachable, it seamlessly generates a straight-line route fallback.
  static Future<RouteResult> fetchShortestPath({
    required LatLng start,
    required LatLng destination,
    required String startTitle,
    required String destinationTitle,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final double distanceMeters = (route['distance'] as num).toDouble();
          final double durationSeconds = (route['duration'] as num).toDouble();

          final coordinates = route['geometry']['coordinates'] as List;
          final List<LatLng> pathPoints = coordinates.map((coord) {
            final List c = coord as List;
            return LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble());
          }).toList();

          final double km = distanceMeters / 1000.0;
          final double miles = km * 0.621371;
          final double mins = durationSeconds / 60.0;

          return RouteResult(
            points: pathPoints,
            distanceKm: km,
            distanceMiles: miles,
            durationMinutes: mins,
            startTitle: startTitle,
            destinationTitle: destinationTitle,
          );
        }
      }
    } catch (_) {
      // Fallback if network is unavailable or request times out
    }

    // Direct fallback calculation
    final double distKm = LocationService.calculateDistanceInKm(start, destination);
    final double distMiles = LocationService.calculateDistanceInMiles(start, destination);
    // Estimated driving time at average 50 km/h speed
    final double estMinutes = (distKm / 50.0) * 60.0;

    return RouteResult(
      points: [start, destination],
      distanceKm: distKm,
      distanceMiles: distMiles,
      durationMinutes: estMinutes,
      startTitle: startTitle,
      destinationTitle: destinationTitle,
    );
  }
}
