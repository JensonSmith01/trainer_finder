import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerListScreen extends StatelessWidget {
  final String gymDocId;
  final String gymName;

  const TrainerListScreen({
    super.key,
    required this.gymDocId,
    required this.gymName,
  });

  @override
  Widget build(BuildContext context) {
    final trainersRef = FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymDocId)
        .collection('trainers');

    return Scaffold(
      appBar: AppBar(title: Text('Trainers at $gymName')),
      body: StreamBuilder<QuerySnapshot>(
        stream: trainersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading trainers.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trainers = snapshot.data!.docs;

          if (trainers.isEmpty) {
            return const Center(child: Text('No trainers found.'));
          }

          return ListView.builder(
            itemCount: trainers.length,
            itemBuilder: (context, index) {
              final trainer = trainers[index];
              return ListTile(
                title: Text(trainer['name']),
                subtitle: Text(trainer['specialty'] ?? 'No specialty listed'),
                trailing: const Icon(Icons.fitness_center),
              );
            },
          );
        },
      ),
    );
  }
}
