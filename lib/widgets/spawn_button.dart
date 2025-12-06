import 'package:flutter/material.dart';

class SpawnButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SpawnButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Spawn Universe', style: TextStyle(fontSize: 16)),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}
