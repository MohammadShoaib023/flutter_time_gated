import 'package:flutter/material.dart';

class StageTwoView extends StatelessWidget {
  const StageTwoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stage Two')),
      body: const Center(
        child: Text(
          'Welcome to Stage Two 🎉',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
