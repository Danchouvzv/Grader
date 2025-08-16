class IeltsResult {
  final double overallBand;
  final Map<String, double> bands;
  final Map<String, String> reasons;
  final String summary;
  final List<String> tips;
  final String transcript;
  final DateTime timestamp;

  const IeltsResult({
    required this.overallBand,
    required this.bands,
    required this.reasons,
    required this.summary,
    required this.tips,
    required this.transcript,
    required this.timestamp,
  });

  factory IeltsResult.fromJson(Map<String, dynamic> json) {
    return IeltsResult(
      overallBand: (json['overall_band'] as num).toDouble(),
      bands: Map<String, double>.from(json['bands'] ?? {}),
      reasons: Map<String, String>.from(json['reasons'] ?? {}),
      summary: json['summary'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
      transcript: json['transcript'] ?? '',
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_band': overallBand,
      'bands': bands,
      'reasons': reasons,
      'summary': summary,
      'tips': tips,
      'transcript': transcript,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Mock data for testing
  factory IeltsResult.mock() {
    return IeltsResult(
      overallBand: 6.5,
      bands: const {
        'fluency_coherence': 6.0,
        'lexical_resource': 6.5,
        'grammar': 6.0,
        'pronunciation': 7.0,
      },
      reasons: const {
        'fluency_coherence': 'Good flow but some hesitation and repetition',
        'lexical_resource': 'Adequate vocabulary with some good expressions',
        'grammar': 'Basic structures used correctly, some complex errors',
        'pronunciation': 'Clear pronunciation with good intonation patterns',
      },
      summary: 'You demonstrate good communication skills with clear pronunciation. Focus on reducing hesitation and expanding your vocabulary range.',
      tips: const [
        'Practice using linking words to improve fluency',
        'Learn more academic vocabulary for better lexical resource',
        'Work on complex sentence structures for grammar improvement',
      ],
      transcript: 'I think that... um... the environment is very important because... you know... we need to protect it for future generations.',
      timestamp: DateTime.now(),
    );
  }
}
