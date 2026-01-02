import 'package:flutter_test/flutter_test.dart';
import 'package:main_page/main.dart';

void main() {
  testWidgets('DNA App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DNAApp());

    // Verify that the app starts.
    expect(find.byType(DNAApp), findsOneWidget);
    expect(find.byType(DNAScene), findsOneWidget);
  });
}
