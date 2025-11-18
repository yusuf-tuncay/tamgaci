import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Hesap İstatistikleri Kartı (kompakt grid yerleşimi)
class AccountStatisticsCard extends StatefulWidget {
  final Map<String, dynamic> statistics;

  const AccountStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  State<AccountStatisticsCard> createState() => _AccountStatisticsCardState();
}

class _AccountStatisticsCardState extends State<AccountStatisticsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalBalance = (widget.statistics['totalBalance'] as double?) ?? 0;
    final totalAvailableBalance =
        (widget.statistics['totalAvailableBalance'] as double?) ?? 0;
    final totalBlockedAmount =
        (widget.statistics['totalBlockedAmount'] as double?) ?? 0;
    final activeAccountsCount =
        (widget.statistics['activeAccountsCount'] as int?) ?? 0;
    final inactiveAccountsCount =
        (widget.statistics['inactiveAccountsCount'] as int?) ?? 0;
    final totalAccountsCount =
        (widget.statistics['totalAccountsCount'] as int?) ?? 0;
    final balancesByCurrency =
        (widget.statistics['balancesByCurrency'] as Map<String, double>?) ?? {};

    final metricItems = <_MetricData>[
      _MetricData(
        label: 'Toplam Bakiye',
        value: _formatCurrency(totalBalance),
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.blue[600] ?? Colors.blue,
      ),
      _MetricData(
        label: 'Kullanılabilir',
        value: _formatCurrency(totalAvailableBalance),
        icon: Icons.check_circle_outline,
        color: Colors.green[600] ?? Colors.green,
      ),
      if (totalBlockedAmount > 0)
        _MetricData(
          label: 'Bloke',
          value: _formatCurrency(totalBlockedAmount),
          icon: Icons.lock_outline,
          color: Colors.orange[600] ?? Colors.orange,
        ),
      _MetricData(
        label: 'Toplam Hesap',
        value: totalAccountsCount.toString(),
        icon: Icons.account_balance_outlined,
        color: Colors.grey[700] ?? Colors.grey,
      ),
      _MetricData(
        label: 'Aktif Hesap',
        value: activeAccountsCount.toString(),
        icon: Icons.check_circle_outline,
        color: Colors.green[600] ?? Colors.green,
      ),
      if (inactiveAccountsCount > 0)
        _MetricData(
          label: 'Pasif Hesap',
          value: inactiveAccountsCount.toString(),
          icon: Icons.pause_circle_outline,
          color: Colors.orange[600] ?? Colors.orange,
        ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hesap Özeti',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _MetricsGrid(metrics: metricItems),
                  if (balancesByCurrency.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _CurrencyGrid(balancesByCurrency: balancesByCurrency),
                  ],
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<_MetricData> metrics;

  const _MetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        int columns = 1;
        if (maxWidth >= 720) {
          columns = 3;
        } else if (maxWidth >= 520) {
          columns = 2;
        }
        const spacing = 12.0;
        final tileWidth =
            (maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: columns == 1 ? double.infinity : tileWidth,
                  child: _MetricTile(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CurrencyGrid extends StatelessWidget {
  final Map<String, double> balancesByCurrency;

  const _CurrencyGrid({required this.balancesByCurrency});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        int columns = 1;
        if (maxWidth >= 680) {
          columns = 4;
        } else if (maxWidth >= 520) {
          columns = 3;
        } else if (maxWidth >= 360) {
          columns = 2;
        }
        const spacing = 10.0;
        final tileWidth =
            (maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: balancesByCurrency.entries
              .map(
                (entry) => SizedBox(
                  width: columns == 1 ? double.infinity : tileWidth,
                  child: _CurrencyTile(
                    currency: entry.key,
                    amountLabel: _formatCurrency(entry.value),
                    color: _getCurrencyColor(entry.key),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // helper reuse from parent
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  Color _getCurrencyColor(String currency) {
    switch (currency) {
      case 'TRY':
        return Colors.red[600] ?? Colors.red;
      case 'USD':
        return Colors.green[600] ?? Colors.green;
      case 'EUR':
        return Colors.blue[600] ?? Colors.blue;
      case 'GBP':
        return Colors.purple[600] ?? Colors.purple;
      default:
        return Colors.grey[600] ?? Colors.grey;
    }
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _MetricTile extends StatelessWidget {
  final _MetricData metric;

  const _MetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: metric.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: metric.color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(metric.icon, size: 20, color: metric.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  metric.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            metric.value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: metric.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final String currency;
  final String amountLabel;
  final Color color;

  const _CurrencyTile({
    required this.currency,
    required this.amountLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              currency,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              amountLabel,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
