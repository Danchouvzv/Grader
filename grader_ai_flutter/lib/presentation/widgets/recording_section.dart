import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../shared/themes/app_icons.dart';
import '../../shared/themes/app_animations.dart';

class RecordingSection extends StatefulWidget {
  final bool isRecording;
  final String? audioFileName;
  final String? duration;
  final VoidCallback onRecordTap;
  final VoidCallback onTranscribeTap;
  final bool canTranscribe;

  const RecordingSection({
    super.key,
    required this.isRecording,
    this.audioFileName,
    this.duration,
    required this.onRecordTap,
    required this.onTranscribeTap,
    required this.canTranscribe,
  });

  @override
  State<RecordingSection> createState() => _RecordingSectionState();
}

class _RecordingSectionState extends State<RecordingSection>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(RecordingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
      } else {
        _pulseController.stop();
        _waveController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
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
        children: [
          // Main recording button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onRecordTap();
            },
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isRecording ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isRecording 
                          ? LinearGradient(
                              colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isRecording ? AppColors.error : AppColors.primary)
                              .withOpacity(0.4),
                          blurRadius: 32,
                          spreadRadius: 8,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: (widget.isRecording ? AppColors.error : AppColors.primary)
                              .withOpacity(0.2),
                          blurRadius: 16,
                          spreadRadius: 4,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Icon
                        Icon(
                          widget.isRecording ? AppIcons.stop : AppIcons.record,
                          size: 64,
                          color: Colors.white,
                        ),
                        
                        // Recording indicator
                        if (widget.isRecording)
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Status text
          AnimatedSwitcher(
            duration: AppAnimations.normal,
            child: Text(
              key: ValueKey(widget.isRecording),
              widget.isRecording 
                  ? 'Recording in progress...'
                  : 'Ready to record your answer',
              style: AppTypography.headlineSmall.copyWith(
                color: widget.isRecording ? AppColors.error : AppColors.textPrimary,
                fontWeight: widget.isRecording ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Audio waveform visualization
          if (widget.isRecording)
            Container(
              height: 60,
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(20, (index) {
                      final delay = index * 0.1;
                      final waveValue = (_waveAnimation.value + delay) % 1.0;
                      final height = 20 + (waveValue * 40);
                      
                      return Container(
                        width: 3,
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          
          // Recording progress bar
          if (widget.isRecording && widget.duration != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recording time',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.duration!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: LinearProgressIndicator(
                      value: null, // Indeterminate progress
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.error,
                      ),
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
              onPressed: widget.canTranscribe ? widget.onTranscribeTap : null,
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
                    AppIcons.ai,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isRecording 
                        ? 'Recording...'
                        : 'Transcribe & Grade with AI',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Audio file info
          if (widget.audioFileName != null) ...[
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
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      AppIcons.audio,
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
                          widget.audioFileName!,
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
                  if (widget.duration != null)
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
                        widget.duration!,
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
