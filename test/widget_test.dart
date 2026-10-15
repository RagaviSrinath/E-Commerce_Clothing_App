import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('NextGenApp smoke test - renders login screen initially', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const NextGenApp());
    await tester.pumpAndSettle();

    expect(find.text('NEXTGEN WARDROBE'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
