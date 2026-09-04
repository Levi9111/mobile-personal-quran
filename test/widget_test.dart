import 'package:flutter_test/flutter_test.dart';
import 'package:noor_quran/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NoorApp());
    expect(find.text('Noor'), findsOneWidget);
  });
}
