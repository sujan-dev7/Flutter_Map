import 'package:flutter/material.dart';

class GeofenceRadiusWidget extends StatelessWidget {
  final double radiusKm;
  final ValueChanged<double> onRadiusChanged;
  final int placesInsideCount;
  final VoidCallback onClose;

  const GeofenceRadiusWidget({
    super.key,
    required this.radiusKm,
    required this.onRadiusChanged,
    required this.placesInsideCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.radar, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Radius / Geofence Visualizer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  tooltip: 'Hide Radius',
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Text(
                  'Radius: ${radiusKm.toStringAsFixed(1)} km',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Text(
                    '$placesInsideCount ${placesInsideCount == 1 ? 'place' : 'places'} within zone',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: radiusKm,
              min: 0.5,
              max: 10.0,
              divisions: 19,
              activeColor: Colors.teal,
              label: '${radiusKm.toStringAsFixed(1)} km',
              onChanged: onRadiusChanged,
            ),
          ],
        ),
      ),
    );
  }
}
