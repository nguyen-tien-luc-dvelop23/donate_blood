import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class BloodMapPage extends StatefulWidget {
  const BloodMapPage({super.key});

  @override
  State<BloodMapPage> createState() => _BloodMapPageState();
}

class _BloodMapPageState extends State<BloodMapPage> {
  static const bgDark = Color(0xFF120A08);
  static const cardDark = Color(0xFF1E1412);
  static const sosRed = Color(0xFFB71C1C);
  static const ctaOrange = Color(0xFFFF6A00);

  final MapController _mapController = MapController();
  
  LatLng _currentPosition = const LatLng(21.028511, 105.804817);
  bool _isLoadingLocation = true;

  final List<Map<String, dynamic>> _sosPoints = [
    {
      "id": "1", "lat": 21.0245, "lng": 105.8021,
      "type": "SOS", "blood": "O-",
      "title": "Cần máu gấp", "desc": "Tai nạn giao thông",
      "time": "5 phút trước"
    },
    {
      "id": "2", "lat": 21.0312, "lng": 105.7954,
      "type": "SOS", "blood": "AB",
      "title": "Cấp cứu", "desc": "Bệnh nhân mổ tim",
      "time": "15 phút trước"
    }
  ];

  final List<Map<String, dynamic>> _hospitalPoints = [
    {
      "id": "h1", "lat": 21.0298, "lng": 105.8082,
      "type": "HOSPITAL", "name": "Bệnh viện Chợ Rẫy (Demo)",
      "address": "201B Nguyễn Chí Thanh, Q5", "status": "Đang mở cửa"
    },
    {
      "id": "h2", "lat": 21.0185, "lng": 105.8015,
      "type": "HOSPITAL", "name": "Viện Huyết Học TW",
      "address": "Phố Phạm Văn Bạch", "status": "Đang mở cửa"
    }
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        _mapController.move(_currentPosition, 14.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  String _calculateDistance(double targetLat, double targetLng) {
    if (_isLoadingLocation) return "-- km";
    final distanceInMeters = Geolocator.distanceBetween(
      _currentPosition.latitude, _currentPosition.longitude,
      targetLat, targetLng,
    );
    return "${(distanceInMeters / 1000).toStringAsFixed(1)} km";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bloodconnect.app',
                ),
                MarkerLayer(markers: _buildAllMarkers()),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [_searchBar(), const SizedBox(height: 12), _filters()],
              ),
            ),
          ),
          _bottomSheet(),
          Positioned(
            right: 16, bottom: 220,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: cardDark,
              onPressed: () => _mapController.move(_currentPosition, 14.0),
              child: const Icon(Icons.my_location, color: ctaOrange),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildAllMarkers() {
    List<Marker> markers = [];
    if (!_isLoadingLocation) {
      markers.add(Marker(
        point: _currentPosition, width: 50, height: 50,
        child: Container(
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
          padding: const EdgeInsets.all(8),
          child: Container(width: 16, height: 16,
            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
        ),
      ));
    }
    for (var sos in _sosPoints) {
      markers.add(Marker(
        point: LatLng(sos['lat'], sos['lng']), width: 80, height: 80,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: sosRed, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))]),
            child: const Text("SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
            child: Text("Cần ${sos['blood']}", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          )
        ]),
      ));
    }
    for (var hosp in _hospitalPoints) {
      markers.add(Marker(
        point: LatLng(hosp['lat'], hosp['lng']), width: 60, height: 60,
        child: Column(children: [
          const CircleAvatar(radius: 14, backgroundColor: Colors.blue,
            child: Icon(Icons.local_hospital, color: Colors.white, size: 14)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
            child: const Text("Bệnh viện", style: TextStyle(color: Colors.white, fontSize: 8)),
          )
        ]),
      ));
    }
    return markers;
  }

  Widget _searchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14)),
      child: const Row(children: [
        Icon(Icons.search, color: Colors.white54), SizedBox(width: 8),
        Expanded(child: Text("Tìm bệnh viện, nhóm máu...", style: TextStyle(color: Colors.white54))),
        Icon(Icons.tune, color: ctaOrange),
      ]),
    );
  }

  Widget _filters() {
    return Row(children: [
      _chip("Chỉ hiện SOS", true), const SizedBox(width: 8),
      _chip("Gần nhất", false), const SizedBox(width: 8),
      _chip("Nhóm máu A", false),
    ]);
  }

  Widget _chip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? ctaOrange : cardDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(label, style: TextStyle(
        color: active ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _bottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35, minChildSize: 0.15, maxChildSize: 0.8,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: ListView(controller: controller, children: [
            Center(child: Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Điểm hiến & SOS gần bạn",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              _chip("SOS", true),
            ]),
            const SizedBox(height: 16),
            ..._sosPoints.map((sos) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _sosItem(sos))),
            ..._hospitalPoints.map((hosp) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _hospitalItem(hosp))),
            const SizedBox(height: 12),
            const Text("Chúng tôi chỉ hiển thị nhóm máu & địa điểm – bảo mật thông tin cá nhân",
              style: TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
            const SizedBox(height: 24),
          ]),
        );
      },
    );
  }

  Widget _sosItem(Map<String, dynamic> sos) {
    String distance = _calculateDistance(sos['lat'], sos['lng']);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.warning, color: ctaOrange), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${sos['title']}: Nhóm ${sos['blood']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sos['desc'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text("$distance • ${sos['time']}", style: const TextStyle(color: ctaOrange, fontSize: 12, fontWeight: FontWeight.w600)),
        ])),
        GestureDetector(
          onTap: () => _mapController.move(LatLng(sos['lat'], sos['lng']), 15.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: ctaOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.navigation, color: ctaOrange, size: 20),
          ),
        )
      ]),
    );
  }

  Widget _hospitalItem(Map<String, dynamic> hosp) {
    String distance = _calculateDistance(hosp['lat'], hosp['lng']);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const CircleAvatar(radius: 18, backgroundColor: Colors.blue,
          child: Icon(Icons.local_hospital, color: Colors.white, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hosp['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(hosp['address'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text("$distance • ${hosp['status']}",
            style: TextStyle(
              color: hosp['status'].toString().contains("Đang") ? const Color(0xFF2ECC71) : Colors.orange,
              fontSize: 12)),
        ])),
        GestureDetector(
          onTap: () => _mapController.move(LatLng(hosp['lat'], hosp['lng']), 15.0),
          child: const Icon(Icons.chevron_right, color: Colors.white38),
        ),
      ]),
    );
  }
}
