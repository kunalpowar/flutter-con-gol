import 'package:flutter/material.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.blur_on_rounded,
            size: 72,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Multiverse Control Center',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Command the chaos across all realities',
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
