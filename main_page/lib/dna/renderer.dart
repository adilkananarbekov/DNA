import 'dart:math';
import 'dart:ui';
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
    // Setup Viewport
    double cx = size.width / 2;
    double cy = size.height / 2;

    // Camera parameters
    // We orbit around the center (0,0,0)
    // Actually we will rotate the world and keep camera fixed.

    // Create transformation matrix
    // 1. Torsional waves + Breathing (modify model positions temporarily for drawing)

    // We need to collect all drawables (lines and circles) and sort them by Z for correct occlusion.
    List<_Drawable> drawables = [];

    // Pre-calculate projection matrix or just manual projection
    // Manual projection is often easier for simple 3D clouds

    // World Transform
    v.Matrix4 matrix = v.Matrix4.identity();
    matrix.translate(0.0, 0.0, -20.0); // Move camera back? Or move object forward.
    // Let's assume camera is at (0,0,20) looking at (0,0,0).
    // So we translate world by (0,0,-20) relative to camera.
    // Or just rotate the points and project: x_proj = x / (z + dist) * scale

    double fov = 300.0 * zoom;

    // Apply rotations
    v.Matrix4 rotation = v.Matrix4.rotationX(rotationX) * v.Matrix4.rotationY(rotationY);

    // Process Bonds first (as lines)
    for (var bond in system.bonds) {
      v.Vector3 start = _transform(bond.start.position, rotation);
      v.Vector3 end = _transform(bond.end.position, rotation);

      // Calculate average Z for sorting
      double z = (start.z + end.z) / 2;

      drawables.add(_DrawableLine(start, end, bond.color, bond.thickness, z));
    }

    // Process Particles
    for (var particle in system.particles) {
      // Apply wave/breathing effect here
      v.Vector3 pos = particle.position.clone();

      // Torsional wave: twist based on Y height and time
      double wave = sin(pos.y * 0.5 + time * 2) * 0.5;
      // Rotation around Y axis for the wave
      double cosW = cos(wave);
      double sinW = sin(wave);
      double nx = pos.x * cosW - pos.z * sinW;
      double nz = pos.x * sinW + pos.z * cosW;
      pos.x = nx;
      pos.z = nz;

      // Breathing: expand/contract radius
      double breath = 1.0 + 0.1 * sin(time * 1.5 + pos.y * 0.3);
      pos.x *= breath;
      pos.z *= breath;

      v.Vector3 tPos = _transform(pos, rotation);
      drawables.add(_DrawableCircle(tPos, particle.color, particle.radius, tPos.z, particle.glowIntensity));
    }

    // Sort by Z (furthest first, so smallest Z if using OpenGL coords where -Z is forward?
    // Here we define +Z towards camera for sorting usually, or just Z value.
    // _transform rotates. Let's assume +Z comes out of screen.
    // So we paint smallest Z (furthest negative) first.
    drawables.sort((a, b) => a.z.compareTo(b.z));

    // Draw
    for (var d in drawables) {
      d.draw(canvas, cx, cy, fov);
    }
  }

  v.Vector3 _transform(v.Vector3 pos, v.Matrix4 rot) {
    // Apply rotation
    v.Vector3 rotated = rot.transform3(pos.clone());
    return rotated;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for animation
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

  _DrawableLine(this.start, this.end, this.color, this.thickness, double z) : super(z);

  @override
  void draw(Canvas canvas, double cx, double cy, double fov) {
    double scaleStart = fov / (fov - start.z); // Perspective division
    double scaleEnd = fov / (fov - end.z);

    if (scaleStart < 0 || scaleEnd < 0) return; // Behind camera (assuming camera at z=fov effectively)

    Offset p1 = Offset(start.x * scaleStart + cx, start.y * scaleStart + cy);
    Offset p2 = Offset(end.x * scaleEnd + cx, end.y * scaleEnd + cy);

    // Fade distant lines
    double opacity = (scaleStart + scaleEnd) / 2;
    opacity = opacity.clamp(0.1, 1.0);

    Paint paint = Paint()
      ..color = color.withOpacity(color.opacity * opacity)
      ..strokeWidth = thickness * opacity
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(p1, p2, paint);
  }
}

class _DrawableCircle extends _Drawable {
  v.Vector3 pos;
  Color color;
  double radius;
  double glow;

  _DrawableCircle(this.pos, this.color, this.radius, double z, this.glow) : super(z);

  @override
  void draw(Canvas canvas, double cx, double cy, double fov) {
    double scale = fov / (fov - pos.z);
    if (scale < 0) return;

    Offset center = Offset(pos.x * scale + cx, pos.y * scale + cy);
    double r = radius * scale * 20; // Scale up for visibility

    // Alpha based on depth
    double alpha = scale.clamp(0.0, 1.0);

    // Glow effect
    if (glow > 0) {
      Paint glowPaint = Paint()
        ..color = color.withOpacity(0.3 * alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 2);
      canvas.drawCircle(center, r * 3, glowPaint);
    }

    Paint paint = Paint()
      ..color = color.withOpacity(color.opacity * alpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, r, paint);
  }
}
