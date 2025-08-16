import 'package:flutter/material.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../shared/themes/app_animations.dart';
import '../widgets/ielts_types.dart';

class ProgressStepper extends StatelessWidget {
  final IeltsStatus currentStatus;
  final bool showLabels;

  const ProgressStepper({
    super.key,
    required this.currentStatus,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step(
        status: IeltsStatus.idle,
        icon: Icons.radio_button_unchecked_rounded,
        label: 'Ready',
        color: AppColors.primary,
      ),
      _Step(
        status: IeltsStatus.recording,
        icon: Icons.mic_rounded,
        label: 'Recording',
        color: AppColors.error,
      ),
      _Step(
        status: IeltsStatus.transcribing,
        icon: Icons.translate_rounded,
        label: 'Transcribing',
        color: AppColors.warning,
      ),
      _Step(
        status: IeltsStatus.grading,
        icon: Icons.psychology_rounded,
        label: 'Grading',
        color: AppColors.info,
      ),
      _Step(
        status: IeltsStatus.done,
        icon: Icons.check_circle_rounded,
        label: 'Complete',
        color: AppColors.success,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (showLabels)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Progress',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Row(
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isActive = _isStepActive(step.status);
              final isCompleted = _isStepCompleted(step.status);
              final isCurrent = currentStatus == step.status;

              return Expanded(
                child: _buildStep(
                  step: step,
                  index: index,
                  isActive: isActive,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  isLast: index == steps.length - 1,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required _Step step,
    required int index,
    required bool isActive,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              // Step icon
              AnimatedContainer(
                duration: AppAnimations.normal,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? step.color
                      : isCompleted
                          ? step.color.withOpacity(0.2)
                          : AppColors.textTertiary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent
                        ? step.color
                        : isCompleted
                            ? step.color
                            : AppColors.textTertiary.withOpacity(0.3),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : step.icon,
                  size: 16,
                  color: isCurrent
                      ? Colors.white
                      : isCompleted
                          ? step.color
                          : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 8),
              // Step label
              if (showLabels)
                Text(
                  step.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isCurrent
                        ? step.color
                        : isCompleted
                            ? step.color
                            : AppColors.textTertiary,
                    fontWeight: isCurrent || isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        // Connector line
        if (!isLast)
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? step.color.withOpacity(0.3)
                    : AppColors.textTertiary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
      ],
    );
  }

  bool _isStepActive(IeltsStatus status) {
    switch (currentStatus) {
      case IeltsStatus.idle:
        return status == IeltsStatus.idle;
      case IeltsStatus.recording:
        return status == IeltsStatus.recording;
      case IeltsStatus.transcribing:
        return status == IeltsStatus.transcribing;
      case IeltsStatus.grading:
        return status == IeltsStatus.grading;
      case IeltsStatus.done:
        return status == IeltsStatus.done;
      case IeltsStatus.error:
        return false;
      default:
        return false;
    }
  }

  bool _isStepCompleted(IeltsStatus status) {
    final statusOrder = [
      IeltsStatus.idle,
      IeltsStatus.recording,
      IeltsStatus.transcribing,
      IeltsStatus.grading,
      IeltsStatus.done,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(status);

    return stepIndex < currentIndex;
  }
}

class _Step {
  final IeltsStatus status;
  final IconData icon;
  final String label;
  final Color color;

  const _Step({
    required this.status,
    required this.icon,
    required this.label,
    required this.color,
  });
}
