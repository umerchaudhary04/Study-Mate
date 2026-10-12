import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudyMateApp());

    // Verify that StudyMate app starts
    expect(find.byType(StudyMateApp), findsOneWidget);
  });
}
