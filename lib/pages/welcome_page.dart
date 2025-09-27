import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue sur PolyAssistant',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 16),
            Text(
              "Votre assistant pour réussir vos études à L'École Polytechnique de Lomé",
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(duration: 800.ms),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Commencer'),
            ).animate().fadeIn(duration: 1000.ms).scale(),
          ],
        ),
      ),
    );
  }
}
