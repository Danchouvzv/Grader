import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final String criterion;
  final double bandScore;
  final String reason;
  final IconData icon;

  const ScoreCard({
    super.key,
    required this.criterion,
    required this.bandScore,
    required this.reason,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF1976D2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  criterion,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Band score
          Row(
            children: [
              Text(
                'Band ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                bandScore.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _getBandColor(bandScore),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          LinearProgressIndicator(
            value: bandScore / 9.0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getBandColor(bandScore)),
            minHeight: 6,
          ),
          
          const SizedBox(height: 12),
          
          // Reason
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getBandColor(bandScore).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              reason,
              style: TextStyle(
                fontSize: 13,
                color: _getBandColor(bandScore),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
