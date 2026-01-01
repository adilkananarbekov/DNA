import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class DNAHelix extends StatefulWidget {
  final double height;
  final double width;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isPaused;
  final double speedMultiplier;

  const DNAHelix({
    Key? key,
    required this.height,
    required this.width,
    this.primaryColor = Colors.blueAccent,
    this.secondaryColor = Colors.redAccent,
    this.isPaused = false,
    this.speedMultiplier = 1.0,
  }) : super(key: key);

  @override
  _DNAHelixState createState() => _DNAHelixState();
}

class _DNAHelixState extends State<DNAHelix> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _manualRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void didUpdateWidget(DNAHelix oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _manualRotation += details.delta.dx * 0.01;
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double rotation = _controller.value * 2 * pi * widget.speedMultiplier + _manualRotation;
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: DNAPainter(
              rotation: rotation,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
            ),
          );
        },
      ),
    );
  }
}

class DNAPainter extends CustomPainter {
  final double rotation;
  final Color primaryColor;
  final Color secondaryColor;

  DNAPainter({
    required this.rotation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final int pairs = 15;
    final double spacing = size.height / (pairs + 1);
    final double radius = size.width * 0.25;

    List<DNAElement> elements = [];

    for (int i = 0; i < pairs; i++) {
      double y = spacing * (i + 1);
      double angle = (i * 0.5) + rotation;

      // Calculate 3D positions
      // Strand 1
      double x1 = centerX + radius * cos(angle);
      double z1 = radius * sin(angle);

      // Strand 2 (opposite)
      double x2 = centerX + radius * cos(angle + pi);
      double z2 = radius * sin(angle + pi);

      double scale1 = 0.5 + 0.5 * (z1 + radius) / (2 * radius);
      double scale2 = 0.5 + 0.5 * (z2 + radius) / (2 * radius);

      // Add atoms and connection
      elements.add(DNAAtom(
        x: x1,
        y: y,
        z: z1,
        radius: 8 * scale1,
        color: primaryColor.withOpacity(0.3 + 0.7 * scale1),
      ));

      elements.add(DNAAtom(
        x: x2,
        y: y,
        z: z2,
        radius: 8 * scale2,
        color: secondaryColor.withOpacity(0.3 + 0.7 * scale2),
      ));

      elements.add(DNAConnection(
        x1: x1,
        y1: y,
        z1: z1,
        x2: x2,
        y2: y,
        z2: z2,
        color: Colors.white.withOpacity(0.3 + 0.5 * ((scale1 + scale2) / 2)),
        width: 2 * ((scale1 + scale2) / 2),
      ));
    }

    // Sort by Z (back to front)
    elements.sort((a, b) => a.z.compareTo(b.z));

    // Draw
    for (var element in elements) {
      element.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant DNAPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.secondaryColor != secondaryColor;
  }
}

abstract class DNAElement {
  double get z;
  void draw(Canvas canvas);
}

class DNAAtom extends DNAElement {
  final double x;
  final double y;
  final double z;
  final double radius;
  final Color color;

  DNAAtom({
    required this.x,
    required this.y,
    required this.z,
    required this.radius,
    required this.color,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, color],
        stops: [0.1, 1.0],
        center: Alignment(-0.3, -0.3), // Simulate light source
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

    canvas.drawCircle(Offset(x, y), radius, paint);
  }
}

class DNAConnection extends DNAElement {
  final double x1;
  final double y1;
  final double z1;
  final double x2;
  final double y2;
  final double z2;
  final Color color;
  final double width;

  DNAConnection({
    required this.x1,
    required this.y1,
    required this.z1,
    required this.x2,
    required this.y2,
    required this.z2,
    required this.color,
    required this.width,
  });

  @override
  double get z => (z1 + z2) / 2; // Average Z for connection

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }
}
