import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  LatLng _mapCenter = const LatLng(47.6588, -117.4260);
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadManualGyms();
  }

  void _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  void _loadManualGyms() {
    setState(() {
      _markers.addAll([
        const Marker(
          markerId: MarkerId('test_gym_1'),
          position: LatLng(43.8146, -111.7856),
          infoWindow: InfoWindow(title: 'Test Gym Marker 1'),
        ),
        const Marker(
          markerId: MarkerId('test_gym_2'),
          position: LatLng(43.8200, -111.7800),
          infoWindow: InfoWindow(title: 'Test Gym Marker 2'),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Gym')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _mapCenter,
          zoom: 11,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
          if (_mapStyle != null) {
            _mapController!.setMapStyle(_mapStyle);
          }
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
