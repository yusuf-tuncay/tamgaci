import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../overlays/calculator_overlay.dart';

/// Sürüklenebilir hesap makinesi widget'ı
class DraggableCalculator extends StatefulWidget {
  const DraggableCalculator({super.key});

  @override
  State<DraggableCalculator> createState() => _DraggableCalculatorState();
}

class _DraggableCalculatorState extends State<DraggableCalculator> {
  String _display = '0';
  String _previousValue = '';
  String _operation = '';
  bool _waitingForOperand = false;
  String _history = '';
  bool _isMinimized = false;
  double _memory = 0.0;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _previousValue = '';
        _operation = '';
        _waitingForOperand = false;
        _history = '';
      } else if (value == 'CE') {
        _display = '0';
      } else if (value == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (value == '=') {
        if (_operation.isNotEmpty && _previousValue.isNotEmpty) {
          _history = '$_previousValue $_operation $_display =';
          _display = _calculate();
          _operation = '';
          _previousValue = '';
          _waitingForOperand = true;
        }
      } else if (['+', '-', '×', '÷'].contains(value)) {
        // Ardışık operatör: sadece operatörü güncelle
        if (_waitingForOperand && _previousValue.isNotEmpty) {
          _operation = value;
          return;
        }
        if (_operation.isNotEmpty &&
            _previousValue.isNotEmpty &&
            !_waitingForOperand) {
          _display = _calculate();
        }
        _previousValue = _display;
        _operation = value;
        _waitingForOperand = true;
      } else if (value == '%') {
        final num = double.parse(_display);
        _display = (num / 100).toString();
      } else if (value == '1/x') {
        final num = double.parse(_display);
        if (num != 0) {
          _display = (1 / num).toString();
        } else {
          _display = 'Error';
        }
      } else if (value == 'x²') {
        final num = double.parse(_display);
        _display = (num * num).toString();
      } else if (value == '²√x') {
        final num = double.parse(_display);
        if (num >= 0) {
          _display = math.sqrt(num).toString();
        } else {
          _display = 'Error';
        }
      } else if (value == '+/-') {
        if (_display != '0') {
          _display =
              _display.startsWith('-') ? _display.substring(1) : '-$_display';
        }
      } else if (value == 'MC') {
        _memory = 0.0;
      } else if (value == 'MR') {
        _display = _memory.toString();
      } else if (value == 'M+') {
        _memory += double.parse(_display);
      } else if (value == 'M-') {
        _memory -= double.parse(_display);
      } else if (value == 'MS') {
        _memory = double.parse(_display);
      } else if (value == 'M←') {
        _memory = 0.0;
      } else if (value == '.') {
        if (_waitingForOperand) {
          _display = '0.';
          _waitingForOperand = false;
        } else if (!_display.contains('.')) {
          _display = '$_display.';
        }
      } else {
        // Rakam girişi
        final bool isDigit = value.length == 1 && '0123456789'.contains(value);
        if (!isDigit) return;
        if (_waitingForOperand) {
          _display = value;
          _waitingForOperand = false;
        } else {
          _display = _display == '0' ? value : _display + value;
        }
      }
    });
  }

  String _calculate() {
    final double prev = double.parse(_previousValue);
    final double current = double.parse(_display);

    switch (_operation) {
      case '+':
        return (prev + current).toString();
      case '-':
        return (prev - current).toString();
      case '×':
        return (prev * current).toString();
      case '÷':
        return current != 0 ? (prev / current).toString() : 'Error';
      default:
        return _display;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: _isMinimized ? 240 : 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2C2C2C),
                  const Color(0xFF1A1A1A),
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFF8F9FA),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF4C6EF5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calculate_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tamgacı\nHesap Makinesi',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        'Profesyonel Hesaplamalar',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isMinimized = !_isMinimized;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isMinimized ? Icons.expand_more : Icons.expand_less,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => CalculatorOverlay.instance.hide(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Premium Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // History Display
                if (_history.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _history,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 12),
                // Main Display
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF4C6EF5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    _display,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Premium Buttons
          if (!_isMinimized)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Memory Row: MC, MR, M+, M-, MS, M←
                  _buildButtonRow(['MC', 'MR', 'M+', 'M-', 'MS', 'M←']),
                  const SizedBox(height: 6),
                  // Row 1: %, CE, C, ⌫
                  _buildButtonRow(['%', 'CE', 'C', '⌫']),
                  const SizedBox(height: 6),
                  // Row 2: 1/x, x², ²√x, ÷
                  _buildButtonRow(['1/x', 'x²', '²√x', '÷']),
                  const SizedBox(height: 6),
                  // Row 3: 7, 8, 9, ×
                  _buildButtonRow(['7', '8', '9', '×']),
                  const SizedBox(height: 6),
                  // Row 4: 4, 5, 6, -
                  _buildButtonRow(['4', '5', '6', '-']),
                  const SizedBox(height: 6),
                  // Row 5: 1, 2, 3, +
                  _buildButtonRow(['1', '2', '3', '+']),
                  const SizedBox(height: 6),
                  // Row 6: +/-, 0, ., =
                  _buildButtonRow(['+/-', '0', '.', '=']),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Row(
      children: buttons
          .map((button) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: buttons.indexOf(button) < buttons.length - 1 ? 4 : 0,
                  ),
                  child: _buildButton(button),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildButton(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOperator = ['+', '-', '×', '÷', '='].contains(text);
    final isSpecial = ['C', 'CE', '⌫'].contains(text);
    final isMemory = ['MC', 'MR', 'M+', 'M-', 'MS', 'M←'].contains(text);
    final isFunction = ['%', '1/x', 'x²', '²√x', '+/-'].contains(text);

    Color textColor;
    List<Color> gradientColors;

    if (isSpecial || isOperator || isMemory || isFunction) {
      textColor = Colors.white;
      gradientColors = const [
        Color(0xFF2563EB),
        Color(0xFF4C6EF5),
      ];
    } else {
      textColor = isDark ? Colors.white : const Color(0xFF111827);
      gradientColors = isDark
          ? const [Color(0xFF374151), Color(0xFF111827)]
          : const [Color(0xFFF3F4F6), Color(0xFFE5E7EB)];
    }

    return GestureDetector(
      onTap: () => _onButtonPressed(text),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.black.withValues(alpha: 0.08), width: 0.8),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isOperator || isFunction || isSpecial ? 18 : 15,
              fontWeight: FontWeight.w700,
              color: textColor,
              decoration: TextDecoration.none,
              letterSpacing: isOperator ? 0.2 : 0.0,
            ),
          ),
        ),
      ),
    );
  }
}
