import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

class DistanceTrackerWidget extends StatelessWidget {
  final LatLng? startPoint;
  final LatLng? endPoint;
  final VoidCallback onClear;

  const DistanceTrackerWidget({
    super.key,
    required this.startPoint,
    required this.endPoint,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasStart = startPoint != null;
    final hasEnd = endPoint != null;

    double km = 0;
    double miles = 0;
    if (hasStart && hasEnd) {
      km = LocationService.calculateDistanceInKm(startPoint!, endPoint!);
      miles = LocationService.calculateDistanceInMiles(startPoint!, endPoint!);
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.straighten, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Distance Measure Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClear,
                  tooltip: 'Cancel Measurement',
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPointStatus('Point A (Start)', startPoint, Colors.green),
                const Icon(Icons.arrow_right_alt, color: Colors.grey),
                _buildPointStatus('Point B (End)', endPoint, Colors.redAccent),
              ],
            ),
            if (hasStart && hasEnd) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${km.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const Text(
                          'Kilometers',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Container(height: 24, width: 1, color: Colors.indigo.shade200),
                    Column(
                      children: [
                        Text(
                          '${miles.toStringAsFixed(2)} mi',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const Text(
                          'Miles',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                !hasStart
                    ? 'Tap on the map to set Start Point (Point A)'
                    : 'Tap on the map to set End Point (Point B)',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPointStatus(String label, LatLng? point, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              point != null ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 14,
              color: point != null ? color : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: point != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
        if (point != null)
          Text(
            '${point.latitude.toStringAsFixed(2)}, ${point.longitude.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace'),
          ),
      ],
    );
  }
}
