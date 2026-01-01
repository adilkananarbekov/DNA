import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:main_page/main.dart';
import 'package:main_page/dna_helix.dart';

void main() {
  testWidgets('DNA Helix App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the title is present
    expect(find.text('3D DNA Helix'), findsOneWidget);

    // Verify that the DNAHelix widget is present
    expect(find.byType(DNAHelix), findsOneWidget);

    // Verify controls are present
    expect(find.textContaining('Speed:'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing); // It starts playing, so should show pause
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // Test pause interaction
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Test speed increase
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();
    // Verify speed text update if possible, but exact value might be tricky to match with just textContaining
  });
}
