import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  final LatLng _mapCenter = const LatLng(47.6588, -117.4260);
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadManualAndFirebaseGyms();
  }

  void _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  void _loadManualAndFirebaseGyms() async {
    // Manually defined gyms
    final testMarkers = <Marker>{
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
    };

    // Firebase gyms
    final snapshot = await FirebaseFirestore.instance.collection('gyms').get();

    final firebaseMarkers = snapshot.docs.map((doc) {
      final data = doc.data();
      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(data['lat'], data['lng']),
        infoWindow: InfoWindow(title: data['name']),
      );
    }).toSet();

    // Add both to the map
    setState(() {
      _markers
        ..clear()
        ..addAll(testMarkers)
        ..addAll(firebaseMarkers);
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
