import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'About Poultry Care',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Poultry Care helps you manage chick counts, deaths, feed info, '
              'vaccinations, diseases, products, notes, events and reminders. '
              'Track your daily farm activities and see quick statistics on the dashboard.',
            ),
            SizedBox(height: 16),
            Text(
              'How it works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Use Reminders to add chicks and register deaths; statistics update automatically. '
              'Add domain info in Home categories. Notes helps with quick memos. '
              'Records tab lists your activity entries.',
            ),
          ],
        ),
      ),
    );
  }
}


