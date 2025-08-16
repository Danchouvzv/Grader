import 'package:flutter/material.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';

class SummaryCard extends StatelessWidget {
  final double overallBand;
  final String summary;
  final bool showInfo;

  const SummaryCard({
    super.key,
    required this.overallBand,
    required this.summary,
    this.showInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.elevatedShadow,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Band',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      overallBand.toString(),
                      style: AppTypography.displayLarge.copyWith(
                        color: _getBandColor(overallBand),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBandColor(overallBand).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getBandColor(overallBand).withOpacity(0.3)),
                      ),
                      child: Text(
                        _getBandDescription(overallBand),
                        style: AppTypography.labelMedium.copyWith(
                          color: _getBandColor(overallBand),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showInfo)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Tooltip(
                    message: 'AI-powered assessment based on IELTS criteria',
                    child: Icon(
                      Icons.verified_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.assessment_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    summary,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.psychology_rounded,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'AI-powered IELTS assessment',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBandColor(double band) {
    if (band >= 8.5) return AppColors.bandExcellent;
    if (band >= 7.0) return AppColors.bandGood;
    if (band >= 6.0) return AppColors.bandCompetent;
    if (band >= 5.0) return AppColors.bandLimited;
    return AppColors.bandPoor;
  }

  String _getBandDescription(double band) {
    if (band >= 8.5) return 'Expert User';
    if (band >= 7.5) return 'Very Good User';
    if (band >= 7.0) return 'Good User';
    if (band >= 6.5) return 'Competent User';
    if (band >= 6.0) return 'Modest User';
    if (band >= 5.5) return 'Limited User';
    if (band >= 5.0) return 'Modest User';
    if (band >= 4.5) return 'Limited User';
    return 'Intermittent User';
  }
}
