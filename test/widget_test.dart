import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatheruk/main.dart';

void main() {
  testWidgets('WeatherUK home screen smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: WeatherUKApp(),
      ),
    );

    // Verify app renders
    expect(find.byType(WeatherUKApp), findsOneWidget);
  });
}
