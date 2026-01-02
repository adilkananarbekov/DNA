import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dna/model.dart';
import 'dna/renderer.dart';

void main() {
  runApp(const DNAApp());
}

class DNAApp extends StatelessWidget {
  const DNAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const DNAScene(),
    );
  }
}

class DNAScene extends StatefulWidget {
  const DNAScene({super.key});

  @override
  State<DNAScene> createState() => _DNASceneState();
}

class _DNASceneState extends State<DNAScene> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late DNASystem _dnaSystem;

  double _time = 0.0;
  double _rotationY = 0.0;
  double _rotationX = 0.0;
  double _zoom = 1.0;

  // Interaction
  Offset? _lastPan;

  @override
  void initState() {
    super.initState();
    _dnaSystem = DNASystem();

    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
        // Auto-rotate slowly if not interacting?
        // User said: "does NOT spin uniformly", "Torsional waves"
        // The rotation is handled in renderer via _time for waves.
        // But we can add a slow global rotation too.
        _rotationY += 0.005;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (details) {
          _lastPan = details.localPosition;
        },
        onPanUpdate: (details) {
          if (_lastPan != null) {
            final dx = details.localPosition.dx - _lastPan!.dx;
            final dy = details.localPosition.dy - _lastPan!.dy;
            setState(() {
              _rotationY += dx * 0.01;
              _rotationX -= dy * 0.01;
            });
            _lastPan = details.localPosition;
          }
        },
        onPanEnd: (_) {
          _lastPan = null;
        },
        onScaleUpdate: (details) {
          setState(() {
            _zoom = (_zoom * details.scale).clamp(0.5, 3.0);
          });
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF000000),
              ],
            ),
          ),
          child: CustomPaint(
            painter: DNAPainter(
              system: _dnaSystem,
              time: _time,
              rotationY: _rotationY,
              rotationX: _rotationX,
              zoom: _zoom,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Reset view
            _rotationY = 0;
            _rotationX = 0;
            _zoom = 1.0;
          });
        },
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blueAccent.withOpacity(0.5),
      ),
    );
  }
}
