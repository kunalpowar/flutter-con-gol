import 'package:flutter/material.dart';

class VelocitySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VelocitySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.speed_rounded,
                color: Colors.greenAccent,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Chaos Velocity: ${value.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 320,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.greenAccent,
                inactiveTrackColor: Colors.greenAccent.withValues(alpha: 0.2),
                thumbColor: Colors.greenAccent,
                overlayColor: Colors.greenAccent.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value,
                min: 1,
                max: 10,
                divisions: 18,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
