// ========== RECENT ACTIVITIES WIDGET ==========
// lib/features/dashboard/presentation/widgets/recent_activities_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';

/// Son aktiviteler widget'ı
class RecentActivitiesWidget extends StatelessWidget {
  /// Son aktiviteler listesi
  final List<ActivityItem> activities;

  const RecentActivitiesWidget({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Aktiviteler',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Tüm aktiviteleri görüntüle
                },
                child: Text(
                  'Tümünü Gör',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz aktivite bulunmuyor',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length > 5 ? 5 : activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityItem(activity, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity, bool isDark) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activity.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            activity.icon,
            color: activity.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                activity.description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (activity.amount != null)
              Text(
                CurrencyHelper.formatCurrency(
                    activity.amount!, activity.currency),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: activity.amount! >= 0 ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              DateFormat('dd.MM.yyyy HH:mm').format(activity.date),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Aktivite öğesi modeli
class ActivityItem {
  /// Aktivite başlığı
  final String title;

  /// Aktivite açıklaması
  final String description;

  /// Aktivite ikonu
  final IconData icon;

  /// Aktivite rengi
  final Color color;

  /// Aktivite tarihi
  final DateTime date;

  /// Tutar (opsiyonel)
  final double? amount;

  /// Para birimi
  final String currency;

  const ActivityItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.date,
    this.amount,
    this.currency = 'TRY',
  });
}
