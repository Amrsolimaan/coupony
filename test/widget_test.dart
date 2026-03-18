import 'package:flutter_test/flutter_test.dart';

import 'package:coupon/app.dart';

void main() {
  testWidgets('App renders correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app renders the "Coupony App" text.
    expect(find.text('Coupony App'), findsOneWidget);
  });
}
