import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemolife/features/requests/presentation/request_blood_screen.dart';

void main() {
  testWidgets('RequestBloodScreen renders form inputs and validates required fields',
      (WidgetTester tester) async {
    // Set viewport large enough for the scrollable form
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RequestBloodScreen(),
        ),
      ),
    );

    // Verify title and main fields exist
    expect(find.text('Request Blood'), findsOneWidget);
    expect(find.byKey(const Key('patientNameField')), findsOneWidget);
    expect(find.byKey(const Key('bloodGroupDropdown')), findsOneWidget);
    expect(find.byKey(const Key('hospitalField')), findsOneWidget);
    expect(find.byKey(const Key('contactPhoneField')), findsOneWidget);
    expect(find.byKey(const Key('submitRequestBtn')), findsOneWidget);

    // Initial quantity stepper is 1
    expect(find.text('1'), findsOneWidget);

    // Tap "+" quantity stepper button
    await tester.tap(find.byKey(const Key('incrementQuantityBtn')));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    // Tap "-" quantity stepper button
    await tester.tap(find.byKey(const Key('decrementQuantityBtn')));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // Scroll to submit button and tap with empty fields
    await tester.ensureVisible(find.byKey(const Key('submitRequestBtn')));
    await tester.tap(find.byKey(const Key('submitRequestBtn')));
    await tester.pumpAndSettle();

    // Verify inline validation errors appear
    expect(find.text('Please enter a name.'), findsOneWidget);
    expect(find.text('Please enter the hospital name.'), findsOneWidget);
    expect(find.text('Please enter a contact phone number.'), findsOneWidget);
  });
}
