import 'package:flutter/material.dart';

class MapTileStyle {
  final String id;
  final String name;
  final String urlTemplate;
  final List<String> subdomains;
  final IconData icon;

  const MapTileStyle({
    required this.id,
    required this.name,
    required this.urlTemplate,
    this.subdomains = const ['a', 'b', 'c'],
    required this.icon,
  });

  static const List<MapTileStyle> availableStyles = [
    MapTileStyle(
      id: 'osm_standard',
      name: 'Standard OSM',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      icon: Icons.map,
    ),
    MapTileStyle(
      id: 'carto_dark',
      name: 'Dark Mode',
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      subdomains: ['a', 'b', 'c', 'd'],
      icon: Icons.dark_mode,
    ),
    MapTileStyle(
      id: 'opentopo',
      name: 'Topographic',
      urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
      icon: Icons.terrain,
    ),
    MapTileStyle(
      id: 'carto_light',
      name: 'Light Minimal',
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
      subdomains: ['a', 'b', 'c', 'd'],
      icon: Icons.wb_sunny,
    ),
  ];
}
