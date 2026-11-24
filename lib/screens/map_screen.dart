import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_place.dart';
import '../models/map_tile_layer.dart';
import '../models/route_result.dart';
import '../services/esewa_service.dart';
import '../services/location_service.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/distance_tracker_widget.dart';
import '../widgets/esewa_wallet_sheet.dart';
import '../widgets/favorites_sheet.dart';
import '../widgets/geofence_radius_widget.dart';
import '../widgets/map_layer_selector.dart';
import '../widgets/place_detail_sheet.dart';
import '../widgets/place_search_sheet.dart';
import '../widgets/shortest_path_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

  // State Variables
  late List<MapPlace> _places;
  MapTileStyle _selectedTileStyle = MapTileStyle.availableStyles[0];

  // Category & Filter State
  PlaceCategory? _selectedCategory;
  bool _showFavoritesOnly = false;

  // Distance Measurement Tool State
  bool _isMeasuringDistance = false;
  LatLng? _measureStartPoint;
  LatLng? _measureEndPoint;

  // Geofence / Circle Radius State
  bool _showGeofenceRadius = false;
  double _geofenceRadiusKm = 2.0;
  LatLng? _geofenceCenter;

  // Shortest Path Routing State
  RouteResult? _currentRoute;

  // User Live Location State (Default: Paris Center)
  final LatLng _userLocation = const LatLng(48.8566, 2.3522);
  final LatLng _initialCenter = const LatLng(48.8584, 2.2945);

  @override
  void initState() {
    super.initState();
    _places = List.from(LocationService.samplePlaces);
    _geofenceCenter = _initialCenter;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _animatedMoveTo(LatLng destLocation, double destZoom) {
    _mapController.move(destLocation, destZoom);
  }

  List<MapPlace> get _visiblePlaces {
    return _places.where((place) {
      if (_showFavoritesOnly && !place.isFavorite) return false;
      if (_selectedCategory != null && place.category != _selectedCategory) return false;
      return true;
    }).toList();
  }

  int get _placesInsideGeofenceCount {
    if (_geofenceCenter == null) return 0;
    return _places.where((p) {
      final distKm = LocationService.calculateDistanceInKm(_geofenceCenter!, p.location);
      return distKm <= _geofenceRadiusKm;
    }).length;
  }

  void _toggleFavorite(MapPlace place) {
    setState(() {
      final index = _places.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _places[index] = _places[index].copyWith(isFavorite: !_places[index].isFavorite);
      }
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_isMeasuringDistance) {
      setState(() {
        if (_measureStartPoint == null) {
          _measureStartPoint = point;
        } else if (_measureEndPoint == null) {
          _measureEndPoint = point;
        } else {
          _measureStartPoint = point;
          _measureEndPoint = null;
        }
      });
      return;
    }

    if (_showGeofenceRadius) {
      setState(() {
        _geofenceCenter = point;
      });
    }
  }

  void _onMapLongPress(TapPosition tapPosition, LatLng point) {
    if (_isMeasuringDistance) return;

    final newPlace = MapPlace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Custom Marker #${_places.length + 1}',
      description: 'Custom pin created at ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
      location: point,
      category: PlaceCategory.custom,
      rating: 5.0,
      ticketPriceNpr: 100.0,
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentPlace = _places.firstWhere((p) => p.id == place.id, orElse: () => place);
            return PlaceDetailSheet(
              place: currentPlace,
              onNavigateTo: () {
                _animatedMoveTo(currentPlace.location, 16.0);
              },
              onToggleFavorite: () {
                _toggleFavorite(currentPlace);
                setModalState(() {});
              },
              onDelete: currentPlace.category == PlaceCategory.custom
                  ? () {
                      setState(() {
                        _places.removeWhere((p) => p.id == currentPlace.id);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Custom marker removed.')),
                      );
                    }
                  : null,
            );
          },
        );
      },
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

  void _showFavoritesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final favs = _places.where((p) => p.isFavorite).toList();
          return FavoritesSheet(
            favoritePlaces: favs,
            onPlaceSelected: (place) {
              _animatedMoveTo(place.location, 15.0);
              _showPlaceDetails(place);
            },
            onToggleFavorite: (place) {
              _toggleFavorite(place);
              setModalState(() {});
            },
          );
        },
      ),
    );
  }

  void _showEsewaWallet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const EsewaWalletSheet(),
    );
  }

  void _showShortestPathFinder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShortestPathSheet(
        availablePlaces: _places,
        currentRoute: _currentRoute,
        onRouteCalculated: (routeResult) {
          setState(() {
            _currentRoute = routeResult;
          });
          Navigator.pop(context);

          if (routeResult.points.isNotEmpty) {
            _mapController.fitCamera(
              CameraFit.coordinates(
                coordinates: routeResult.points,
                padding: const EdgeInsets.all(60.0),
              ),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found shortest route: ${routeResult.distanceKm.toStringAsFixed(1)} km (~${routeResult.durationMinutes.toStringAsFixed(0)} mins)'),
              duration: const Duration(seconds: 4),
            ),
          );
        },
        onClearRoute: () {
          setState(() {
            _currentRoute = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Route cleared.')),
          );
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
          content: Text('Distance Mode: Tap two points on the map to calculate distance.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _toggleGeofenceVisualizer() {
    setState(() {
      _showGeofenceRadius = !_showGeofenceRadius;
      if (_showGeofenceRadius && _geofenceCenter == null) {
        _geofenceCenter = _mapController.camera.center;
      }
    });
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

    if (_currentRoute != null && _currentRoute!.points.isNotEmpty) {
      polylines.add(
        Polyline(
          points: _currentRoute!.points,
          strokeWidth: 5.5,
          color: Colors.indigoAccent,
        ),
      );
    }

    final circles = <CircleMarker>[];
    if (_showGeofenceRadius && _geofenceCenter != null) {
      circles.add(
        CircleMarker(
          point: _geofenceCenter!,
          radius: _geofenceRadiusKm * 1000,
          useRadiusInMeter: true,
          color: Colors.teal.withValues(alpha: 0.18),
          borderColor: Colors.teal,
          borderStrokeWidth: 2.0,
        ),
      );
    }

    final visibleMarkers = _visiblePlaces;

    return Scaffold(
      body: Stack(
        children: [
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
              TileLayer(
                urlTemplate: _selectedTileStyle.urlTemplate,
                subdomains: _selectedTileStyle.subdomains,
                userAgentPackageName: 'com.example.map_flutter',
              ),

              if (circles.isNotEmpty)
                CircleLayer(
                  circles: circles,
                ),

              if (polylines.isNotEmpty)
                PolylineLayer(
                  polylines: polylines,
                ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation,
                    width: 48,
                    height: 48,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(alpha: 0.2 + (_pulseController.value * 0.3)),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 6),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (_isMeasuringDistance && _measureStartPoint != null)
                    Marker(
                      point: _measureStartPoint!,
                      width: 36,
                      height: 36,
                      child: const Icon(Icons.location_on, color: Colors.green, size: 36),
                    ),
                  if (_isMeasuringDistance && _measureEndPoint != null)
                    Marker(
                      point: _measureEndPoint!,
                      width: 36,
                      height: 36,
                      child: const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
                    ),

                  if (_currentRoute != null && _currentRoute!.points.isNotEmpty) ...[
                    Marker(
                      point: _currentRoute!.points.first,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.trip_origin, color: Colors.green, size: 40),
                    ),
                    Marker(
                      point: _currentRoute!.points.last,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.pin_drop, color: Colors.redAccent, size: 40),
                    ),
                  ],
                ],
              ),

              MarkerLayer(
                markers: visibleMarkers.map((place) {
                  return Marker(
                    point: place.location,
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => _showPlaceDetails(place),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
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
                            child: Center(
                              child: Icon(
                                place.icon,
                                color: place.color,
                                size: 22,
                              ),
                            ),
                          ),
                          if (place.isFavorite)
                            const Positioned(
                              top: -2,
                              right: -2,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.favorite, color: Colors.redAccent, size: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Header & Search Bar
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
                            // eSewa Wallet Quick Access Button
                            IconButton(
                              icon: const Icon(Icons.account_balance_wallet, color: EsewaService.esewaColor),
                              onPressed: _showEsewaWallet,
                              tooltip: 'eSewa Digital Wallet',
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
                              onPressed: _showFavoritesSheet,
                              tooltip: 'Saved Places',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  CategoryFilterBar(
                    selectedCategory: _selectedCategory,
                    showFavoritesOnly: _showFavoritesOnly,
                    allPlaces: _places,
                    onCategorySelected: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    onToggleFavorites: (favOnly) {
                      setState(() {
                        _showFavoritesOnly = favOnly;
                      });
                    },
                  ),

                  if (_currentRoute != null) ...[
                    const SizedBox(height: 8),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.indigo.shade900,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_currentRoute!.startTitle} → ${_currentRoute!.destinationTitle}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_currentRoute!.distanceKm.toStringAsFixed(1)} km (${_currentRoute!.distanceMiles.toStringAsFixed(1)} mi) • ~${_currentRoute!.durationMinutes.toStringAsFixed(0)} mins',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                              onPressed: () {
                                setState(() {
                                  _currentRoute = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (_isMeasuringDistance) ...[
                    const SizedBox(height: 8),
                    DistanceTrackerWidget(
                      startPoint: _measureStartPoint,
                      endPoint: _measureEndPoint,
                      onClear: _toggleDistanceMeasurement,
                    ),
                  ],

                  if (_showGeofenceRadius) ...[
                    const SizedBox(height: 8),
                    GeofenceRadiusWidget(
                      radiusKm: _geofenceRadiusKm,
                      placesInsideCount: _placesInsideGeofenceCount,
                      onRadiusChanged: (newRad) {
                        setState(() {
                          _geofenceRadiusKm = newRad;
                        });
                      },
                      onClose: _toggleGeofenceVisualizer,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action FABs Sidebar
          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // eSewa Wallet FAB
                FloatingActionButton.small(
                  heroTag: 'fab_esewa',
                  backgroundColor: EsewaService.esewaColor,
                  foregroundColor: Colors.white,
                  onPressed: _showEsewaWallet,
                  tooltip: 'eSewa Mobile Wallet',
                  child: const Icon(Icons.account_balance_wallet),
                ),
                const SizedBox(height: 10),

                // Shortest Path Navigation FAB
                FloatingActionButton.small(
                  heroTag: 'fab_route',
                  backgroundColor: _currentRoute != null ? Colors.indigoAccent : Colors.white,
                  foregroundColor: _currentRoute != null ? Colors.white : Colors.indigo,
                  onPressed: _showShortestPathFinder,
                  tooltip: 'Shortest Path Finder',
                  child: const Icon(Icons.alt_route),
                ),
                const SizedBox(height: 10),

                // Geofence Radius FAB
                FloatingActionButton.small(
                  heroTag: 'fab_geofence',
                  backgroundColor: _showGeofenceRadius ? Colors.teal : Colors.white,
                  foregroundColor: _showGeofenceRadius ? Colors.white : Colors.teal,
                  onPressed: _toggleGeofenceVisualizer,
                  tooltip: 'Geofence Radius Visualizer',
                  child: const Icon(Icons.radar),
                ),
                const SizedBox(height: 10),

                // Distance Measurement Tool FAB
                FloatingActionButton.small(
                  heroTag: 'fab_distance',
                  backgroundColor: _isMeasuringDistance ? Colors.indigo : Colors.white,
                  foregroundColor: _isMeasuringDistance ? Colors.white : Colors.indigo,
                  onPressed: _toggleDistanceMeasurement,
                  tooltip: 'Measure Distance',
                  child: const Icon(Icons.straighten),
                ),
                const SizedBox(height: 10),

                // Map Style Switcher FAB
                FloatingActionButton.small(
                  heroTag: 'fab_style',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: _showStyleSelector,
                  tooltip: 'Change Map Style',
                  child: const Icon(Icons.layers_outlined),
                ),
                const SizedBox(height: 10),

                // Zoom In
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

                // Zoom Out
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

                // Live User Location
                FloatingActionButton(
                  heroTag: 'fab_user_location',
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _animatedMoveTo(_userLocation, 15.0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Centered to your location.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'My Location',
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
