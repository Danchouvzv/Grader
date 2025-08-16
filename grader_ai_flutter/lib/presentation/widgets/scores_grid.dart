import 'package:flutter/material.dart';
import 'score_card.dart';

class ScoresGrid extends StatelessWidget {
  final Map<String, double> bands;
  final Map<String, String> reasons;

  const ScoresGrid({
    super.key,
    required this.bands,
    required this.reasons,
  });

  @override
  Widget build(BuildContext context) {
    final criteria = [
      {
        'key': 'fluency_coherence',
        'name': 'Fluency & Coherence',
        'icon': Icons.speaker_notes,
      },
      {
        'key': 'lexical_resource',
        'name': 'Lexical Resource',
        'icon': Icons.translate,
      },
      {
        'key': 'grammar',
        'name': 'Grammar (GRA)',
        'icon': Icons.spellcheck,
      },
      {
        'key': 'pronunciation',
        'name': 'Pronunciation',
        'icon': Icons.record_voice_over,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Scores',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: criteria.length,
            itemBuilder: (context, index) {
              final criterion = criteria[index];
              final key = criterion['key'] as String;
              final bandScore = bands[key] ?? 0.0;
              final reason = reasons[key] ?? 'No feedback available';
              
              return ScoreCard(
                criterion: criterion['name'] as String,
                bandScore: bandScore,
                reason: reason,
                icon: criterion['icon'] as IconData,
              );
            },
          ),
        ],
      ),
    );
  }
}
