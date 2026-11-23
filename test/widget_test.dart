import 'package:flutter_test/flutter_test.dart';
import 'package:map_flutter/main.dart';

void main() {
  testWidgets('App loads MapScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
