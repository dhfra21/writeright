// Main handwriting practice screen
import 'package:flutter/material.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement practice screen
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: const Center(child: Text('Practice Screen')),
    );
  }
}
