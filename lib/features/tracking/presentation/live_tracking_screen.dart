import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/blood_badge.dart';

/// Live location tracking screen with interactive OpenStreetMap map,
/// moving emergency courier ambulance marker, route polyline, and live telemetry.
class LiveTrackingScreen extends StatefulWidget {
  final String referenceId;
  final String patientName;
  final String hospital;
  final String bloodGroup;
  final int quantity;

  const LiveTrackingScreen({
    super.key,
    required this.referenceId,
    this.patientName = 'Priya Menon',
    this.hospital = 'Apollo Speciality Hospital',
    this.bloodGroup = 'O+',
    this.quantity = 2,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  Timer? _movementTimer;
  double _progress = 0.35; // Initial 35% along route
  bool _isMoving = true;

  // Real-world urban route coordinates (Central Blood Bank -> Hospital corridor)
  static final List<LatLng> _routePoints = [
    const LatLng(13.0827, 80.2707), // Central Blood Bank, Park Town
    const LatLng(13.0760, 80.2640),
    const LatLng(13.0690, 80.2580),
    const LatLng(13.0610, 80.2510),
    const LatLng(13.0550, 80.2450),
    const LatLng(13.0480, 80.2400),
    const LatLng(13.0400, 80.2350), // Apollo Hospital, Greams Road
  ];

  late LatLng _bankLocation;
  late LatLng _hospitalLocation;
  late LatLng _currentCourierLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _bankLocation = _routePoints.first;
    _hospitalLocation = _routePoints.last;
    _currentCourierLocation = _interpolatePosition(_progress);

    // Simulate realistic live vehicle movement along the emergency corridor
    _movementTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || !_isMoving) return;
      setState(() {
        _progress += 0.025;
        if (_progress >= 0.98) {
          _progress = 0.98; // Arrived
        }
        _currentCourierLocation = _interpolatePosition(_progress);
      });
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    super.dispose();
  }

  /// Calculates interpolated coordinates between waypoints given a progress factor (0.0 to 1.0)
  LatLng _interpolatePosition(double t) {
    if (t <= 0) return _routePoints.first;
    if (t >= 1) return _routePoints.last;

    final totalSegments = _routePoints.length - 1;
    final segmentIndex = (t * totalSegments).floor().clamp(0, totalSegments - 1);
    final segmentT = (t * totalSegments) - segmentIndex;

    final p1 = _routePoints[segmentIndex];
    final p2 = _routePoints[segmentIndex + 1];

    final lat = p1.latitude + (p2.latitude - p1.latitude) * segmentT;
    final lng = p1.longitude + (p2.longitude - p1.longitude) * segmentT;
    return LatLng(lat, lng);
  }

  Future<void> _callCourier() async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('tel:9840198765');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _recenterOnVehicle() {
    HapticFeedback.selectionClick();
    try {
      _mapController.move(_currentCourierLocation, 14.5);
    } catch (e) {
      debugPrint('MapController move deferred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remainingKm = ((1.0 - _progress) * 5.4).clamp(0.2, 5.4).toStringAsFixed(1);
    final remainingMins = ((1.0 - _progress) * 16).ceil().clamp(1, 16);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Live Dispatch Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.referenceId,
              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Center on Vehicle',
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _recenterOnVehicle,
          ),
        ],
      ),
      body: Stack(
        children: [
          // INTERACTIVE MAP
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(13.0610, 80.2510),
              initialZoom: 13.2,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hemolife.app',
              ),

              // Route Polyline Layer
              PolylineLayer(
                polylines: [
                  // Outer Glow / Border
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 7.0,
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  // Inner Route Line
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.5,
                    color: AppColors.primary,
                  ),
                ],
              ),

              // Markers Layer: Central Bank, Hospital, and Moving Vehicle
              MarkerLayer(
                markers: [
                  // 1. Origin: Central Blood Bank
                  Marker(
                    point: _bankLocation,
                    width: 70,
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Text('Blood Bank', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0288D1),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                          ),
                          child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),

                  // 2. Destination: Hospital
                  Marker(
                    point: _hospitalLocation,
                    width: 70,
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Text('Hospital', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.healthy,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                          ),
                          child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),

                  // 3. Live Moving Ambulance / Courier Marker with Pulse Effect
                  Marker(
                    point: _currentCourierLocation,
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing outer radar circle
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // TOP FLOATING LIVE ETA PILL
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Arriving in ~$remainingMins mins',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.healthy,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$remainingKm km remaining to ${widget.hospital}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  BloodBadge(bloodGroup: widget.bloodGroup, size: 34),
                ],
              ),
            ),
          ),

          // BOTTOM TELEMETRY & COURIER CARD
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PULL HANDLE
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TELEMETRY SENSORS (Cold chain temp, distance, units)
                  Row(
                    children: [
                      _buildMetricTile(
                        context,
                        icon: Icons.thermostat_rounded,
                        label: 'Cold-Chain',
                        value: '3.8°C',
                        status: 'Optimal (2-6°C)',
                        statusColor: AppColors.healthy,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricTile(
                        context,
                        icon: Icons.speed_rounded,
                        label: 'Vehicle Speed',
                        value: '42 km/h',
                        status: 'Emergency Green',
                        statusColor: const Color(0xFF0288D1),
                      ),
                      const SizedBox(width: 10),
                      _buildMetricTile(
                        context,
                        icon: Icons.water_drop_rounded,
                        label: 'Payload',
                        value: '${widget.quantity} Units',
                        status: widget.bloodGroup,
                        statusColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // DISPATCH COURIER DETAILS
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.person_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vikramaditya S.',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Certified Medical Courier • Van #TN-01-EM-2024',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          onPressed: _callCourier,
                          icon: const Icon(Icons.phone_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.healthy,
                            foregroundColor: Colors.white,
                          ),
                          tooltip: 'Call Courier',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // COPY TRACKING ID ACTION
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.referenceId));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tracking ID ${widget.referenceId} copied!'),
                                backgroundColor: AppColors.healthy,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy Tracking ID', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _recenterOnVehicle,
                          icon: const Icon(Icons.navigation_rounded, size: 16),
                          label: const Text('Follow Vehicle', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightTextMuted)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
