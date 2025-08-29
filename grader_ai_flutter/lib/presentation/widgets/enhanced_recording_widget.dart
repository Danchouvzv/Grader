import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';

class EnhancedRecordingWidget extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final String? duration;
  final VoidCallback onRecordTap;
  final VoidCallback? onStopTap;
  final String? audioFileName;
  final double? audioLevel; // 0.0 to 1.0
  
  const EnhancedRecordingWidget({
    super.key,
    required this.isRecording,
    required this.isProcessing,
    required this.onRecordTap,
    this.onStopTap,
    this.duration,
    this.audioFileName,
    this.audioLevel,
  });

  @override
  State<EnhancedRecordingWidget> createState() => _EnhancedRecordingWidgetState();
}

class _EnhancedRecordingWidgetState extends State<EnhancedRecordingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _startRecordingAnimation();
    }
  }

  void _startRecordingAnimation() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
    _glowController.repeat(reverse: true);
  }

  void _stopRecordingAnimation() {
    _pulseController.stop();
    _waveController.stop();
    _glowController.stop();
    _pulseController.reset();
    _waveController.reset();
    _glowController.reset();
  }

  @override
  void didUpdateWidget(EnhancedRecordingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording) {
      if (widget.isRecording) {
        _startRecordingAnimation();
      } else {
        _stopRecordingAnimation();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.elevatedShadow,
        border: Border.all(
          color: widget.isRecording 
              ? AppColors.error.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Status and Duration
          if (widget.isRecording || widget.duration != null) ...[
            _buildStatusSection(),
            const SizedBox(height: 24),
          ],
          
          // Recording Button with Animations
          _buildRecordingButton(),
          
          const SizedBox(height: 24),
          
          // Action Text
          _buildActionText(),
          
          // Audio Visualizer (when recording)
          if (widget.isRecording) ...[
            const SizedBox(height: 24),
            _buildAudioVisualizer(),
          ],
          
          // File Info (when not recording but has file)
          if (!widget.isRecording && widget.audioFileName != null) ...[
            const SizedBox(height: 16),
            _buildFileInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isRecording 
            ? AppColors.error.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isRecording 
              ? AppColors.error.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.isRecording ? AppColors.error : AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.isRecording ? 'RECORDING' : 'COMPLETED',
            style: AppTypography.labelMedium.copyWith(
              color: widget.isRecording ? AppColors.error : AppColors.success,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          if (widget.duration != null) ...[
            const SizedBox(width: 12),
            Text(
              widget.duration!,
              style: AppTypography.headlineSmall.copyWith(
                color: widget.isRecording ? AppColors.error : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        if (widget.isRecording) {
          widget.onStopTap?.call();
        } else {
          widget.onRecordTap();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _glowController]),
        builder: (context, child) {
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Outer glow effect
                if (widget.isRecording)
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.4 * _glowAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                // Standard shadow
                BoxShadow(
                  color: (widget.isRecording ? AppColors.error : AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Transform.scale(
              scale: widget.isRecording ? _pulseAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: widget.isRecording
                        ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                        : [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: widget.isProcessing
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionText() {
    String text;
    if (widget.isProcessing) {
      text = 'Processing your recording...';
    } else if (widget.isRecording) {
      text = 'Recording in progress\nTap to stop';
    } else {
      text = 'Tap to start recording\nyour IELTS response';
    }

    return Text(
      text,
      style: AppTypography.titleMedium.copyWith(
        color: widget.isRecording ? AppColors.error : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAudioVisualizer() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (index) {
              final double animationValue = (_waveAnimation.value + index * 0.1) % 1.0;
              final double height = 20 + (math.sin(animationValue * 2 * math.pi) * 20).abs();
              
              return Container(
                width: 3,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.audio_file_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recording saved',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.audioFileName != null)
                  Text(
                    widget.audioFileName!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 24,
          ),
        ],
      ),
    );
  }
}

// Compact Recording Button for smaller spaces
class CompactRecordingButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  final double size;

  const CompactRecordingButton({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.size = 60,
  });

  @override
  State<CompactRecordingButton> createState() => _CompactRecordingButtonState();
}

class _CompactRecordingButtonState extends State<CompactRecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CompactRecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording) {
      if (widget.isRecording) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isRecording ? _scaleAnimation.value : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isRecording
                      ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                      : [AppColors.primary, AppColors.primaryLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording ? AppColors.error : AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: widget.size * 0.4,
              ),
            ),
          );
        },
      ),
    );
  }
}
