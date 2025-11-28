import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich/main.dart';
import 'package:sandwich/models/sandwich.dart';

void main() {
  group('App', () {
    testWidgets('renders OrderScreen as home', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(OrderScreen), findsOneWidget);
    });
  });

  group('OrderScreen - Quantity', () {
    testWidgets('shows initial title and sandwich info',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('Sandwich Counter'), findsOneWidget);
      expect(find.textContaining('white footlong sandwich'), findsOneWidget);
    });

    testWidgets('increments quantity when + icon tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      // tap the quantity add icon (Icons.add)
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
      // now there should be one sandwich emoji displayed (initial 1 -> 2 emojis)
      expect(find.textContaining('🥪'), findsWidgets);
    });

    testWidgets('decrements quantity when - icon tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      // ensure we have at least one increment first so decrement does something
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();
      // now decrement
      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pump();
      // should still show sandwich info
      expect(find.textContaining('white footlong sandwich'), findsOneWidget);
    });

    testWidgets('does not decrement below zero', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      // repeatedly tap remove until it would go below zero
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.remove).first);
        await tester.pump();
      }
      // ensure UI still shows sandwich info (quantity should not go negative)
      expect(find.textContaining('white footlong sandwich'), findsOneWidget);
    });

    testWidgets('does not increment above maxQuantity',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      // tap the + icon many times
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();
      }
      // expect 5 sandwiches (max) shown with 5 emojis
      expect(find.text('5 white footlong sandwich(es): 🥪🥪🥪🥪🥪'),
          findsOneWidget);
    });
  });

  group('OrderScreen - Controls', () {
    testWidgets('changes bread type with DropdownMenu',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byType(DropdownMenu<BreadType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('wheat').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('wheat footlong sandwich'), findsOneWidget);
      await tester.tap(find.byType(DropdownMenu<BreadType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('wholemeal').last);
      await tester.pumpAndSettle();
      expect(
          find.textContaining('wholemeal footlong sandwich'), findsOneWidget);
    });

    testWidgets('updates note with TextField', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.enterText(
          find.byKey(const Key('notes_textfield')), 'Extra mayo');
      await tester.pump();
      expect(find.text('Note: Extra mayo'), findsOneWidget);
    });
  });

  group('StyledButton', () {
    testWidgets('renders with icon and label', (WidgetTester tester) async {
      const testButton = StyledButton(
        onPressed: null,
        icon: Icons.add,
        label: 'Test Add',
        colour: Colors.blue,
      );
      const testApp = MaterialApp(
        home: Scaffold(body: testButton),
      );
      await tester.pumpWidget(testApp);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Test Add'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('OrderItemDisplay', () {
    testWidgets('shows correct text and note for zero sandwiches',
        (WidgetTester tester) async {
      const widgetToBeTested = OrderItemDisplay(
        0,
        'footlong',
        BreadType.white,
        'No notes added.',
      );
      const testApp = MaterialApp(
        home: Scaffold(body: widgetToBeTested),
      );
      await tester.pumpWidget(testApp);
      expect(find.text('0 white footlong sandwich(es): '), findsOneWidget);
      expect(find.text('Note: No notes added.'), findsOneWidget);
    });

    testWidgets('shows correct text and emoji for three sandwiches',
        (WidgetTester tester) async {
      const widgetToBeTested = OrderItemDisplay(
        3,
        'footlong',
        BreadType.white,
        'No notes added.',
      );
      const testApp = MaterialApp(
        home: Scaffold(body: widgetToBeTested),
      );
      await tester.pumpWidget(testApp);
      expect(
          find.text('3 white footlong sandwich(es): 🥪🥪🥪'), findsOneWidget);
      expect(find.text('Note: No notes added.'), findsOneWidget);
    });

    testWidgets('shows correct bread and type for two six-inch wheat',
        (WidgetTester tester) async {
      const widgetToBeTested = OrderItemDisplay(
        2,
        'six-inch',
        BreadType.wheat,
        'No pickles',
      );
      const testApp = MaterialApp(
        home: Scaffold(body: widgetToBeTested),
      );
      await tester.pumpWidget(testApp);
      expect(find.text('2 wheat six-inch sandwich(es): 🥪🥪'), findsOneWidget);
      expect(find.text('Note: No pickles'), findsOneWidget);
    });

    testWidgets('shows correct bread and type for one wholemeal footlong',
        (WidgetTester tester) async {
      const widgetToBeTested = OrderItemDisplay(
        1,
        'footlong',
        BreadType.wholemeal,
        'Lots of lettuce',
      );
      const testApp = MaterialApp(
        home: Scaffold(body: widgetToBeTested),
      );
      await tester.pumpWidget(testApp);
      expect(
          find.text('1 wholemeal footlong sandwich(es): 🥪'), findsOneWidget);
      expect(find.text('Note: Lots of lettuce'), findsOneWidget);
    });
  });

  group('OrderScreen - Toggle', () {
    testWidgets('shows sliding widget toggles correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());

      expect(find.textContaining('white footlong sandwich'), findsOneWidget);

      await tester.tap(find.byKey(const Key('size_switch')));
      await tester.pump();
      expect(find.textContaining('six-inch sandwich'), findsOneWidget);

      await tester.tap(find.byKey(const Key('size_switch')));
      await tester.pump();
      expect(find.textContaining('footlong sandwich'), findsOneWidget);
    });
  });

  group('OrderScreen - Cart', () {
    testWidgets('shows SnackBar confirmation when Add to Cart tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());

      // tap the Add to Cart button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add to Cart'));
      await tester.pump(); // start animations / SnackBar
      await tester.pump(const Duration(seconds: 1)); // allow SnackBar to appear

      // SnackBar content includes 'Added' (we assert the confirmation is shown)
      expect(find.textContaining('Added'), findsOneWidget);
    });

    testWidgets('cart summary updates when Add to Cart tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());

      // initial summary
      expect(find.byKey(const Key('cart_summary')), findsOneWidget);
      expect(find.text('Cart: 0 items — Total: \$0.00'), findsOneWidget);

      // tap Add to Cart (initial quantity = 1, footlong price = 11.00)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add to Cart'));
      await tester.pump(); // process add
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Cart: 1 items — Total: \$11.00'), findsOneWidget);
    });
  });
}