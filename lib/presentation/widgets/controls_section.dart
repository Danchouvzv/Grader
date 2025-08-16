import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? Colors.red : const Color(0xFF1976D2),
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : const Color(0xFF1976D2))
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Button label
          Text(
            isRecording ? 'Tap to stop recording' : 'Tap to start recording',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
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
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.translate, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isRecording ? 'Recording...' : 'Transcribe & Grade',
                    style: const TextStyle(
                      fontSize: 16,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.audio_file,
                    size: 20,
                    color: Color(0xFF666666),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Audio saved',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          audioFileName!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (duration != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        duration!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
