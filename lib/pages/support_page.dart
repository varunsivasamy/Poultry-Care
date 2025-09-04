import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'App Creator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Name: Your Name Here'),
            Text('Email: your.email@example.com'),
            Text('Phone: +1 234 567 8901'),
            SizedBox(height: 16),
            Text(
              'For feedback or support, reach out via email or phone. '
              'Include screenshots and steps to reproduce issues when possible.',
            ),
          ],
        ),
      ),
    );
  }
}


