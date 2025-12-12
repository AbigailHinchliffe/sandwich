import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich/main.dart'; 

void main() {
  testWidgets('Profile screen shows fields and save works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    // verify fields present
    expect(find.byKey(const Key('profile_name')), findsOneWidget);
    expect(find.byKey(const Key('profile_email')), findsOneWidget);
    expect(find.byKey(const Key('profile_phone')), findsOneWidget);
    expect(find.byKey(const Key('profile_save')), findsOneWidget);
    expect(find.byKey(const Key('profile_cancel')), findsOneWidget);

    // enter values
    await tester.enterText(find.byKey(const Key('profile_name')), 'Test User');
    await tester.enterText(find.byKey(const Key('profile_email')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('profile_phone')), '1234567890');

    // tap save
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pump(); // start SnackBar animation
    expect(find.text('Profile saved'), findsOneWidget);
  });

  testWidgets('Profile save requires name', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    // name empty -> show validation
    await tester.enterText(find.byKey(const Key('profile_name')), '');
    await tester.tap(find.byKey(const Key('profile_save')));
    await tester.pump();
    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('Profile screen can be opened from Order screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Verify we're on order screen
    expect(find.text('Sandwich Counter'), findsOneWidget);
    
    // Find and tap the "Open Profile" button
    final openProfileButton = find.byKey(const Key('open_profile'));
    expect(openProfileButton, findsOneWidget);
    
    await tester.ensureVisible(openProfileButton);
    await tester.tap(openProfileButton);
    await tester.pumpAndSettle();

    // Verify we're now on the profile screen
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byKey(const Key('profile_name')), findsOneWidget);
    expect(find.byKey(const Key('profile_email')), findsOneWidget);
    expect(find.byKey(const Key('profile_phone')), findsOneWidget);
  });
}
