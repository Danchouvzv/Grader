import 'package:flutter/material.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../shared/themes/app_animations.dart';
import '../../features/ielts/domain/entities/ielts_speaking_part.dart';

class SpeakingPartsProgress extends StatelessWidget {
  final IeltsSpeakingSession session;
  final VoidCallback? onPartTap;

  const SpeakingPartsProgress({
    super.key,
    required this.session,
    this.onPartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Speaking Parts Progress',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...session.parts.asMap().entries.map((entry) {
            final index = entry.key;
            final part = entry.value;
            final isCurrent = index == session.currentPartIndex;
            final isCompleted = part.isCompleted;
            final isAccessible = index <= session.currentPartIndex || 
                               (index > 0 && session.parts[index - 1].isCompleted);

            // Debug info
            print('Part $index: ${part.type.title}, isCurrent: $isCurrent, isCompleted: $isCompleted, isAccessible: $isAccessible');
            print('  Session currentPartIndex: ${session.currentPartIndex}');
            print('  Part index: $index');
            print('  isCurrent calculation: ${index == session.currentPartIndex}');

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPartCard(
                part: part,
                index: index,
                isCurrent: isCurrent,
                isCompleted: isCompleted,
                isAccessible: isAccessible,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPartCard({
    required IeltsSpeakingPart part,
    required int index,
    required bool isCurrent,
    required bool isCompleted,
    required bool isAccessible,
  }) {
    final isActive = isCurrent && !isCompleted;
    final canTap = isAccessible && onPartTap != null;

    return GestureDetector(
      onTap: canTap ? onPartTap : null,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : isCompleted
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : isCompleted
                    ? AppColors.success
                    : AppColors.textTertiary.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Part number and status
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : isCompleted
                        ? AppColors.success
                        : AppColors.textTertiary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : isCompleted
                          ? AppColors.success
                          : AppColors.textTertiary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        '${index + 1}',
                        style: AppTypography.titleMedium.copyWith(
                          color: isActive || isCompleted
                              ? Colors.white
                              : AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Part details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        part.type.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : isCompleted
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withOpacity(0.2)
                              : isCompleted
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.textTertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          part.type.subtitle,
                          style: AppTypography.labelSmall.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : isCompleted
                                    ? AppColors.success
                                    : AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    part.type.duration,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isCompleted && part.result != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Band ${part.result!.overallBand.toStringAsFixed(1)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Action indicator
            if (isAccessible)
              Icon(
                isCurrent
                    ? Icons.play_circle_filled_rounded
                    : isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                color: isCurrent
                    ? AppColors.primary
                    : isCompleted
                        ? AppColors.success
                        : AppColors.textTertiary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
