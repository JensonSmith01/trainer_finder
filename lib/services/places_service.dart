import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchNearbyGyms(double lat, double lng) async {
  const apiKey = 'AIzaSyA7MmoiYPa2gM2MLTvDVvkln0UBY8UAV8s'; // Replace with your actual key
  const radius = 5000;
  const type = 'gym';

  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    '?location=$lat,$lng'
    '&radius=$radius'
    '&type=$type'
    '&key=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final results = json['results'] as List<dynamic>;

    return results.map((gym) {
      return {
        'name': gym['name'],
        'lat': gym['geometry']['location']['lat'],
        'lng': gym['geometry']['location']['lng'],
      };
    }).toList();
  } else {
    throw Exception('Failed to fetch gyms: ${response.statusCode}');
  }
}


