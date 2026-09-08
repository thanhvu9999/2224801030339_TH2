import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

Finder findDisplay(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == text && widget.style?.fontSize == 72,
  );
}

void main() {
  testWidgets('Calculator basic addition test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify initially displays 0
    expect(findDisplay('0'), findsOneWidget);

    // Tap 7, +, 8, =
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('8'));
    await tester.pump();
    expect(findDisplay('7+8'), findsOneWidget);

    await tester.tap(find.text('='));
    await tester.pump();
    expect(findDisplay('15'), findsOneWidget);
  });

  testWidgets('Calculator multiplication with decimals and C button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 2, 5 × 2 = 5
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text(','));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('×'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(findDisplay('5'), findsOneWidget);

    // Press C to clear
    await tester.tap(find.text('C'));
    await tester.pump();
    expect(findDisplay('0'), findsOneWidget);
  });

  testWidgets('Calculator division by zero handles error safely', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 9 ÷ 0 = Lỗi
    await tester.tap(find.text('9'));
    await tester.pump();
    await tester.tap(find.text('÷'));
    await tester.pump();
    await tester.tap(find.text('0').last); // key button
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(findDisplay('Lỗi'), findsOneWidget);

    // Clear after error
    await tester.tap(find.text('C'));
    await tester.pump();
    expect(findDisplay('0'), findsOneWidget);
  });

  testWidgets('Calculator backspace test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Type 1, 2, 3
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(findDisplay('123'), findsOneWidget);

    // Tap backspace
    await tester.tap(find.text('⌫'));
    await tester.pump();
    expect(findDisplay('12'), findsOneWidget);

    await tester.tap(find.text('⌫'));
    await tester.pump();
    expect(findDisplay('1'), findsOneWidget);

    await tester.tap(find.text('⌫'));
    await tester.pump();
    expect(findDisplay('0'), findsOneWidget);
  });

  testWidgets('Calculator subtraction and decimal result test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 7 - 2,5 = 4,5
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('-'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text(','));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(findDisplay('4,5'), findsOneWidget);
  });

  testWidgets('Continuous calculation after equals', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 10 + 5 = 15
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('0').last);
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(findDisplay('15'), findsOneWidget);

    // Continue with + 5 = 20
    await tester.tap(find.text('+'));
    await tester.pump();
    expect(findDisplay('15+'), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(findDisplay('20'), findsOneWidget);
  });

  testWidgets('Leading zero and comma prevention', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap 0 multiple times, then 5 -> should be 5
    await tester.tap(find.text('0').last);
    await tester.pump();
    await tester.tap(find.text('0').last);
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(findDisplay('5'), findsOneWidget);

    // Tap , twice then 2 -> should be 5,2
    await tester.tap(find.text(','));
    await tester.pump();
    await tester.tap(find.text(','));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    expect(findDisplay('5,2'), findsOneWidget);
  });
}

