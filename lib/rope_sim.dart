import 'package:flutter/material.dart';
import 'dart:math';
import 'rope_painter.dart';

enum RopeType { normal, elastic, rigid }

class RopeSimulation extends StatefulWidget {
  const RopeSimulation({super.key});

  @override
  State<RopeSimulation> createState() => _RopeSimulationState();
}

class _RopeSimulationState extends State<RopeSimulation> with SingleTickerProviderStateMixin {
  final List<Point> points = [];
  late final AnimationController _controller;
  int numPoints = 20;
  double totalLength = 300.0;
  double gravity = 4;
  late Offset handlePosition;
  RopeType ropeType = RopeType.rigid;
  double ropeThickness = 2.0;
  bool showPoints = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..repeat()
      ..addListener(_updateRope);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    handlePosition = Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 3);
    _initializeRope();
  }

  void _initializeRope() {
    points.clear();
    final segmentLength = totalLength / (numPoints - 1);
    points.addAll(List.generate(numPoints, (i) => Point(handlePosition.dx, handlePosition.dy + i * segmentLength)));
  }

  void _updateRope() {
    setState(() {
      points[0] = Point(handlePosition.dx, handlePosition.dy);
      final segmentLength = totalLength / (numPoints - 1);
      final stretchFactor = _getRopeStretchFactor();

      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        var current = points[i];

        final gravityEffect = gravity * (i / points.length);
        current = Point(current.x, current.y + gravityEffect);

        final dx = current.x - prev.x;
        final dy = current.y - prev.y;
        final distance = sqrt(dx * dx + dy * dy);
        final difference = segmentLength - distance;
        final percent = difference / distance * stretchFactor;
        final offsetX = dx * percent;
        final offsetY = dy * percent;

        points[i] = Point(current.x + offsetX, current.y + offsetY);
      }
    });
  }

  double _getRopeStretchFactor() {
    switch (ropeType) {
      case RopeType.normal:
        return 0.5;
      case RopeType.elastic:
        return 0.3;
      case RopeType.rigid:
        return 0.8;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() => handlePosition = details.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: _handlePanUpdate,
            child: CustomPaint(
              painter: RopePainter(points, handlePosition, Colors.white, ropeThickness, showPoints),
              size: Size.infinite,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildControlPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRopeTypeDropdown(),
          const SizedBox(height: 5),
          _buildSlider('Gravity:', gravity, 0, 20, 40, (value) => gravity = value),
          _buildSlider('Thickness:', ropeThickness, 1, 10, 18, (value) => ropeThickness = value),
          _buildSlider('Rope Length:', totalLength, 100, 800, 70, (value) {
            totalLength = value;
            _initializeRope();
          }),
          _buildShowPointsSwitch(),
        ],
      ),
    );
  }

  Widget _buildRopeTypeDropdown() {
    return Row(
      children: [
        const Text('Rope Type:', style: TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(width: 10),
        DropdownButton<RopeType>(
          value: ropeType,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white, fontSize: 12),
          onChanged: (RopeType? newValue) {
            if (newValue != null) setState(() => ropeType = newValue);
          },
          items: RopeType.values.map((RopeType value) {
            return DropdownMenuItem<RopeType>(
              value: value,
              child: Text(value.toString().split('.').last),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSlider(
      String label, double value, double min, double max, int divisions, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            onChanged: (double value) => setState(() => onChanged(value)),
          ),
        ),
      ],
    );
  }

  Widget _buildShowPointsSwitch() {
    return Row(
      children: [
        const Text('Show Points:', style: TextStyle(color: Colors.white, fontSize: 12)),
        Switch(
          value: showPoints,
          onChanged: (bool value) => setState(() => showPoints = value),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
