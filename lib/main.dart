// Flutter Calculator App
// main.dart

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;
  runApp(MyApp(isDark: isDark));
}

class MyApp extends StatefulWidget {
  final bool isDark;
  const MyApp({Key? key, required this.isDark}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  Future<void> _toggleTheme() async {
    setState(() => _isDark = !_isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[200],
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.blue),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
            .copyWith(primary: Colors.tealAccent),
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: CalculatorPage(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const CalculatorPage({Key? key, required this.onToggleTheme, required this.isDark}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '0';

  final List<String> buttons = [
    'AC', '÷', '×', '⌫',
    '7', '8', '9', '-',
    '4', '5', '6', '+',
    '1', '2', '3', '=',
    '0', '.',
  ];

  bool _isOperator(String ch) {
    return ch == '+' || ch == '-' || ch == '×' || ch == '÷';
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _expression = '';
        _result = '0';
        return;
      }

      if (buttonText == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        if (_expression.isEmpty) _result = '0';
        return;
      }

      if (buttonText == '=') {
        _evaluate();
        return;
      }

      // Prevent invalid inputs
      final last = _expression.isEmpty ? '' : _expression[_expression.length - 1];

      if (_isOperator(buttonText)) {
        // convert × and ÷ to standard tokens when evaluating
        if (_expression.isEmpty) {
          // allow leading '-' for negative numbers
          if (buttonText == '-') {
            _expression += buttonText;
          }
          // ignore other leading operators
          return;
        }
        if (_isOperator(last)) {
          // replace last operator with new one
          _expression = _expression.substring(0, _expression.length - 1) + buttonText;
          return;
        }
      }

      if (buttonText == '.') {
        // prevent multiple decimals in the same number
        // find last operator in expression
        int lastOp = -1;
        for (int i = _expression.length - 1; i >= 0; i--) {
          if (_isOperator(_expression[i])) {
            lastOp = i;
            break;
          }
        }
        final currentNumber = _expression.substring(lastOp + 1);
        if (currentNumber.contains('.')) return;
      }

      _expression += buttonText;
    });
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    String exp = _expression.replaceAll('×', '*').replaceAll('÷', '/');

    // prevent trailing operator
    if (_isOperator(exp[exp.length - 1])) {
      exp = exp.substring(0, exp.length - 1);
    }

    try {
      Parser p = Parser();
      Expression parsed = p.parse(exp);
      ContextModel cm = ContextModel();
      double eval = parsed.evaluate(EvaluationType.REAL, cm);
      // handle whole number vs decimal
      if (eval == eval.roundToDouble()) {
        _result = eval.toInt().toString();
      } else {
        _result = eval.toString();
      }
      // set expression to result for chaining
      _expression = _result;
    } catch (e) {
      _result = 'Error';
    }
  }

  Widget _buildButton(String text, {double flex = 1}) {
    final bool isOp = _isOperator(text) || text == '=' || text == 'AC' || text == '⌫';
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: isOp ? null : null,
            elevation: 3,
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _expression.isEmpty ? '0' : _expression,
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _result,
                    style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.primary),
                  )
                ],
              ),
            ),
          ),

          // Buttons area
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(children: [
                  _buildButton('AC'),
                  _buildButton('÷'),
                  _buildButton('×'),
                  _buildButton('⌫'),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('-'),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('+'),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('='),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(flex: 2, child: _buildButton('0')),
                  Expanded(child: _buildButton('.')),
                ])
              ],
            ),
          )
        ],
      ),
    );
  }
}
