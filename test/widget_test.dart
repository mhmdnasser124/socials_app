// This is a basic Flutter widgets test.
//
// To perform an interaction with a widgets in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widgets
// tree, read text, and verify that the values of widgets properties are correct.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socials_app/core/UI/resources/localization_manager.dart';
import 'package:socials_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders socials tabs', (tester) async {
    await EasyLocalization.ensureInitialized();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: LocalizationManager.supportedLocales,
        path: LocalizationManager.translationsPath,
        fallbackLocale: LocalizationManager.fallbackLocale,
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('My Posts'), findsOneWidget);
  });
}
