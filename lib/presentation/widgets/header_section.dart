import 'package:flutter/material.dart';
import 'ielts_types.dart';

class HeaderSection extends StatelessWidget {
  final IeltsStatus status;
  final String? topic;
  final VoidCallback? onHistoryTap;

  const HeaderSection({
    super.key,
    required this.status,
    this.topic,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IELTS Speaking',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (topic != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        topic!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onHistoryTap != null)
                IconButton(
                  onPressed: onHistoryTap,
                  icon: const Icon(Icons.history, size: 24),
                  tooltip: 'History',
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusChips(),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      children: IeltsStatus.values.map((statusType) {
        final isActive = statusType == status;
        return _StatusChip(
          label: _getStatusLabel(statusType),
          isActive: isActive,
          icon: _getStatusIcon(statusType),
        );
      }).toList(),
    );
  }

  String _getStatusLabel(IeltsStatus status) {
    switch (status) {
      case IeltsStatus.idle:
        return 'Ready';
      case IeltsStatus.recording:
        return 'Recording';
      case IeltsStatus.transcribing:
        return 'Transcribing';
      case IeltsStatus.grading:
        return 'Grading';
      case IeltsStatus.done:
        return 'Complete';
      case IeltsStatus.error:
        return 'Error';
    }
  }

  IconData _getStatusIcon(IeltsStatus status) {
    switch (status) {
      case IeltsStatus.idle:
        return Icons.mic;
      case IeltsStatus.recording:
        return Icons.fiber_manual_record;
      case IeltsStatus.transcribing:
        return Icons.translate;
      case IeltsStatus.grading:
        return Icons.assessment;
      case IeltsStatus.done:
        return Icons.check_circle;
      case IeltsStatus.error:
        return Icons.error;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1976D2) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? Colors.white : const Color(0xFF666666),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
