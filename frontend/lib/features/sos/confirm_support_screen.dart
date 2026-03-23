import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/api/sos_service.dart';

class ConfirmSupportScreen extends StatefulWidget {
  final dynamic sosData;
  const ConfirmSupportScreen({super.key, required this.sosData});

  @override
  State<ConfirmSupportScreen> createState() => _ConfirmSupportScreenState();
}

class _ConfirmSupportScreenState extends State<ConfirmSupportScreen> {
  bool _isConfirming = false;

  Future<void> _handleConfirm() async {
    setState(() => _isConfirming = true);
    final id = widget.sosData['id'];
    if (id != null && id.toString().length > 10) { // Call API if real guid
      await SosService().confirmSos(id.toString());
    } else {
      await Future.delayed(const Duration(seconds: 1)); // Delay for dummy
    }
    setState(() => _isConfirming = false);
    
    if (!mounted) return;
    Navigator.pushNamed(context, '/sos_success');
  }

  @override
  Widget build(BuildContext context) {
    // Standard mock point for map
    final location = const LatLng(21.000, 105.845);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Bottom Dark Background
          Container(
            color: scaffoldBg,
          ),
          
          // 2. Top Header Map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: location,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: location,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          scaffoldBg.withValues(alpha: 0.5),
                          scaffoldBg.withValues(alpha: 1.0),
                        ],
                        stops: const [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                // Blood Type Badge
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.sosData['bloodType']?.toString() ?? 'O+',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                // Back & Share
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.share, color: textPrimary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // Title and Location text
                Positioned(
                  bottom: 30, // Above the solid boundary
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sosData['location']?.toString() ?? 'Bệnh viện Bạch Mai',
                        style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: textSecondary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '78 Giải Phóng, Phương Mai, Đống Đa', // Dummy sub-address
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 3. Scrollable Content (Under header)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Emergency Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('KHẨN CẤP', style: TextStyle(color: Color(0xFFFF6A00), fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.emergency, color: Colors.red, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.sosData['reason']?.toString() ?? 'Tai nạn giao thông',
                                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.sosData['description']?.toString() ?? 'Cần gấp 2 đơn vị máu toàn phần. Tình trạng bệnh nhân đang nguy kịch',
                                    style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Distance & Time Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.navigation, color: Color(0xFFFF6A00), size: 20),
                              const SizedBox(height: 12),
                              Text('Khoảng cách', style: TextStyle(fontSize: 12, color: textSecondary)),
                              const SizedBox(height: 4),
                              Text('1.2 km', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.directions_car, color: Colors.blueAccent, size: 20),
                              const SizedBox(height: 12),
                              Text('Thời gian đến', style: TextStyle(fontSize: 12, color: textSecondary)),
                              const SizedBox(height: 4),
                              Text('~5 phút', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Mini map
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: IgnorePointer(
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: location,
                            initialZoom: 14.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: location,
                                  width: 30,
                                  height: 30,
                                  child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isConfirming ? null : _handleConfirm,
                      icon: _isConfirming 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const SizedBox.shrink(),
                      label: Text(
                        _isConfirming ? "Đang xử lý..." : "Xác nhận hỗ trợ  →",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6A00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
