import 'package:flutter/material.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../shared/themes/app_icons.dart';
import '../../shared/themes/app_animations.dart';

class ResultsSection extends StatelessWidget {
  final double overallBand;
  final Map<String, double> bands;
  final Map<String, String> reasons;
  final String summary;
  final List<String> tips;
  final String transcript;

  const ResultsSection({
    super.key,
    required this.overallBand,
    required this.bands,
    required this.reasons,
    required this.summary,
    required this.tips,
    required this.transcript,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Overall Band Card
          _buildOverallBandCard(),
          
          const SizedBox(height: 20),
          
          // Detailed Scores Grid
          _buildDetailedScoresGrid(),
          
          const SizedBox(height: 20),
          
          // Summary Card
          _buildSummaryCard(),
          
          const SizedBox(height: 20),
          
          // Transcript Section
          _buildTranscriptSection(),
          
          const SizedBox(height: 20),
          
          // Tips Section
          _buildTipsSection(),
        ],
      ),
    );
  }

  Widget _buildOverallBandCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Band',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          overallBand.toString(),
                          style: AppTypography.displayLarge.copyWith(
                            color: _getBandColor(overallBand),
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getBandColor(overallBand).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getBandColor(overallBand).withOpacity(0.3),
                              width: 1,
                            ),
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
                  ],
                ),
              ),
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
                child: Icon(
                  AppIcons.verified,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                    AppIcons.assessment,
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
          const SizedBox(height: 16),
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
                  AppIcons.ai,
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

  Widget _buildDetailedScoresGrid() {
    final criteria = [
      {'key': 'fluency_coherence', 'label': 'Fluency & Coherence', 'icon': AppIcons.speaking},
      {'key': 'lexical_resource', 'label': 'Lexical Resource', 'icon': AppIcons.tips},
      {'key': 'grammar', 'label': 'Grammar & Accuracy', 'icon': AppIcons.assessment},
      {'key': 'pronunciation', 'label': 'Pronunciation', 'icon': AppIcons.audio},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;
        final crossAxisCount = isNarrow ? 1 : 2;
        final childAspectRatio = isNarrow ? 2.0 : 1.8;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: criteria.length,
          itemBuilder: (context, index) {
            final criterion = criteria[index];
            final key = criterion['key'] as String;
            final label = criterion['label'] as String;
            final icon = criterion['icon'] as IconData;
            final score = bands[key] ?? 6.0;
            final reason = reasons[key] ?? '';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
                border: Border.all(
                  color: _getBandColor(score).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getBandColor(score).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: _getBandColor(score),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        score.toString(),
                        style: AppTypography.displaySmall.copyWith(
                          color: _getBandColor(score),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: score / 9.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getBandColor(score),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Text(
                      reason,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
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
              Icon(
                AppIcons.summary,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Summary',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
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
              Icon(
                AppIcons.transcript,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Transcript',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: Copy transcript
                },
                icon: Icon(
                  AppIcons.copy,
                  color: AppColors.primary,
                  size: 20,
                ),
                tooltip: 'Copy transcript',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              transcript,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  AppIcons.tips,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Improvement Tips',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
