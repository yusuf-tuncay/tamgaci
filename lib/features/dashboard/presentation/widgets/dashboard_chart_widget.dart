// ========== DASHBOARD CHART WIDGET ==========
// lib/features/dashboard/presentation/widgets/dashboard_chart_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';

/// Dashboard grafik widget'ı
class DashboardChartWidget extends StatelessWidget {
  /// Grafik başlığı
  final String title;

  /// Grafik verileri (aylık satış verileri)
  final List<ChartData> data;

  /// Grafik türü
  final ChartType type;

  const DashboardChartWidget({
    super.key,
    required this.title,
    required this.data,
    this.type = ChartType.bar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildChart(data, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<ChartData> data, bool isDark) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Veri bulunamadı',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    switch (type) {
      case ChartType.bar:
        return _buildBarChart(data, isDark);
      case ChartType.line:
        return _buildLineChart(data, isDark);
      case ChartType.pie:
        return _buildPieChart(data, isDark);
    }
  }

  Widget _buildBarChart(List<ChartData> data, bool isDark) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((item) {
        final height = (item.value / maxValue) * 150;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              item.value.toStringAsFixed(0),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLineChart(List<ChartData> data, bool isDark) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: LineChartPainter(data, isDark),
    );
  }

  Widget _buildPieChart(List<ChartData> data, bool isDark) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: CustomPaint(
          painter: PieChartPainter(data, isDark),
        ),
      ),
    );
  }
}

/// Grafik veri modeli
class ChartData {
  final String label;
  final double value;
  final Color? color;

  const ChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

/// Grafik türü enum'u
enum ChartType {
  bar,
  line,
  pie,
}

/// Çizgi grafik painter'ı
class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final bool isDark;

  LineChartPainter(this.data, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y =
          size.height - ((data[i].value - minValue) / range) * size.height;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Noktaları çiz
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Pasta grafik painter'ı
class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final bool isDark;

  PieChartPainter(this.data, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.map((e) => e.value).reduce((a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double startAngle = -90 * (3.14159 / 180); // -90 derece

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = data[i].color ?? _getColorForIndex(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
