import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';

class ControlsSection extends StatelessWidget {
  final bool isRecording;
  final String? audioFileName;
  final String? duration;
  final VoidCallback onRecordTap;
  final VoidCallback onTranscribeTap;
  final bool canTranscribe;

  const ControlsSection({
    super.key,
    required this.isRecording,
    this.audioFileName,
    this.duration,
    required this.onRecordTap,
    required this.onTranscribeTap,
    required this.canTranscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Main recording button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onRecordTap();
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isRecording 
                    ? LinearGradient(
                        colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? AppColors.error : AppColors.primary)
                        .withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 8,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: (isRecording ? AppColors.error : AppColors.primary)
                        .withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Button label with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(isRecording),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isRecording ? 'Recording in progress...' : 'Ready to record your answer',
                style: AppTypography.bodyLarge.copyWith(
                  color: isRecording ? AppColors.error : AppColors.textSecondary,
                  fontWeight: isRecording ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Recording tips
          if (!isRecording)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                          Icons.lightbulb_rounded,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recording Tips',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Speak clearly and at a natural pace\n• Use the topic points as a guide\n• Aim for 1-2 minutes of speech\n• Don\'t worry about perfect grammar',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Transcribe button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: canTranscribe ? onTranscribeTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRecording ? 'Recording...' : 'Transcribe & Grade with AI',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (audioFileName != null) ...[
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
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.audio_file_rounded,
                      size: 20,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio saved',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          audioFileName!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (duration != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        duration!,
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
