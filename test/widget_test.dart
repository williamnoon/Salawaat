import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salawaat/main.dart';

void main() {
  testWidgets('onboarding opens the main Salawaat experience', (tester) async {
    await tester.pumpWidget(const SalawaatApp());

    expect(find.text('Increase your ṣalāh upon him ﷺ'), findsOneWidget);
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    expect(find.text('Salawāt'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);
  });

  testWidgets('recording salawat increments the daily count', (tester) async {
    await tester.pumpWidget(const SalawaatApp());
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I said it'));
    await tester.pump();

    expect(find.text('28'), findsOneWidget);
  });

  testWidgets('rhythm can change to thirty minutes', (tester) async {
    await tester.pumpWidget(const SalawaatApp());
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rhythm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Every 30 minutes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(find.text('Every 30 min'), findsOneWidget);
    expect(find.text('in 30 minutes'), findsOneWidget);
  });
}
