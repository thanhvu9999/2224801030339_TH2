import 'dart:math' as math;
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
  String _expression = ""; // Hiển thị biểu thức vừa tính hoặc đang tính
  bool _isEquationFinished = false;
  double _memory = 0.0;
  final List<String> _history = []; // Lưu lịch sử tính toán

  // Khử sai số dấu phẩy động và làm tròn số
  String _formatResult(num eval) {
    if (eval == eval.roundToDouble() &&
        !eval.toString().contains('e') &&
        !eval.toString().contains('E')) {
      return eval.toInt().toString();
    } else {
      double clean = double.parse(eval.toStringAsPrecision(12));
      if (clean == clean.roundToDouble() &&
          !clean.toString().contains('e') &&
          !clean.toString().contains('E')) {
        return clean.toInt().toString();
      } else {
        String s = clean.toString();
        if (s.endsWith('.0')) {
          s = s.substring(0, s.length - 2);
        }
        return s.replaceAll('.', ',');
      }
    }
  }

  // Đánh giá biểu thức thành số thực
  double? _evaluateToNumber(String expr) {
    String clean = expr;
    while (clean.isNotEmpty &&
        ['+', '-', '×', '÷', ','].contains(clean[clean.length - 1])) {
      clean = clean.substring(0, clean.length - 1);
    }
    if (clean.isEmpty) return 0.0;

    String formatted = clean
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');
    try {
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(formatted);
      RealEvaluator evaluator = RealEvaluator(ContextModel());
      num res = evaluator.evaluate(exp);
      if (res.isNaN || res.isInfinite) return null;
      return res.toDouble();
    } catch (_) {
      return null;
    }
  }

  void _onPressed(String text) {
    if (text == "=") {
      _calculate();
      return;
    }

    if (text == "C") {
      _clearAll();
      return;
    }

    if (text == "CE") {
      _clearEntry();
      return;
    }

    if (text == "⌫") {
      _backspace();
      return;
    }

    if (text == "x²") {
      _calculateSquare();
      return;
    }

    if (text == "√x") {
      _calculateSquareRoot();
      return;
    }

    if (text == "¹/x") {
      _calculateReciprocal();
      return;
    }

    if (text == "%") {
      _calculatePercentage();
      return;
    }

    if (text == "+/-") {
      _toggleSign();
      return;
    }

    setState(() {
      // Nút phép tính: +, -, ×, ÷
      if (["+", "-", "×", "÷"].contains(text)) {
        if (_display == "Lỗi") return;
        _isEquationFinished = false;

        String lastChar = _display[_display.length - 1];
        if (['+', '-', '×', '÷'].contains(lastChar)) {
          _display = _display.substring(0, _display.length - 1) + text;
        } else if (lastChar == ',') {
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

        int lastOpIndex = _display.lastIndexOf(RegExp(r'[+\-×÷]'));
        String currentNum = lastOpIndex == -1
            ? _display
            : _display.substring(lastOpIndex + 1);

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

        if (currentNum == "0") {
          _display = _display.substring(0, _display.length - 1) + text;
        } else {
          _display += text;
        }
      }
    });
  }

  // Tính kết quả biểu thức (=) và lưu lịch sử
  void _calculate() {
    if (_display == "Lỗi") return;

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

      if (eval.isNaN || eval.isInfinite) {
        setState(() {
          _display = "Lỗi";
          _isEquationFinished = true;
        });
        return;
      }

      String resultString = _formatResult(eval);

      setState(() {
        _expression = "$expression =";
        _history.insert(0, "$expression = $resultString"); // Lưu lịch sử
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

  // Tính bình phương (x²)
  void _calculateSquare() {
    if (_display == "Lỗi") return;
    double? val = _evaluateToNumber(_display);
    if (val == null) {
      setState(() {
        _display = "Lỗi";
        _isEquationFinished = true;
      });
      return;
    }

    double res = val * val;
    String formattedVal = _formatResult(val);
    String resultString = _formatResult(res);

    setState(() {
      _expression = "sqr($formattedVal) =";
      _history.insert(0, "$formattedVal² = $resultString"); // Lưu lịch sử
      _display = resultString;
      _isEquationFinished = true;
    });
  }

  // Tính căn bậc 2 (√x)
  void _calculateSquareRoot() {
    if (_display == "Lỗi") return;
    double? val = _evaluateToNumber(_display);
    if (val == null || val < 0) {
      setState(() {
        _display = "Lỗi";
        _isEquationFinished = true;
      });
      return;
    }

    double res = math.sqrt(val);
    String formattedVal = _formatResult(val);
    String resultString = _formatResult(res);

    setState(() {
      _expression = "√($formattedVal) =";
      _history.insert(0, "√($formattedVal) = $resultString"); // Lưu lịch sử
      _display = resultString;
      _isEquationFinished = true;
    });
  }

  // Tính nghịch đảo (¹/x)
  void _calculateReciprocal() {
    if (_display == "Lỗi") return;
    double? val = _evaluateToNumber(_display);
    if (val == null || val == 0) {
      setState(() {
        _display = "Lỗi";
        _isEquationFinished = true;
      });
      return;
    }

    double res = 1.0 / val;
    String formattedVal = _formatResult(val);
    String resultString = _formatResult(res);

    setState(() {
      _expression = "1/($formattedVal) =";
      _history.insert(0, "1/($formattedVal) = $resultString"); // Lưu lịch sử
      _display = resultString;
      _isEquationFinished = true;
    });
  }

  // Tính phần trăm (%)
  void _calculatePercentage() {
    if (_display == "Lỗi") return;
    double? val = _evaluateToNumber(_display);
    if (val == null) {
      setState(() {
        _display = "Lỗi";
        _isEquationFinished = true;
      });
      return;
    }

    double res = val / 100.0;
    String formattedVal = _formatResult(val);
    String resultString = _formatResult(res);

    setState(() {
      _expression = "$formattedVal% =";
      _history.insert(0, "$formattedVal% = $resultString"); // Lưu lịch sử
      _display = resultString;
      _isEquationFinished = true;
    });
  }

  // Đổi dấu âm dương (+/-)
  void _toggleSign() {
    if (_display == "0" || _display == "Lỗi") return;

    setState(() {
      int lastOpIndex = _display.lastIndexOf(RegExp(r'[+×÷]'));
      int lastMinusIndex = _display.lastIndexOf('-');

      if (lastOpIndex == -1 && (lastMinusIndex == -1 || lastMinusIndex == 0)) {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
        return;
      }

      int splitIndex = math.max(lastOpIndex, lastMinusIndex);
      if (splitIndex != -1) {
        String prefix = _display.substring(0, splitIndex);
        String op = _display[splitIndex];
        String suffix = _display.substring(splitIndex + 1);

        if (op == '+') {
          _display = '$prefix-$suffix';
        } else if (op == '-') {
          if (splitIndex > 0 && ['+', '×', '÷'].contains(_display[splitIndex - 1])) {
            _display = prefix + suffix;
          } else {
            _display = '$prefix+$suffix';
          }
        } else {
          if (suffix.startsWith('-')) {
            _display = '$prefix$op${suffix.substring(1)}';
          } else {
            _display = '$prefix$op-$suffix';
          }
        }
      }
    });
  }

  // Nút CE: Xóa mục nhập hiện tại
  void _clearEntry() {
    setState(() {
      if (_display == "Lỗi" || _isEquationFinished) {
        _display = "0";
        _isEquationFinished = false;
        return;
      }
      int lastOpIndex = _display.lastIndexOf(RegExp(r'[+\-×÷]'));
      if (lastOpIndex == -1) {
        _display = "0";
      } else {
        _display = _display.substring(0, lastOpIndex + 1);
        if (_display.isEmpty) _display = "0";
      }
    });
  }

  // Nút C: Xóa toàn bộ
  void _clearAll() {
    setState(() {
      _display = "0";
      _expression = "";
      _isEquationFinished = false;
    });
  }

  // Nút ⌫: Xóa ký tự cuối
  void _backspace() {
    setState(() {
      if (_display == "Lỗi" || _isEquationFinished) {
        _display = "0";
        _isEquationFinished = false;
      } else if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = "0";
      }
    });
  }

  // Xử lý bộ nhớ (M+, M-, MS)
  void _handleMemory(String op) {
    if (_display == "Lỗi") return;
    double? val = _evaluateToNumber(_display);
    if (val == null) return;

    setState(() {
      if (op == "MS") {
        _memory = val;
      } else if (op == "M+") {
        _memory += val;
      } else if (op == "M-") {
        _memory -= val;
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Bộ nhớ: ${_formatResult(_memory)}"),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Hiển thị lịch sử tính toán
  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Lịch sử tính toán",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_history.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: "Xóa lịch sử",
                            onPressed: () {
                              setState(() {
                                _history.clear();
                              });
                              setModalState(() {});
                            },
                          ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    Expanded(
                      child: _history.isEmpty
                          ? const Center(
                              child: Text(
                                "Chưa có lịch sử tính toán",
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                String item = _history[index];
                                List<String> parts = item.split(" = ");
                                String exprPart = parts.isNotEmpty ? parts[0] : item;
                                String resPart = parts.length > 1 ? parts[1] : "";

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    exprPart,
                                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    "= $resPart",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _display = resPart;
                                      _isEquationFinished = true;
                                    });
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.grey),
            tooltip: "Lịch sử tính toán",
            onPressed: _showHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Khu vực hiển thị kết quả
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_expression.isNotEmpty)
                    Text(
                      _expression,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Hàng nút nhớ M+, M-, MS
          _buildMemoryRow(),
          const SizedBox(height: 6),
          // Bàn phím máy tính nâng cao (6 hàng)
          _buildAdvancedKeyboard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMemoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMemoryButton("M+"),
          _buildMemoryButton("M-"),
          _buildMemoryButton("MS"),
        ],
      ),
    );
  }

  Widget _buildMemoryButton(String text) {
    return InkWell(
      onTap: () => _handleMemory(text),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedKeyboard() {
    return Column(
      children: [
        // Hàng 1
        _buildRow(["%", "CE", "C", "⌫"]),
        // Hàng 2
        _buildRow(["¹/x", "x²", "√x", "÷"]),
        // Hàng 3
        _buildRow(["7", "8", "9", "×"]),
        // Hàng 4
        _buildRow(["4", "5", "6", "-"]),
        // Hàng 5
        _buildRow(["1", "2", "3", "+"]),
        // Hàng 6
        _buildRow(["+/-", "0", ",", "="]),
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

  Widget _buildButton(String text) {
    Color bgColor;
    Color textColor = Colors.white;

    if (text == "=") {
      bgColor = const Color(0xFF76C7FF);
      textColor = Colors.black;
    } else if (["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ",", "+/-"].contains(text)) {
      bgColor = const Color(0xFF3B3B3B);
    } else {
      bgColor = const Color(0xFF323232);
    }

    Widget content;
    if (text == "⌫") {
      content = Icon(Icons.backspace_outlined, color: textColor, size: 22);
    } else {
      content = Text(
        text,
        style: TextStyle(
          fontSize: text == "=" ? 26 : 20,
          fontWeight: text == "=" ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      );
    }

    return Container(
      height: 62,
      padding: const EdgeInsets.all(3),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: () => _onPressed(text),
        child: content,
      ),
    );
  }
}
