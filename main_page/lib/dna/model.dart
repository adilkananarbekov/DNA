import 'dart:math';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter/material.dart';

/// Represents a single particle in the system (atom, ion, etc.)
class Particle {
  Vector3 position;
  Color color;
  double radius;
  double glowIntensity;

  Particle({
    required this.position,
    required this.color,
    this.radius = 2.0,
    this.glowIntensity = 0.0,
  });
}

/// Represents a bond between two particles
class Bond {
  final Particle start;
  final Particle end;
  final Color color;
  final double thickness;

  Bond({
    required this.start,
    required this.end,
    this.color = Colors.white,
    this.thickness = 1.0,
  });
}

/// The entire DNA system containing particles and bonds
class DNASystem {
  List<Particle> particles = [];
  List<Bond> bonds = [];

  // Adjusted Parameters for better visibility
  static const double risePerBasePair = 0.8;
  static const double radius = 6.0;
  static const int basePairsCount = 30;
  static const double twistsPerBasePair = 0.5; // ~28 degrees
  static const double majorGrooveOffset = 0.5; // Offset for major/minor groove effect

  DNASystem() {
    _generateDNA();
    _addFloatingParticles();
  }

  void _generateDNA() {
    Particle? prevPA;
    Particle? prevPB;

    for (int i = 0; i < basePairsCount; i++) {
      double y = (i - basePairsCount / 2) * risePerBasePair;

      // Introduce groove asymmetry
      // Standard helix has even spacing, but DNA has major/minor grooves.
      // We can modulate the angle slightly or just accept B-DNA roughly 10.5 bp/turn.
      // Let's stick to regular spiral for visual clarity but add a slight offset if needed.
      // Or just keep it clean. Let's keep the regular twist but maybe adjust the phase.

      double angle = i * twistsPerBasePair;

      // Backbone positions (Strand A and Strand B)
      Vector3 posA = Vector3(
        radius * cos(angle),
        y,
        radius * sin(angle),
      );

      Vector3 posB = Vector3(
        radius * cos(angle + pi + majorGrooveOffset), // Offset one strand slightly to create grooves
        y,
        radius * sin(angle + pi + majorGrooveOffset),
      );

      // Create backbone particles (Phosphates) - Large and distinct
      Particle pA = Particle(
        position: posA,
        color: Colors.cyanAccent, // Bright distinct color
        radius: 0.8,
        glowIntensity: 0.8
      );
      Particle pB = Particle(
        position: posB,
        color: Colors.purpleAccent,
        radius: 0.8,
        glowIntensity: 0.8
      );

      particles.add(pA);
      particles.add(pB);

      // Connect to previous backbone particles to form rails
      if (prevPA != null && prevPB != null) {
        Bond railA = Bond(
          start: prevPA,
          end: pA,
          color: Colors.cyan.withOpacity(0.5),
          thickness: 3.0 // Thicker rails
        );
        Bond railB = Bond(
          start: prevPB,
          end: pB,
          color: Colors.purple.withOpacity(0.5),
          thickness: 3.0
        );
        bonds.add(railA);
        bonds.add(railB);
      }

      prevPA = pA;
      prevPB = pB;

      // Base pairs (The rungs)
      // Interpolate positions to creates bases
      Vector3 center = Vector3(0, y, 0);

      // Base A (closer to strand A)
      Vector3 basePosA = Vector3.zero()..setFrom(posA)..sub(center)..scale(0.7)..add(center);
      // Base B (closer to strand B)
      Vector3 basePosB = Vector3.zero()..setFrom(posB)..sub(center)..scale(0.7)..add(center);

      // Distinct colors for bases
      Color colorA = (i % 4 == 0) ? Colors.redAccent : (i % 4 == 1) ? Colors.blueAccent : (i % 4 == 2) ? Colors.greenAccent : Colors.orangeAccent;
      Color colorB = (i % 4 == 0) ? Colors.blueAccent : (i % 4 == 1) ? Colors.redAccent : (i % 4 == 2) ? Colors.orangeAccent : Colors.greenAccent;

      Particle baseAtomA = Particle(position: basePosA, color: colorA, radius: 0.5);
      Particle baseAtomB = Particle(position: basePosB, color: colorB, radius: 0.5);

      particles.add(baseAtomA);
      particles.add(baseAtomB);

      // Bond Backbone to Base
      bonds.add(Bond(start: pA, end: baseAtomA, color: Colors.grey.withOpacity(0.3), thickness: 1.5));
      bonds.add(Bond(start: pB, end: baseAtomB, color: Colors.grey.withOpacity(0.3), thickness: 1.5));

      // Hydrogen Bond (Base to Base)
      bonds.add(Bond(
        start: baseAtomA,
        end: baseAtomB,
        color: Colors.white.withOpacity(0.6),
        thickness: 2.0 // Distinct rung
      ));
    }
  }

  void _addFloatingParticles() {
    Random rng = Random();
    for (int i = 0; i < 30; i++) {
      particles.add(Particle(
        position: Vector3(
          (rng.nextDouble() - 0.5) * 30,
          (rng.nextDouble() - 0.5) * 40,
          (rng.nextDouble() - 0.5) * 30,
        ),
        color: Colors.white.withOpacity(0.1),
        radius: rng.nextDouble() * 0.4 + 0.1,
      ));
    }
  }
}
