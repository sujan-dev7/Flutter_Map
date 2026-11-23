import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_place.dart';
import '../models/map_tile_layer.dart';
import '../services/location_service.dart';
import '../widgets/distance_tracker_widget.dart';
import '../widgets/map_layer_selector.dart';
import '../widgets/place_detail_sheet.dart';
import '../widgets/place_search_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // State Variables
  late List<MapPlace> _places;
  MapTileStyle _selectedTileStyle = MapTileStyle.availableStyles[0];

  // Feature 4: Distance Measurement State
  bool _isMeasuringDistance = false;
  LatLng? _measureStartPoint;
  LatLng? _measureEndPoint;

  // Initial Center: Paris (Eiffel Tower region)
  final LatLng _initialCenter = const LatLng(48.8584, 2.2945);

  @override
  void initState() {
    super.initState();
    _places = List.from(LocationService.samplePlaces);
  }

  void _animatedMoveTo(LatLng destLocation, double destZoom) {
    _mapController.move(destLocation, destZoom);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_isMeasuringDistance) {
      setState(() {
        if (_measureStartPoint == null) {
          _measureStartPoint = point;
        } else if (_measureEndPoint == null) {
          _measureEndPoint = point;
        } else {
          // Reset and start new measurement
          _measureStartPoint = point;
          _measureEndPoint = null;
        }
      });
      return;
    }
  }

  void _onMapLongPress(TapPosition tapPosition, LatLng point) {
    if (_isMeasuringDistance) return;

    // Feature 1: Add Custom Marker on Long Press
    final newPlace = MapPlace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Custom Marker #${_places.length + 1}',
      description: 'User created marker at coordinates ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
      location: point,
      category: PlaceCategory.custom,
      rating: 5.0,
    );

    setState(() {
      _places.add(newPlace);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added new marker: ${newPlace.title}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _showPlaceDetails(newPlace),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPlaceDetails(MapPlace place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailSheet(
        place: place,
        onNavigateTo: () {
          _animatedMoveTo(place.location, 16.0);
        },
        onDelete: place.category == PlaceCategory.custom
            ? () {
                setState(() {
                  _places.removeWhere((p) => p.id == place.id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom marker removed.')),
                );
              }
            : null,
      ),
    );
  }

  void _showStyleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MapLayerSelector(
        currentStyle: _selectedTileStyle,
        onStyleSelected: (style) {
          setState(() {
            _selectedTileStyle = style;
          });
        },
      ),
    );
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceSearchSheet(
        places: _places,
        onPlaceSelected: (place) {
          _animatedMoveTo(place.location, 15.0);
          _showPlaceDetails(place);
        },
      ),
    );
  }

  void _toggleDistanceMeasurement() {
    setState(() {
      _isMeasuringDistance = !_isMeasuringDistance;
      if (!_isMeasuringDistance) {
        _measureStartPoint = null;
        _measureEndPoint = null;
      }
    });

    if (_isMeasuringDistance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Distance mode: Tap two points on the map to measure distance.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final polylines = <Polyline>[];
    if (_measureStartPoint != null && _measureEndPoint != null) {
      polylines.add(
        Polyline(
          points: [_measureStartPoint!, _measureEndPoint!],
          strokeWidth: 4.0,
          color: Colors.indigo,
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map Core Widget
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              onTap: _onMapTap,
              onLongPress: _onMapLongPress,
            ),
            children: [
              // Feature 2: Map Tile Layer
              TileLayer(
                urlTemplate: _selectedTileStyle.urlTemplate,
                subdomains: _selectedTileStyle.subdomains,
                userAgentPackageName: 'com.example.map_flutter',
              ),

              // Feature 4: Polyline Layer for Distance Tracking
              if (polylines.isNotEmpty)
                PolylineLayer(
                  polylines: polylines,
                ),

              // Feature 4: Measurement Markers Layer
              if (_isMeasuringDistance)
                MarkerLayer(
                  markers: [
                    if (_measureStartPoint != null)
                      Marker(
                        point: _measureStartPoint!,
                        width: 36,
                        height: 36,
                        child: const Icon(Icons.location_on, color: Colors.green, size: 36),
                      ),
                    if (_measureEndPoint != null)
                      Marker(
                        point: _measureEndPoint!,
                        width: 36,
                        height: 36,
                        child: const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
                      ),
                  ],
                ),

              // Feature 1: Main Place Markers Layer
              MarkerLayer(
                markers: _places.map((place) {
                  return Marker(
                    point: place.location,
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => _showPlaceDetails(place),
                      child: Tooltip(
                        message: place.title,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                            border: Border.all(color: place.color, width: 2.5),
                          ),
                          child: Icon(
                            place.icon,
                            color: place.color,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Header & Search Bar (Feature 3)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    child: InkWell(
                      onTap: _showSearchSheet,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Search places, landmarks...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.tune,
                                size: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Feature 4: Active Distance Tracker Banner
                  if (_isMeasuringDistance) ...[
                    const SizedBox(height: 8),
                    DistanceTrackerWidget(
                      startPoint: _measureStartPoint,
                      endPoint: _measureEndPoint,
                      onClear: _toggleDistanceMeasurement,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Floating Map Action Buttons
          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Feature 4: Toggle Distance Measurement Tool
                FloatingActionButton.small(
                  heroTag: 'fab_distance',
                  backgroundColor: _isMeasuringDistance ? Colors.indigo : Colors.white,
                  foregroundColor: _isMeasuringDistance ? Colors.white : Colors.indigo,
                  onPressed: _toggleDistanceMeasurement,
                  tooltip: 'Measure Distance',
                  child: const Icon(Icons.straighten),
                ),
                const SizedBox(height: 10),

                // Feature 2: Map Style Switcher Tool
                FloatingActionButton.small(
                  heroTag: 'fab_style',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: _showStyleSelector,
                  tooltip: 'Change Map Style',
                  child: const Icon(Icons.layers_outlined),
                ),
                const SizedBox(height: 10),

                // Zoom In Button
                FloatingActionButton.small(
                  heroTag: 'fab_zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                  tooltip: 'Zoom In',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),

                // Zoom Out Button
                FloatingActionButton.small(
                  heroTag: 'fab_zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                  tooltip: 'Zoom Out',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 10),

                // Recenter Home Button
                FloatingActionButton(
                  heroTag: 'fab_home',
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _animatedMoveTo(_initialCenter, 13.0);
                  },
                  tooltip: 'Recenter Map',
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
