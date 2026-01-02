import 'package:flutter_test/flutter_test.dart';
import 'package:main_page/dna/model.dart';

void main() {
  test('DNA System generation', () {
    final system = DNASystem();
    expect(system.particles.isNotEmpty, true);
    expect(system.bonds.isNotEmpty, true);

    // Check if we have roughly expected number of particles
    // 40 base pairs * (2 backbone + 2 base) = 160 particles
    // + 50 floating
    expect(system.particles.length, greaterThan(150));
  });

  test('Particle position integrity', () {
    final system = DNASystem();
    for (var p in system.particles) {
      expect(p.position.x.isNaN, false);
      expect(p.position.y.isNaN, false);
      expect(p.position.z.isNaN, false);
    }
  });
}
