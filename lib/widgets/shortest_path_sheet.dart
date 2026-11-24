import 'package:flutter/material.dart';
import '../models/map_place.dart';
import '../models/route_result.dart';
import '../services/routing_service.dart';

class ShortestPathSheet extends StatefulWidget {
  final List<MapPlace> availablePlaces;
  final ValueChanged<RouteResult> onRouteCalculated;
  final VoidCallback onClearRoute;
  final RouteResult? currentRoute;

  const ShortestPathSheet({
    super.key,
    required this.availablePlaces,
    required this.onRouteCalculated,
    required this.onClearRoute,
    this.currentRoute,
  });

  @override
  State<ShortestPathSheet> createState() => _ShortestPathSheetState();
}

class _ShortestPathSheetState extends State<ShortestPathSheet> {
  MapPlace? _startPlace;
  MapPlace? _destinationPlace;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.availablePlaces.length >= 2) {
      _startPlace = widget.availablePlaces[0];
      _destinationPlace = widget.availablePlaces[1];
    } else if (widget.availablePlaces.isNotEmpty) {
      _startPlace = widget.availablePlaces[0];
    }
  }

  Future<void> _calculateRoute() async {
    if (_startPlace == null || _destinationPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both Start and Destination places.')),
      );
      return;
    }

    if (_startPlace!.id == _destinationPlace!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start and Destination places must be different.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final routeResult = await RoutingService.fetchShortestPath(
      start: _startPlace!.location,
      destination: _destinationPlace!.location,
      startTitle: _startPlace!.title,
      destinationTitle: _destinationPlace!.title,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      widget.onRouteCalculated(routeResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              const Icon(Icons.alt_route, color: Colors.indigo, size: 26),
              const SizedBox(width: 10),
              const Text(
                'Shortest Path Finder',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (widget.currentRoute != null)
                TextButton.icon(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.redAccent),
                  label: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    widget.onClearRoute();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Start Dropdown
          DropdownButtonFormField<MapPlace>(
            initialValue: _startPlace,
            decoration: InputDecoration(
              labelText: 'Start Origin',
              prefixIcon: const Icon(Icons.trip_origin, color: Colors.green),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: widget.availablePlaces.map((place) {
              return DropdownMenuItem<MapPlace>(
                value: place,
                child: Text(place.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _startPlace = val;
              });
            },
          ),
          const SizedBox(height: 12),

          // Swap Origin & Destination Button
          Center(
            child: IconButton(
              icon: const Icon(Icons.swap_vert, color: Colors.indigo),
              onPressed: () {
                setState(() {
                  final temp = _startPlace;
                  _startPlace = _destinationPlace;
                  _destinationPlace = temp;
                });
              },
              tooltip: 'Swap Start and Destination',
            ),
          ),
          const SizedBox(height: 4),

          // Destination Dropdown
          DropdownButtonFormField<MapPlace>(
            initialValue: _destinationPlace,
            decoration: InputDecoration(
              labelText: 'Target Destination',
              prefixIcon: const Icon(Icons.place, color: Colors.redAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: widget.availablePlaces.map((place) {
              return DropdownMenuItem<MapPlace>(
                value: place,
                child: Text(place.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _destinationPlace = val;
              });
            },
          ),
          const SizedBox(height: 20),

          // Result Card if active
          if (widget.currentRoute != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${widget.currentRoute!.distanceKm.toStringAsFixed(2)} km',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const Text('Distance', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  Container(height: 24, width: 1, color: Colors.indigo.shade200),
                  Column(
                    children: [
                      Text(
                        '${widget.currentRoute!.durationMinutes.toStringAsFixed(0)} min',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const Text('Est. Duration', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Calculate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _calculateRoute,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.directions),
              label: Text(_isLoading ? 'Calculating Shortest Path...' : 'Find Shortest Path'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
