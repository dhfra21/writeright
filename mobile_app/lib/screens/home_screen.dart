// Home screen
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement home screen
    return Scaffold(
      appBar: AppBar(title: const Text('Handwriting Learning')),
      body: const Center(child: Text('Home Screen')),
    );
  }
}
