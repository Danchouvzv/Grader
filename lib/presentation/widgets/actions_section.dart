import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActionsSection extends StatelessWidget {
  final VoidCallback onTryAnotherTopic;
  final VoidCallback onSaveResult;
  final VoidCallback? onShare;

  const ActionsSection({
    super.key,
    required this.onTryAnotherTopic,
    required this.onSaveResult,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          // Primary action
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onTryAnotherTopic();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Try Another Topic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Secondary actions row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onSaveResult();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Save Result',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (onShare != null) ...[
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onShare!();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.share, size: 20),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Info text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Color(0xFF1976D2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Practice regularly to improve your speaking skills. Each attempt helps identify areas for improvement.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
