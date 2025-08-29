import 'package:flutter/material.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../shared/themes/app_icons.dart';
import '../../features/ielts/domain/entities/ielts_speaking_part.dart';

class SessionResultsSummary extends StatelessWidget {
  final IeltsSpeakingSession session;
  final VoidCallback onStartNewSession;
  final VoidCallback onViewDetailedResults;

  const SessionResultsSummary({
    super.key,
    required this.session,
    required this.onStartNewSession,
    required this.onViewDetailedResults,
  });

  @override
  Widget build(BuildContext context) {
    final overallBand = session.overallBand ?? 0.0;
    final completedParts = session.parts.where((part) => part.isCompleted).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.05),
            AppColors.success.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  AppIcons.verified,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Complete!',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'All ${completedParts.length} parts finished',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Overall Band Score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Overall Band Score',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      overallBand.toStringAsFixed(1),
                      style: AppTypography.displayLarge.copyWith(
                        color: _getBandColor(overallBand),
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getBandColor(overallBand).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getBandColor(overallBand).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getBandDescription(overallBand),
                        style: AppTypography.labelLarge.copyWith(
                          color: _getBandColor(overallBand),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Parts Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parts Summary',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...completedParts.map((part) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${session.parts.indexOf(part) + 1}',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                part.type.title,
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                part.type.subtitle,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getBandColor(part.result!.overallBand).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getBandColor(part.result!.overallBand).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Band ${part.result!.overallBand.toStringAsFixed(1)}',
                            style: AppTypography.labelMedium.copyWith(
                              color: _getBandColor(part.result!.overallBand),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: onViewDetailedResults,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(color: AppColors.success),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onStartNewSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'New Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
