import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final double overallBand;
  final String summary;
  final bool showInfo;

  const SummaryCard({
    super.key,
    required this.overallBand,
    required this.summary,
    this.showInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      'Overall Band',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      overallBand.toString(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: _getBandColor(overallBand),
                      ),
                    ),
                  ],
                ),
              ),
              if (showInfo)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F8FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Tooltip(
                    message: 'Unofficial estimation. For practice only.',
                    child: const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assessment,
                  size: 20,
                  color: Color(0xFF1976D2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    summary,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unofficial practice band based on IELTS criteria.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBandColor(double band) {
    if (band >= 7.0) return const Color(0xFF4CAF50); // Green
    if (band >= 6.0) return const Color(0xFF2196F3); // Blue
    if (band >= 5.0) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}
