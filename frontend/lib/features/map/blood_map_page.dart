import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class BloodMapPage extends StatefulWidget {
  const BloodMapPage({super.key});

  @override
  State<BloodMapPage> createState() => _BloodMapPageState();
}

class _BloodMapPageState extends State<BloodMapPage> {
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
      "type": "HOSPITAL", "name": "Bệnh viện Chợ Rẫy",
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
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoadingLocation = false);
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
                children: [_searchBar(context), const SizedBox(height: 12), _filters(context)],
              ),
            ),
          ),
          _bottomSheet(context),
          Positioned(
            right: 16, bottom: 220,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).cardColor,
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

  Widget _searchBar(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showSearch(context: context, delegate: PlaceSearchDelegate());
        if (result != null && result['lat'] != null && result['lon'] != null) {
          final lat = result['lat'] as double;
          final lon = result['lon'] as double;
          setState(() {
            _currentPosition = LatLng(lat, lon);
          });
          _mapController.move(_currentPosition, 16.0);
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(Icons.search, color: Theme.of(context).textTheme.bodyMedium?.color), 
          const SizedBox(width: 8),
          Expanded(child: Text("Tìm bệnh viện, khu vực, tên đường...", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
          const Icon(Icons.tune, color: ctaOrange),
        ]),
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _chip(context, "Chỉ hiện SOS", true), const SizedBox(width: 8),
        _chip(context, "Gần nhất", false), const SizedBox(width: 8),
        _chip(context, "Nhóm máu A", false),
      ]),
    );
  }

  Widget _chip(BuildContext context, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? ctaOrange : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(label, style: TextStyle(
        color: active ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _bottomSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35, minChildSize: 0.15, maxChildSize: 0.8,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: ListView(controller: controller, children: [
            Center(child: Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Điểm hiến & SOS gần bạn",
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.bold)),
              _chip(context, "SOS", true),
            ]),
            const SizedBox(height: 16),
            ..._sosPoints.map((sos) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _sosItem(context, sos))),
            ..._hospitalPoints.map((hosp) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _hospitalItem(context, hosp))),
            const SizedBox(height: 12),
            Text("Chúng tôi chỉ hiển thị nhóm máu & địa điểm – bảo mật thông tin cá nhân",
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11), textAlign: TextAlign.center),
            const SizedBox(height: 24),
          ]),
        );
      },
    );
  }

  Widget _sosItem(BuildContext context, Map<String, dynamic> sos) {
    String distance = _calculateDistance(sos['lat'], sos['lng']);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.warning, color: ctaOrange), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${sos['title']}: Nhóm ${sos['blood']}", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sos['desc'], style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
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

  Widget _hospitalItem(BuildContext context, Map<String, dynamic> hosp) {
    String distance = _calculateDistance(hosp['lat'], hosp['lng']);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const CircleAvatar(radius: 18, backgroundColor: Colors.blue,
          child: Icon(Icons.local_hospital, color: Colors.white, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hosp['name'], style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(hosp['address'], style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12)),
          const SizedBox(height: 4),
          Text("$distance • ${hosp['status']}",
            style: TextStyle(
              color: hosp['status'].toString().contains("Đang") ? const Color(0xFF2ECC71) : Colors.orange,
              fontSize: 12)),
        ])),
        GestureDetector(
          onTap: () => _mapController.move(LatLng(hosp['lat'], hosp['lng']), 15.0),
          child: Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ]),
    );
  }
}

class PlaceSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  @override
  String get searchFieldLabel => 'Nhập địa điểm...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions();

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return const Center(child: Text('Gợi ý: Nhập tên đường, phường, bệnh viện...'));
    
    return FutureBuilder<List<dynamic>>(
      future: _searchPlaces(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00)));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) return const Center(child: Text('Không tìm thấy địa điểm'));

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final place = results[index];
            return ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blueGrey),
              title: Text(place['display_name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () {
                final lat = double.tryParse(place['lat']?.toString() ?? '0');
                final lon = double.tryParse(place['lon']?.toString() ?? '0');
                close(context, {
                  'lat': lat,
                  'lon': lon,
                  'name': place['display_name']
                });
              },
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _searchPlaces(String q) async {
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/search', 
        queryParameters: {'q': q, 'format': 'json', 'limit': 8, 'countrycodes': 'vn'},
        options: Options(headers: {'User-Agent': 'BloodConnectFlutterApp/1.0'})
      );
      if (res.statusCode == 200 && res.data is List) {
        return res.data;
      }
    } catch (_) {}
    return [];
  }
}

