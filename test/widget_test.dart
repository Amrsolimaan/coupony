import 'package:flutter_test/flutter_test.dart';

import 'package:coupony/app.dart';

void main() {
  testWidgets('App renders correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app renders correctly.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
