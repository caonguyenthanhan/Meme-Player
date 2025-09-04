import 'package:flutter/material.dart';

class PresetSpeedButtons extends StatelessWidget {
  final double currentSpeed;
  final Function(double) onSpeedChanged;

  const PresetSpeedButtons({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final presetSpeeds = [0.1, 0.5, 0.75, 1.0, 1.5, 1.75, 2.0, 2.5, 3.0, 5.0, 10.0];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: presetSpeeds.map((speed) {
            final isSelected = (currentSpeed - speed).abs() < 0.01;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () => onSpeedChanged(speed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white24,
                  foregroundColor: isSelected ? Colors.white : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: isSelected ? 4 : 1,
                ),
                child: Text(
                  '${speed}x',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
