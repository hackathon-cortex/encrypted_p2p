import 'package:flutter_test/flutter_test.dart';
import 'package:encrypted_p2p/app.dart';

void main() {
  testWidgets('CortexApp launches with initial splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CortexApp());
    expect(find.text('CORTEX'), findsOneWidget);

    // Let the splash timer finish and transition to login
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Login screen is reached
    expect(find.text('AUTHENTICATE'), findsOneWidget);
  });
}
