import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'trainer_list_screen.dart';
import 'services/places_service.dart';

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
    _loadAllGyms();
  }

  void _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  Future<void> _loadAllGyms() async {
    await _loadUserLocation();
    await _loadFirestoreGyms();
    await _loadNearbyGymsFromPlaces();
  }

  Future<void> _loadUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    _mapCenter = LatLng(position.latitude, position.longitude);
    _mapController?.animateCamera(CameraUpdate.newLatLng(_mapCenter));
    print('User location set to: $_mapCenter');
  }

  Future<void> _loadFirestoreGyms() async {
    final gymsSnapshot = await FirebaseFirestore.instance.collection('gyms').get();

    final markers = gymsSnapshot.docs.map((doc) {
      final data = doc.data();
      final gymName = data['name'];
      final lat = data['latitude'];
      final lng = data['longitude'];
      print('Firestore gym: $gymName at $lat, $lng');

      return Marker(
        markerId: MarkerId('firestore_${doc.id}'),
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

  Future<void> _loadNearbyGymsFromPlaces() async {
    try {
      final gyms = await fetchNearbyGyms(_mapCenter.latitude, _mapCenter.longitude);
      print('Fetched ${gyms.length} nearby gyms from Places API');
      gyms.forEach((g) => print('${g['name']} - ${g['lat']}, ${g['lng']}'));

      final markers = gyms.map((gym) {
        return Marker(
          markerId: MarkerId('places_${gym['name']}_${gym['lat']}'),
          position: LatLng(gym['lat'], gym['lng']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: gym['name']),
        );
      }).toSet();

      setState(() {
        _markers.addAll(markers);
      });
    } catch (e) {
      print('Error loading gyms from Places API: $e');
    }
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
          // Temporarily disable styling to rule out issues
          // if (_mapStyle != null) {
          //   _mapController!.setMapStyle(_mapStyle);
          // }
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
