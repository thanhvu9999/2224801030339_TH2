import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF171717), // Nền tối sâu hơn
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = "0";
  bool _isEquationFinished = false;

  void _onPressed(String text) {
    if (text == "=") {
      _calculate();
      return;
    }

    setState(() {
      // Nút C: Xóa toàn bộ về trạng thái ban đầu
      if (text == "C") {
        _display = "0";
        _isEquationFinished = false;
        return;
      }

      // Nút ⌫: Xóa ký tự cuối cùng
      if (text == "⌫") {
        if (_display == "Lỗi" || _isEquationFinished) {
          _display = "0";
          _isEquationFinished = false;
        } else if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = "0";
        }
        return;
      }

      // Nút phép tính: +, -, ×, ÷
      if (["+", "-", "×", "÷"].contains(text)) {
        if (_display == "Lỗi") return;
        _isEquationFinished = false;

        String lastChar = _display[_display.length - 1];
        if (['+', '-', '×', '÷'].contains(lastChar)) {
          // Thay thế phép tính cuối nếu bấm liên tiếp các dấu phép tính
          _display = _display.substring(0, _display.length - 1) + text;
        } else if (lastChar == ',') {
          // Nếu ký tự cuối là dấu phẩy thì thay thế bằng phép tính
          _display = _display.substring(0, _display.length - 1) + text;
        } else {
          _display += text;
        }
        return;
      }

      // Nút dấu phẩy thập phân: ,
      if (text == ",") {
        if (_display == "Lỗi" || _isEquationFinished) {
          _display = "0,";
          _isEquationFinished = false;
          return;
        }

        // Lấy chuỗi của số hiện tại đang nhập (sau toán tử cuối cùng)
        int lastOpIndex = _display.lastIndexOf(RegExp(r'[+\-×÷]'));
        String currentNum = lastOpIndex == -1
            ? _display
            : _display.substring(lastOpIndex + 1);

        // Chỉ cho phép 1 dấu phẩy trong mỗi số
        if (!currentNum.contains(',')) {
          if (currentNum.isEmpty) {
            _display += "0,";
          } else {
            _display += ",";
          }
        }
        return;
      }

      // Nút số: 0 - 9
      if (_display == "Lỗi" || _isEquationFinished) {
        _display = text;
        _isEquationFinished = false;
        return;
      }

      if (_display == "0") {
        _display = text;
      } else {
        int lastOpIndex = _display.lastIndexOf(RegExp(r'[+\-×÷]'));
        String currentNum = lastOpIndex == -1
            ? _display
            : _display.substring(lastOpIndex + 1);

        // Tránh số 0 dư thừa ở đầu số như 5+03 -> chuyển thành 5+3
        if (currentNum == "0") {
          _display = _display.substring(0, _display.length - 1) + text;
        } else {
          _display += text;
        }
      }
    });
  }

  void _calculate() {
    if (_display == "Lỗi") return;

    // Loại bỏ các toán tử hoặc dấu phẩy còn sót lại ở cuối biểu thức
    String expression = _display;
    while (expression.isNotEmpty &&
        ['+', '-', '×', '÷', ','].contains(expression[expression.length - 1])) {
      expression = expression.substring(0, expression.length - 1);
    }

    if (expression.isEmpty) {
      setState(() {
        _display = "0";
        _isEquationFinished = true;
      });
      return;
    }

    // Chuẩn hóa biểu thức phù hợp với math_expressions
    String formattedExpression = expression
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');

    try {
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(formattedExpression);
      ContextModel cm = ContextModel();
      RealEvaluator evaluator = RealEvaluator(cm);
      num eval = evaluator.evaluate(exp);

      // Kiểm tra chia cho 0 hoặc giá trị vô cực / không hợp lệ
      if (eval.isNaN || eval.isInfinite) {
        setState(() {
          _display = "Lỗi";
          _isEquationFinished = true;
        });
        return;
      }

      // Xử lý làm tròn số và định dạng kết quả hiển thị
      String resultString;
      if (eval == eval.roundToDouble() &&
          !eval.toString().contains('e') &&
          !eval.toString().contains('E')) {
        resultString = eval.toInt().toString();
      } else {
        // Khử sai số dấu phẩy động (ví dụ: 0.1 + 0.2 = 0.30000000000000004 -> 0.3)
        double cleanEval = double.parse(eval.toStringAsPrecision(12));
        if (cleanEval == cleanEval.roundToDouble() &&
            !cleanEval.toString().contains('e') &&
            !cleanEval.toString().contains('E')) {
          resultString = cleanEval.toInt().toString();
        } else {
          String s = cleanEval.toString();
          if (s.endsWith('.0')) {
            s = s.substring(0, s.length - 2);
          }
          resultString = s.replaceAll('.', ',');
        }
      }

      setState(() {
        _display = resultString;
        _isEquationFinished = true;
      });
    } catch (e) {
      setState(() {
        _display = "Lỗi";
        _isEquationFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "2224801030339 - Nguyễn Thành Vũ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
      body: Column(
        children: [
          // Khu vực hiển thị kết quả
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Text(
                _display,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Bàn phím nút bấm
          _buildMinimalKeyboard(),
          const SizedBox(height: 20), // Tạo khoảng cách dưới cùng
        ],
      ),
    );
  }

  Widget _buildMinimalKeyboard() {
    return Column(
      children: [
        // Hàng 1
        _buildRow(["0", "C", ",", "⌫"]),
        // Hàng 2
        _buildRow(["7", "8", "9", "÷"]),
        // Hàng 3
        _buildRow(["4", "5", "6", "×"]),
        // Hàng 4
        _buildRow(["1", "2", "3", "-"]),
        // Hàng 5
        Row(
          children: [
            Expanded(
              flex: 3, // Nút =
              child: _buildButton("=", isSpecial: true),
            ),
            Expanded(
              flex: 1, // Nút + 
              child: _buildButton("+"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> texts) {
    return Row(
      children: texts
          .map((text) => Expanded(child: _buildButton(text)))
          .toList(),
    );
  }

  Widget _buildButton(String text, {bool isSpecial = false}) {
    // Thiết lập màu
    Color bgColor;
    Color textColor = Colors.white;

    if (text == "=") {
      bgColor = const Color(0xFF76C7FF); // set màu nền
      textColor = Colors.black;
    } else if (["0", ","].contains(text)) {
      bgColor = const Color(0xFF2D2D2D); // Màu xám
    } else if (["÷", "×", "-", "+", "C", "⌫"].contains(text)) {
      bgColor = const Color(0xFF323232); // Màu nền
    } else {
      bgColor = const Color(0xFF3B3B3B); // Màu nền
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.all(3),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: () => _onPressed(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSpecial ? 28 : 22,
            fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
