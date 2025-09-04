import 'package:flutter/material.dart';

class PlaybackSpeedControl extends StatefulWidget {
  final double currentSpeed;
  final Function(double) onSpeedChanged;

  const PlaybackSpeedControl({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  State<PlaybackSpeedControl> createState() => _PlaybackSpeedControlState();
}

class _PlaybackSpeedControlState extends State<PlaybackSpeedControl> {
  late double _currentSpeed;
  final List<double> _presetSpeeds = [
    0.1, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 5.0, 10.0
  ];

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.currentSpeed;
  }

  void _incrementSpeed(double increment) {
    final newSpeed = (_currentSpeed + increment).clamp(0.1, 10.0);
    setState(() {
      _currentSpeed = newSpeed;
    });
    widget.onSpeedChanged(newSpeed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tốc độ phát: ${_currentSpeed.toStringAsFixed(2)}x',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Slider
          Slider(
            value: _currentSpeed,
            min: 0.1,
            max: 10.0,
            divisions: 99, // 0.1 increments
            label: '${_currentSpeed.toStringAsFixed(2)}x',
            onChanged: (value) {
              setState(() {
                _currentSpeed = value;
              });
              widget.onSpeedChanged(value);
            },
          ),
          
          // Increment/Decrement buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _incrementSpeed(-0.1),
                child: const Text('-0.1'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _incrementSpeed(-0.25),
                child: const Text('-0.25'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _incrementSpeed(0.25),
                child: const Text('+0.25'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _incrementSpeed(0.1),
                child: const Text('+0.1'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Preset speed buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _presetSpeeds.map((speed) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentSpeed = speed;
                  });
                  widget.onSpeedChanged(speed);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentSpeed == speed
                      ? Theme.of(context).primaryColor
                      : null,
                  foregroundColor: _currentSpeed == speed
                      ? Colors.white
                      : null,
                ),
                child: Text('${speed}x'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}