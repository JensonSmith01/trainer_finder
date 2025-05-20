import 'package:flutter/material.dart';

class GymSelectionScreen extends StatelessWidget {
  const GymSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gyms = ['Hart Gym', 'Bodifi Fitness', 'Anytime Fitness'];

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Gym')),
      body: ListView.builder(
        itemCount: gyms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(gyms[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // You could navigate to a Trainer screen here later
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You selected: ${gyms[index]}')),
              );
            },
          );
        },
      ),
    );
  }
}
