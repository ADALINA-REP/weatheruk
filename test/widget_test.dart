import 'package:flutter_test/flutter_test.dart';
import 'package:weatheruk/main.dart';

void main() {
  testWidgets('WeatherUK home screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that WeatherUK app bar and main weather info are rendered.
    expect(find.text('WeatherUK Radar'), findsOneWidget);
    expect(find.text('London, UK'), findsOneWidget);
  });
}

