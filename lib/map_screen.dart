import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trainer_list_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadGymMarkers();
  }

  Future<void> _loadGymMarkers() async {
    final gymsSnapshot = await FirebaseFirestore.instance.collection('gyms').get();

    final markers = gymsSnapshot.docs.map((doc) {
      final data = doc.data();
      final gymName = data['name'];
      final lat = data['latitude'];
      final lng = data['longitude'];

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: gymName,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrainerListScreen(
                  gymDocId: doc.id,
                  gymName: gymName,
                ),
              ),
            );
          },
        ),
      );
    }).toSet();

    setState(() {
      _markers.addAll(markers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Gym')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(47.6588, -117.4260), // You can center this on your region
          zoom: 11,
        ),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
}
