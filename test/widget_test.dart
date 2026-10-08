// Basic Flutter widget test for F&O Trader app

import 'package:flutter_test/flutter_test.dart';
import 'package:fno_trader/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FnoTraderApp());
    
    // Verify app loads
    expect(find.byType(FnoTraderApp), findsOneWidget);
  });
}
