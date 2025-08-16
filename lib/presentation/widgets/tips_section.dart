import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TipsSection extends StatelessWidget {
  final List<String> tips;

  const TipsSection({
    super.key,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actionable Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _TipCard(
                tip: tips[index],
                tipNumber: index + 1,
                onPracticeTap: () => _onPracticeTap(context, index),
              );
            },
          ),
        ],
      ),
    );
  }

  void _onPracticeTap(BuildContext context, int tipIndex) {
    HapticFeedback.lightImpact();
    // TODO: Implement practice functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Practice for tip ${tipIndex + 1} coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  final int tipNumber;
  final VoidCallback onPracticeTap;

  const _TipCard({
    required this.tip,
    required this.tipNumber,
    required this.onPracticeTap,
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
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                tipNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A1A),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onPracticeTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: const Text(
              'Practice',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
