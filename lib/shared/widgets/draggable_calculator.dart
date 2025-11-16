import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _preview = ''; // Anlık ön izleme
  bool _isMinimized = false;
  double _memory = 0.0;
  String _lastOperation = '';
  double _lastValue = 0.0;
  final FocusNode _focusNode = FocusNode();
  List<String> _historyList = []; // Son işlemler listesi
  static const String _historyListKey = 'calculator_history_list';
  static const int _maxHistoryItems = 10; // Maksimum 10 işlem sakla
  bool _isHistorySheetOpen = false; // History bottom sheet açık mı?

  String _formatNumber(double num) {
    // Tam sayıları ondalık olmadan göster
    if (num == num.truncateToDouble()) {
      return num.toInt().toString();
    }
    // Ondalık sayıları formatla (gereksiz sıfırları kaldır)
    String formatted = num.toString();
    if (formatted.contains('.')) {
      // Sonundaki sıfırları kaldır
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      // Eğer sadece nokta kaldıysa, onu da kaldır
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    // Çok uzun sayıları kısalt (maksimum 10 ondalık basamak)
    if (formatted.contains('.')) {
      final parts = formatted.split('.');
      if (parts[1].length > 10) {
        formatted = num.toStringAsFixed(10);
        formatted = formatted.replaceAll(RegExp(r'0+$'), '');
        formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      }
    }
    return formatted;
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _previousValue = '';
        _operation = '';
        _waitingForOperand = false;
        _history = '';
        _preview = '';
        _lastOperation = '';
        _lastValue = 0.0;
      } else if (value == 'CE') {
        _display = '0';
        _waitingForOperand = false;
        _updatePreview();
      } else if (value == '⌫') {
        if (_display.length > 1 && _display != 'Error') {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
        _updatePreview();
      } else if (value == '=') {
        if (_operation.isNotEmpty && _previousValue.isNotEmpty) {
          _history = '$_previousValue $_operation $_display =';
          final result = _calculate();
          _addToHistoryList('$_history $result');
          _preview = '';
          _lastOperation = _operation;
          _lastValue = double.parse(_display);
          _display = result;
          _previousValue = '';
          _waitingForOperand = true;
        } else if (_lastOperation.isNotEmpty && _waitingForOperand) {
          // Ardışık = tuşu: son işlemi tekrarla
          _previousValue = _display;
          _operation = _lastOperation;
          _display = _formatNumber(_lastValue);
          _history = '$_previousValue $_operation $_display =';
          final result = _calculate();
          _addToHistoryList('$_history $result');
          _preview = '';
          _display = result;
        }
      } else if (['+', '-', '×', '÷'].contains(value)) {
        // Ardışık operatör: sadece operatörü güncelle
        if (_waitingForOperand && _previousValue.isNotEmpty) {
          _operation = value;
          _preview = '$_previousValue $_operation';
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
        _lastOperation = '';
        _updatePreview();
      } else if (value == '%') {
        // Yüzde işlemi: Eğer bir işlem varsa, önceki değerin yüzdesini hesapla
        if (_operation.isNotEmpty && _previousValue.isNotEmpty) {
          final prev = double.parse(_previousValue);
          final current = double.parse(_display);
          final percent = prev * (current / 100);

          switch (_operation) {
            case '+':
              _display = _formatNumber(prev + percent);
              break;
            case '-':
              _display = _formatNumber(prev - percent);
              break;
            case '×':
              _display = _formatNumber(prev * (current / 100));
              break;
            case '÷':
              if (current == 0) {
                _display = 'Error';
              } else {
                _display = _formatNumber(prev / (current / 100));
              }
              break;
          }
          _history = '$_previousValue $_operation $current% =';
          _addToHistoryList('$_history $_display');
          _preview = '';
          _previousValue = '';
          _operation = '';
          _waitingForOperand = true;
        } else {
          // Sadece yüzde: sayıyı 100'e böl
          final num = double.parse(_display);
          _display = _formatNumber(num / 100);
          _preview = '';
        }
      } else if (value == '1/x') {
        final num = double.parse(_display);
        if (num != 0) {
          _display = _formatNumber(1 / num);
        } else {
          _display = 'Error';
        }
        _waitingForOperand = true;
        _preview = '';
      } else if (value == 'x²') {
        final num = double.parse(_display);
        _display = _formatNumber(num * num);
        _waitingForOperand = true;
        _preview = '';
      } else if (value == '²√x') {
        final num = double.parse(_display);
        if (num >= 0) {
          _display = _formatNumber(math.sqrt(num));
        } else {
          _display = 'Error';
        }
        _waitingForOperand = true;
        _preview = '';
      } else if (value == '+/-') {
        if (_display != '0' && _display != 'Error') {
          _display =
              _display.startsWith('-') ? _display.substring(1) : '-$_display';
        }
        _updatePreview();
      } else if (value == 'MC') {
        _memory = 0.0;
      } else if (value == 'MR') {
        _display = _formatNumber(_memory);
        _waitingForOperand = true;
        _updatePreview();
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
        _updatePreview();
      } else {
        // Rakam girişi
        final bool isDigit = value.length == 1 && '0123456789'.contains(value);
        if (!isDigit) return;
        if (_display == 'Error') {
          _display = value;
          _waitingForOperand = false;
        } else if (_waitingForOperand) {
          _display = value;
          _waitingForOperand = false;
        } else {
          _display = _display == '0' ? value : _display + value;
        }
        _updatePreview();
      }
    });
  }

  void _updatePreview() {
    // Anlık ön izleme oluştur
    if (_operation.isNotEmpty && _previousValue.isNotEmpty) {
      // Eğer operatör seçildiyse ama henüz ikinci sayı girilmediyse, sadece operatörü göster
      if (_waitingForOperand) {
        _preview = '$_previousValue $_operation';
      } else {
        // İkinci sayı girildiyse, tam işlemi göster
        _preview = '$_previousValue $_operation $_display';
      }
    } else {
      _preview = '';
    }
  }

  /// History listesine yeni işlem ekle
  void _addToHistoryList(String historyItem) {
    setState(() {
      _historyList.insert(0, historyItem); // En yeni en üstte
      if (_historyList.length > _maxHistoryItems) {
        _historyList = _historyList.take(_maxHistoryItems).toList();
      }
      _saveHistory();
    });
  }

  /// History listesini SharedPreferences'a kaydet
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyListKey, _historyList);
    } catch (e) {
      debugPrint('Hesap makinesi history kaydetme hatası: $e');
    }
  }

  /// History listesini SharedPreferences'tan yükle
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedHistory = prefs.getStringList(_historyListKey);
      if (savedHistory != null && mounted) {
        setState(() {
          _historyList = savedHistory;
        });
      }
    } catch (e) {
      debugPrint('Hesap makinesi history yükleme hatası: $e');
    }
  }

  /// History listesini temizle
  void _clearHistory() {
    setState(() {
      _historyList.clear();
      _saveHistory();
    });
  }

  /// History bottom sheet'i göster
  void _showHistoryBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _isHistorySheetOpen = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Son İşlemler',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kapatma butonu
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                      if (_historyList.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        // Temizleme butonu
                        GestureDetector(
                          onTap: () {
                            _clearHistory();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: isDark ? Colors.red[300] : Colors.red[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // History List
            if (_historyList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz işlem yapılmadı',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final historyItem = _historyList[index];
                    // Sonuç kısmını ayır
                    final parts = historyItem.split(' = ');
                    final expression =
                        parts.length > 1 ? parts[0] : historyItem;
                    final result = parts.length > 1 ? parts[1] : '';

                    return GestureDetector(
                      onTap: () {
                        // Sonuca tıklandığında display'e yükle ve dialog'u kapat
                        if (result.isNotEmpty) {
                          setState(() {
                            _display = result;
                            _waitingForOperand = true;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.02)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                expression,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (result.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Text(
                                '= $result',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.blue[300]
                                      : Colors.blue[700],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    ).whenComplete(() {
      // Bottom sheet kapandığında state'i güncelle
      setState(() {
        _isHistorySheetOpen = false;
      });
    });
  }

  String _calculate() {
    try {
      final double prev = double.parse(_previousValue);
      final double current = double.parse(_display);

      double result;
      switch (_operation) {
        case '+':
          result = prev + current;
          break;
        case '-':
          result = prev - current;
          break;
        case '×':
          result = prev * current;
          break;
        case '÷':
          if (current == 0) {
            return 'Error';
          }
          result = prev / current;
          break;
        default:
          return _display;
      }

      _lastValue = current;
      return _formatNumber(result);
    } catch (e) {
      return 'Error';
    }
  }

  bool _isDesktopLayout(BuildContext context) {
    if (kIsWeb) {
      // Web'de ekran genişliğine göre masaüstü layout kontrolü
      final screenWidth = MediaQuery.of(context).size.width;
      return screenWidth >= 1024; // 1024px ve üzeri masaüstü layout
    }
    // Native platformlarda platform kontrolü
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    // Kaydedilmiş işlemleri yükle
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Klavye kısayolları için focus node ekle (sadece masaüstü layoutunda)
    // didChangeDependencies'de MediaQuery'ye erişebiliriz
    if (_isDesktopLayout(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyPress(
      FocusNode node, KeyEvent event, BuildContext context) {
    // Sadece masaüstü layoutunda klavye desteği
    if (!_isDesktopLayout(context)) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // Enter veya = tuşu
      if (key.keyLabel == 'Enter' || key.keyLabel == '=') {
        _onButtonPressed('=');
        return KeyEventResult.handled;
      }
      // Escape veya Delete tuşu
      else if (key.keyLabel == 'Escape' || key.keyLabel == 'Delete') {
        _onButtonPressed('C');
        return KeyEventResult.handled;
      }
      // Backspace tuşu
      else if (key.keyLabel == 'Backspace') {
        _onButtonPressed('⌫');
        return KeyEventResult.handled;
      }
      // Rakamlar
      else if (key.keyLabel.length == 1 &&
          '0123456789'.contains(key.keyLabel)) {
        _onButtonPressed(key.keyLabel);
        return KeyEventResult.handled;
      }
      // Operatörler
      else if (key.keyLabel == '+') {
        _onButtonPressed('+');
        return KeyEventResult.handled;
      } else if (key.keyLabel == '-') {
        _onButtonPressed('-');
        return KeyEventResult.handled;
      } else if (key.keyLabel == '*') {
        _onButtonPressed('×');
        return KeyEventResult.handled;
      } else if (key.keyLabel == '/') {
        _onButtonPressed('÷');
        return KeyEventResult.handled;
      }
      // Nokta
      else if (key.keyLabel == '.' || key.keyLabel == ',') {
        _onButtonPressed('.');
        return KeyEventResult.handled;
      }
      // Yüzde
      else if (key.keyLabel == '%') {
        _onButtonPressed('%');
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sadece masaüstünde klavye desteği için Focus widget'ı kullan
    final calculatorWidget = Container(
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
        borderRadius: BorderRadius.circular(_isMinimized ? 16 : 20),
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
            padding: EdgeInsets.all(_isMinimized ? 12 : 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF4C6EF5),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_isMinimized ? 16 : 20),
                topRight: Radius.circular(_isMinimized ? 16 : 20),
                bottomLeft:
                    _isMinimized ? const Radius.circular(16) : Radius.zero,
                bottomRight:
                    _isMinimized ? const Radius.circular(16) : Radius.zero,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isMinimized
                            ? 'Hesap Makinesi'
                            : 'Tamgacı\nHesap Makinesi',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: _isMinimized ? 13 : 16,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                          height: _isMinimized ? 1.2 : 1.3,
                        ),
                        maxLines: _isMinimized ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!_isMinimized) ...[
                        const SizedBox(height: 2),
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
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // History ikonu (sadece minimize edilmemiş durumda)
                    if (!_isMinimized)
                      GestureDetector(
                        onTap: () {
                          if (_isHistorySheetOpen) {
                            // Eğer açıksa kapat
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          } else {
                            // Kapalıysa aç
                            _showHistoryBottomSheet(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _isHistorySheetOpen
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    if (!_isMinimized) const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isMinimized = !_isMinimized;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(_isMinimized ? 5 : 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isMinimized ? Icons.expand_more : Icons.expand_less,
                          color: Colors.white,
                          size: _isMinimized ? 16 : 18,
                        ),
                      ),
                    ),
                    SizedBox(width: _isMinimized ? 6 : 8),
                    GestureDetector(
                      onTap: () => CalculatorOverlay.instance.hide(),
                      child: Container(
                        padding: EdgeInsets.all(_isMinimized ? 5 : 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: _isMinimized ? 16 : 18,
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
            padding: EdgeInsets.all(_isMinimized ? 12 : 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // History Display (tamamlanmış işlemler)
                if (_history.isNotEmpty && !_isMinimized)
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
                if (_history.isNotEmpty && !_isMinimized)
                  const SizedBox(height: 8),
                // Preview Display (anlık ön izleme)
                if (_preview.isNotEmpty && !_isMinimized)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.blue.withValues(alpha: 0.15)
                          : Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.blue.withValues(alpha: 0.3)
                            : Colors.blue.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _preview,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.blue[300] : Colors.blue[700],
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if ((_history.isNotEmpty || _preview.isNotEmpty) &&
                    !_isMinimized)
                  const SizedBox(height: 12),
                // Main Display
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: _isMinimized ? 12 : 20,
                    vertical: _isMinimized ? 12 : 18,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF4C6EF5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(_isMinimized ? 12 : 16),
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
                      fontSize: _isMinimized ? 20 : 28,
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

    // Sadece masaüstü layoutunda klavye desteği için Focus widget'ı ile sarmala
    if (_isDesktopLayout(context)) {
      return Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) => _handleKeyPress(node, event, context),
        child: calculatorWidget,
      );
    } else {
      return calculatorWidget;
    }
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
