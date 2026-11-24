import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final double distanceMiles;
  final double durationMinutes;
  final String startTitle;
  final String destinationTitle;

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.distanceMiles,
    required this.durationMinutes,
    required this.startTitle,
    required this.destinationTitle,
  });
}
