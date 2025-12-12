import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich/main.dart';
import 'package:sandwich/views/profile_screen.dart';

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

  testWidgets('Profile screen can be opened from drawer', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Verify we're on order screen
    expect(find.text('Sandwich Counter'), findsOneWidget);
    
    // Open the drawer
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    
    // Find and tap the Profile menu item in the drawer
    final profileMenuItem = find.byKey(const Key('drawer_profile'));
    expect(profileMenuItem, findsOneWidget);
    
    await tester.tap(profileMenuItem);
    await tester.pumpAndSettle();

    // Verify we're now on the profile screen
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byKey(const Key('profile_name')), findsOneWidget);
    expect(find.byKey(const Key('profile_email')), findsOneWidget);
    expect(find.byKey(const Key('profile_phone')), findsOneWidget);
  });
}
