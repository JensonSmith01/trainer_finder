import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'trainer_list_screen.dart';

class GymSelectionScreen extends StatelessWidget {
  const GymSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gymsRef = FirebaseFirestore.instance.collection('gyms');

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Gym')),
      body: StreamBuilder<QuerySnapshot>(
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
                      builder: (_) => TrainerListScreen(gymDocId: gym.id, gymName: gymName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
