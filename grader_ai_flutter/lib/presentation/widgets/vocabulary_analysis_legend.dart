import 'package:flutter/material.dart';
import '../../core/services/vocabulary_analysis_service.dart';

class VocabularyAnalysisLegend extends StatelessWidget {
  const VocabularyAnalysisLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Vocabulary Analysis Legend',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(
                'Basic (A1-A2)',
                Colors.red,
                'Simple words, repeated words, filler words',
              ),
              _buildLegendItem(
                'Intermediate (B1-B2)',
                Colors.orange,
                'Standard vocabulary',
              ),
              _buildLegendItem(
                'Advanced (C1-C2)',
                Colors.green,
                'Sophisticated vocabulary',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Wavy underline = repeated or filler words',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String description) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
