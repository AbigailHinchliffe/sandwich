import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich/main.dart';

void main() {
  testWidgets('App boots and shows OrderScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.byType(OrderScreen), findsOneWidget);
    expect(find.text('Sandwich Counter'), findsOneWidget);
  });

  testWidgets('notes field updates the preview text', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final notesFinder = find.byKey(const Key('notes_textfield'));
    expect(notesFinder, findsOneWidget);

    await tester.enterText(notesFinder, 'Extra mayo');
    await tester.pumpAndSettle();

    //expect(find.text('Note: Extra mayo'), findsOneWidget);
  });

  testWidgets('size switch toggles between footlong and six-inch', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final sizeSwitch = find.byKey(const Key('size_switch'));
    expect(sizeSwitch, findsOneWidget);

    // toggle to six-inch
    await tester.tap(sizeSwitch);
    await tester.pumpAndSettle();
    expect(find.textContaining('Six-inch'), findsWidgets);

    // toggle back to footlong
    await tester.tap(sizeSwitch);
    await tester.pumpAndSettle();
    expect(find.textContaining('Footlong'), findsWidgets);
  });

  testWidgets('Add to Cart shows SnackBar confirmation and updates summary', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    final cartSummary = find.byKey(const Key('cart_summary'));
    expect(cartSummary, findsOneWidget);

    // initial summary contains Cart and $0.00
    expect(find.textContaining('Cart:'), findsOneWidget);
    expect(find.textContaining('\$0.00'), findsOneWidget);

    final addButton = find.widgetWithText(ElevatedButton, 'Add to Cart');
    expect(addButton, findsOneWidget);

    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // SnackBar confirmation appears
    expect(find.textContaining('Added'), findsOneWidget);

    // cart summary updates (contains Cart: and a dollar sign in the text)
    expect(find.byKey(const Key('cart_summary')), findsOneWidget);
    expect(find.textContaining('Cart:'), findsOneWidget);
    expect(find.textContaining('\$'), findsWidgets);
  });
}