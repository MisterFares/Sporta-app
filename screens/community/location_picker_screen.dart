import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fit/styles/colors.dart';

class LocationPickerScreen extends StatefulWidget {
  final Function(double lat, double lng, String name) onLocationSelected;

  const LocationPickerScreen({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  String _address = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: AppColors.cardBackground,
        actions: [
          if (_selectedPosition != null)
            TextButton(
              onPressed: () {
                widget.onLocationSelected(
                  _selectedPosition!.latitude,
                  _selectedPosition!.longitude,
                  _address,
                );
                Navigator.pop(context);
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a place...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _searchLocation,
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(30.0444, 31.2357), // Cairo
                initialZoom: 12,
                onTap: (tapPosition, position) => _onMapTap(position),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.fit',
                ),
                if (_selectedPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPosition!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_address.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: AppColors.cardBackground,
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(child: Text(_address)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _onMapTap(LatLng position) async {
    setState(() {
      _selectedPosition = position;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address = '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  void _searchLocation(String query) async {
    try {
      print("🔍 Searching for: $query");
      final locations = await locationFromAddress(query);
      print("📍 Found ${locations.length} locations");
      if (locations.isNotEmpty) {
        final location = locations.first;
        final position = LatLng(location.latitude, location.longitude);
        _mapController.move(position, 15);
        _onMapTap(position);
      } else {
        print("❌ No locations found");
      }
    } catch (e) {
      print("❌ Error searching: $e");
    }
  }
}
