import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

Finder findDisplay(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == text && widget.style?.fontSize == 64,
  );
}

void main() {
  testWidgets('Calculator basic addition test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(findDisplay('0'), findsOneWidget);

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

  testWidgets('Calculator square (x²) and square root (√x)', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 5 -> x² -> 25
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('x²'));
    await tester.pump();
    expect(findDisplay('25'), findsOneWidget);

    // C
    await tester.tap(find.text('C'));
    await tester.pump();

    // 9 -> √x -> 3
    await tester.tap(find.text('9'));
    await tester.pump();
    await tester.tap(find.text('√x'));
    await tester.pump();
    expect(findDisplay('3'), findsOneWidget);
  });

  testWidgets('Calculator reciprocal (¹/x) and percentage (%)', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 4 -> ¹/x -> 0,25
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.tap(find.text('¹/x'));
    await tester.pump();
    expect(findDisplay('0,25'), findsOneWidget);

    // C
    await tester.tap(find.text('C'));
    await tester.pump();

    // 50 -> % -> 0,5
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('0').last);
    await tester.pump();
    await tester.tap(find.text('%'));
    await tester.pump();
    expect(findDisplay('0,5'), findsOneWidget);
  });

  testWidgets('Calculator toggle sign (+/-) and CE', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 8 -> +/- -> -8 -> +/- -> 8
    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('+/-'));
    await tester.pump();
    expect(findDisplay('-8'), findsOneWidget);

    await tester.tap(find.text('+/-'));
    await tester.pump();
    expect(findDisplay('8'), findsOneWidget);

    // Type + 9 then CE -> should clear 9 leaving 8+
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('9'));
    await tester.pump();
    expect(findDisplay('8+9'), findsOneWidget);

    await tester.tap(find.text('CE'));
    await tester.pump();
    expect(findDisplay('8+'), findsOneWidget);
  });

  testWidgets('Calculator history recording and display', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 3 × 4 = 12
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('×'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(findDisplay('12'), findsOneWidget);

    // Open history bottom sheet
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    // Verify history content
    expect(find.text('Lịch sử tính toán'), findsOneWidget);
    expect(find.text('3×4'), findsOneWidget);
    expect(find.text('= 12'), findsOneWidget);

    // Close sheet
    await tester.tap(find.text('= 12'));
    await tester.pumpAndSettle();
    expect(findDisplay('12'), findsOneWidget);
  });

  testWidgets('Calculator division by zero handles error safely', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 8 ÷ 0 = Lỗi
    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.tap(find.text('÷'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(findDisplay('Lỗi'), findsOneWidget);

    // Press C
    await tester.tap(find.text('C'));
    await tester.pump();
    expect(findDisplay('0'), findsOneWidget);
  });

  testWidgets('Calculator memory buttons test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Enter 20 -> MS
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('MS'));
    await tester.pump();

    // Verify SnackBar shown
    expect(find.text('Bộ nhớ: 20'), findsOneWidget);
  });
}

