import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'model.dart';

class DNAPainter extends CustomPainter {
  final DNASystem system;
  final double time;
  final double rotationY;
  final double rotationX;
  final double zoom;

  DNAPainter({
    required this.system,
    required this.time,
    required this.rotationY,
    required this.rotationX,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;

    List<_Drawable> drawables = [];

    // Scale factor to convert model units (radius ~6) to screen pixels
    // Radius 6 * 15 = 90 pixels on screen
    const double worldScale = 15.0;

    // FOV acts as the camera distance for perspective division
    double fov = 600.0;

    // Rotation Matrix
    v.Matrix4 rotation = v.Matrix4.rotationX(rotationX) * v.Matrix4.rotationY(rotationY);

    // Process Bonds
    for (var bond in system.bonds) {
      v.Vector3 startPos = _applyWave(bond.start.position);
      v.Vector3 endPos = _applyWave(bond.end.position);

      v.Vector3 tStart = _transform(startPos, rotation);
      v.Vector3 tEnd = _transform(endPos, rotation);

      // Calculate depth
      double z = (tStart.z + tEnd.z) / 2;

      // Don't draw if behind "camera plane" (simplification)
      // Assuming camera is at +z = fov

      drawables.add(_DrawableLine(tStart, tEnd, bond.color, bond.thickness, z, worldScale, zoom));
    }

    // Process Particles
    for (var particle in system.particles) {
      v.Vector3 pos = _applyWave(particle.position);
      v.Vector3 tPos = _transform(pos, rotation);
      drawables.add(_DrawableSphere(tPos, particle.color, particle.radius, tPos.z, particle.glowIntensity, worldScale, zoom));
    }

    // Sort by Z (furthest first)
    drawables.sort((a, b) => a.z.compareTo(b.z));

    // Draw
    for (var d in drawables) {
      d.draw(canvas, cx, cy, fov);
    }
  }

  v.Vector3 _applyWave(v.Vector3 original) {
    v.Vector3 pos = original.clone();

    // Torsional wave
    double wave = sin(pos.y * 0.3 + time * 1.5) * 0.3;

    double cosW = cos(wave);
    double sinW = sin(wave);
    double nx = pos.x * cosW - pos.z * sinW;
    double nz = pos.x * sinW + pos.z * cosW;
    pos.x = nx;
    pos.z = nz;

    // Breathing
    double breath = 1.0 + 0.05 * sin(time * 2.0 + pos.y * 0.2);
    pos.x *= breath;
    pos.z *= breath;

    return pos;
  }

  v.Vector3 _transform(v.Vector3 pos, v.Matrix4 rot) {
    return rot.transform3(pos.clone());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

abstract class _Drawable {
  double z;
  _Drawable(this.z);
  void draw(Canvas canvas, double cx, double cy, double fov);
}

class _DrawableLine extends _Drawable {
  v.Vector3 start;
  v.Vector3 end;
  Color color;
  double thickness;
  double worldScale;
  double zoom;

  _DrawableLine(this.start, this.end, this.color, this.thickness, double z, this.worldScale, this.zoom) : super(z);

  @override
  void draw(Canvas canvas, double cx, double cy, double fov) {
    // Perspective projection
    double scaleStart = (fov / (fov - start.z * worldScale)) * zoom;
    double scaleEnd = (fov / (fov - end.z * worldScale)) * zoom;

    // Simple clipping if behind camera
    if (scaleStart < 0 || scaleEnd < 0) return;

    Offset p1 = Offset(start.x * worldScale * scaleStart + cx, start.y * worldScale * scaleStart + cy);
    Offset p2 = Offset(end.x * worldScale * scaleEnd + cx, end.y * worldScale * scaleEnd + cy);

    double depthAlpha = ((scaleStart + scaleEnd) / 2).clamp(0.2, 1.0);

    // Using withValues(alpha: ...) to avoid deprecation
    Paint paint = Paint()
      ..color = color.withValues(alpha: (color.a * depthAlpha).clamp(0.0, 1.0))
      ..strokeWidth = thickness * worldScale * 0.5 * depthAlpha * zoom // Scale line thickness too
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(p1, p2, paint);
  }
}

class _DrawableSphere extends _Drawable {
  v.Vector3 pos;
  Color color;
  double radius;
  double glow;
  double worldScale;
  double zoom;

  _DrawableSphere(this.pos, this.color, this.radius, double z, this.glow, this.worldScale, this.zoom) : super(z);

  @override
  void draw(Canvas canvas, double cx, double cy, double fov) {
    double scale = (fov / (fov - pos.z * worldScale)) * zoom;
    if (scale < 0) return;

    Offset center = Offset(pos.x * worldScale * scale + cx, pos.y * worldScale * scale + cy);

    // Visual radius in pixels
    double r = radius * worldScale * scale;

    if (r < 0.5) return;

    double depthAlpha = scale.clamp(0.0, 1.0);

    // Glow
    if (glow > 0) {
      Paint glowPaint = Paint()
        ..color = color.withValues(alpha: (0.4 * depthAlpha).clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.5);
      canvas.drawCircle(center, r * 2.5, glowPaint);
    }

    // Sphere Gradient
    Paint paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: depthAlpha),
          color.withValues(alpha: depthAlpha),
          color.withValues(alpha: (depthAlpha * 0.5).clamp(0.0, 1.0)),
        ],
        stops: const [0.0, 0.4, 1.0],
        focal: const Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawCircle(center, r, paint);
  }
}
