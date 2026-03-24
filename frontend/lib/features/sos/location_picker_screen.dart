import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(21.028511, 105.804817);
  bool _isLoading = true;
  bool _isGettingAddress = false;
  String _currentAddress = "Vui lòng di chuyển bản đồ...";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (mounted) {
        setState(() {
          _center = LatLng(pos.latitude, pos.longitude);
          _isLoading = false;
        });
        _mapController.move(_center, 16.0);
        _getAddress(_center);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddress(LatLng pos) async {
    if (!mounted) return;
    setState(() => _isGettingAddress = true);
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {'lat': pos.latitude, 'lon': pos.longitude, 'format': 'json', 'accept-language': 'vi'},
        options: Options(headers: {'User-Agent': 'BloodConnectApp/1.0'})
      );
      if (res.statusCode == 200 && res.data != null && mounted) {
        setState(() {
          _currentAddress = res.data['display_name'] ?? "Vị trí không xác định";
          _isGettingAddress = false;
        });
      } else if (mounted) {
        setState(() => _isGettingAddress = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isGettingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí của bạn', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && pos.center != null) {
                  setState(() => _center = pos.center!);
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _getAddress(_center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bloodconnect.app',
              ),
            ],
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40), // Offset pin slightly above center to point exactly at crosshair
              child: Icon(Icons.location_on, size: 40, color: Color(0xFFFF6A00)),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00))),
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (_isGettingAddress) 
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6A00)))
                      else 
                        const Icon(Icons.location_on, color: Color(0xFFFF6A00), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_currentAddress, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isGettingAddress ? null : () {
                        Navigator.pop(context, {
                          'address': _currentAddress,
                          'lat': _center.latitude,
                          'lon': _center.longitude
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6A00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Xác nhận vị trí này', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20, bottom: 180,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).cardColor,
              onPressed: () => _determinePosition(),
              child: const Icon(Icons.my_location, color: Color(0xFFFF6A00)),
            ),
          ),
        ],
      ),
    );
  }
}
