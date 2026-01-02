import 'dart:math';
import 'package:vector_math/vector_math_64.dart';
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

  // Parameters for the helix
  static const double risePerBasePair = 0.5; // Vertical distance
  static const double radius = 3.0; // Helix radius
  static const int basePairsCount = 40; // Number of base pairs
  static const double twistsPerBasePair = 0.4; // Rotation per step (radians)

  DNASystem() {
    _generateDNA();
    _addFloatingParticles();
  }

  void _generateDNA() {
    for (int i = 0; i < basePairsCount; i++) {
      double y = (i - basePairsCount / 2) * risePerBasePair;
      double angle = i * twistsPerBasePair;

      // Backbone positions (Strand A and Strand B)
      Vector3 posA = Vector3(
        radius * cos(angle),
        y,
        radius * sin(angle),
      );

      Vector3 posB = Vector3(
        radius * cos(angle + pi), // 180 degrees offset
        y,
        radius * sin(angle + pi),
      );

      // Create backbone particles
      Particle pA = Particle(
        position: posA,
        color: Colors.blueAccent.withOpacity(0.8),
        radius: 0.4,
        glowIntensity: 0.5
      );
      Particle pB = Particle(
        position: posB,
        color: Colors.purpleAccent.withOpacity(0.8),
        radius: 0.4,
        glowIntensity: 0.5
      );

      particles.add(pA);
      particles.add(pB);

      // Connect to previous particles to form rails (if not first)
      if (i > 0) {
        // We know the previous two particles are at index -2 and -1 relative to current addition
        // But easier to just store them or access list
        int lastIndex = particles.length - 1;
        // pB is at lastIndex, pA is at lastIndex - 1
        // Previous pB is at lastIndex - 2, Previous pA is at lastIndex - 3

        Bond railA = Bond(
          start: particles[lastIndex - 3],
          end: pA,
          color: Colors.blue.withOpacity(0.3),
          thickness: 2.0
        );
        Bond railB = Bond(
          start: particles[lastIndex - 2],
          end: pB,
          color: Colors.purple.withOpacity(0.3),
          thickness: 2.0
        );
        bonds.add(railA);
        bonds.add(railB);
      }

      // Base pairs (Steps)
      // A-T or C-G logic can be randomized.
      // Let's make the bond split in the middle to allow "breathing" visualization later
      // Or just a single line for now.
      // User wants: "Base pairs: solid, denser material with subtle inner glow"

      // Let's add two inner particles for the bases themselves
      Vector3 innerA = posA * 0.6 + Vector3(0, y, 0) * 0.4; // Interpolate towards center
      Vector3 innerB = posB * 0.6 + Vector3(0, y, 0) * 0.4; // logic: posA is (x,y,z), we want (0,y,0) is center.
      // Actually vector math: lerp(posA, center, t). Center is (0,y,0).
      Vector3 center = Vector3(0, y, 0);
      Vector3 basePosA = Vector3.zero()..setFrom(posA)..sub(center)..scale(0.6)..add(center);
      Vector3 basePosB = Vector3.zero()..setFrom(posB)..sub(center)..scale(0.6)..add(center);

      Color baseColorA = (i % 2 == 0) ? Colors.orange : Colors.green; // Arbitrary A/C
      Color baseColorB = (i % 2 == 0) ? Colors.yellow : Colors.red;   // Arbitrary T/G

      Particle baseAtomA = Particle(position: basePosA, color: baseColorA, radius: 0.6);
      Particle baseAtomB = Particle(position: basePosB, color: baseColorB, radius: 0.6);

      particles.add(baseAtomA);
      particles.add(baseAtomB);

      // Connect backbone to base
      bonds.add(Bond(start: pA, end: baseAtomA, color: Colors.grey.withOpacity(0.5), thickness: 1.0));
      bonds.add(Bond(start: pB, end: baseAtomB, color: Colors.grey.withOpacity(0.5), thickness: 1.0));

      // Hydrogen bond (middle)
      bonds.add(Bond(
        start: baseAtomA,
        end: baseAtomB,
        color: Colors.white.withOpacity(0.2),
        thickness: 0.5
      ));
    }
  }

  void _addFloatingParticles() {
    Random rng = Random();
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        position: Vector3(
          (rng.nextDouble() - 0.5) * 15,
          (rng.nextDouble() - 0.5) * 20,
          (rng.nextDouble() - 0.5) * 15,
        ),
        color: Colors.white.withOpacity(0.3),
        radius: rng.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  // Update logic for animation
  void update(double time) {
    // Here we can apply "breathing" or wave effects without permanently destroying the base structure.
    // However, since we stored mutable Vector3s, we need to be careful.
    // Best practice: Store initial positions and apply offsets every frame.
    // For simplicity in this iteration, we will just apply rotation in the renderer,
    // but for "non-uniform motion" we might want to offset positions here.
  }
}
