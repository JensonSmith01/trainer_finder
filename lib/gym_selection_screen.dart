import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'trainer_list_screen.dart';
import 'map_screen.dart'; // ← Add this import

class GymSelectionScreen extends StatelessWidget {
  const GymSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gymsRef = FirebaseFirestore.instance.collection('gyms');

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Gym')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('View Gyms on Map'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen()),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: gymsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading gyms.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final gyms = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: gyms.length,
                  itemBuilder: (context, index) {
                    final gym = gyms[index];
                    final gymName = gym['name'];

                    return ListTile(
                      title: Text(gymName),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainerListScreen(
                              gymDocId: gym.id,
                              gymName: gymName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
