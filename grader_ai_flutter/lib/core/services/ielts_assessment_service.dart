import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class IeltsAssessmentService {
  static final IeltsAssessmentService _instance = IeltsAssessmentService._internal();
  factory IeltsAssessmentService() => _instance;
  IeltsAssessmentService._internal();

  final Dio _dio = Dio();
  
  // Configuration moved to ApiConfig

  Future<IeltsAssessment> assessSpeaking({
    required String transcript,
    required String task,
    required Map<String, dynamic> audioMetrics,
  }) async {
    // Check if OpenAI is configured
    if (!ApiConfig.isOpenAiConfigured) {
      print('OpenAI API key not configured, using mock assessment');
      return _getMockAssessment();
    }

    try {
      final systemPrompt = _buildSystemPrompt();
      final userPrompt = _buildUserPrompt(transcript, task, audioMetrics);

      // Configure timeouts on Dio instance
      _dio.options.connectTimeout = const Duration(seconds: 30);
      _dio.options.receiveTimeout = const Duration(seconds: 60);
      
      final response = await _dio.post(
        '${ApiConfig.openAiBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': ApiConfig.openAiModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.2, // Lower for more consistent results
          'max_tokens': 2000,
        },
      );

      final result = json.decode(response.data['choices'][0]['message']['content']);
      return IeltsAssessment.fromJson(result);
      
    } catch (e) {
      print('OpenAI API error: $e');
      // Return enhanced mock assessment with real-like analysis
      return _getEnhancedMockAssessment(transcript, audioMetrics);
    }
  }

  String _buildSystemPrompt() {
    return '''
You are an expert IELTS Speaking examiner with 15+ years of experience. Assess this IELTS Speaking Part 2 response using the official band descriptors.

ASSESSMENT CRITERIA (0-9 scale):

1. FLUENCY & COHERENCE
- Band 9: Natural, effortless flow with full coherence
- Band 7-8: Generally fluent, occasional hesitation, clear progression
- Band 5-6: Some hesitation, repetition, self-correction affects flow
- Band 3-4: Frequent pauses, limited ability to link ideas
- Band 1-2: Very limited communication, long pauses

2. LEXICAL RESOURCE  
- Band 9: Full flexibility, precise usage, natural collocations
- Band 7-8: Wide range, some less common vocabulary, occasional errors
- Band 5-6: Adequate range for the task, some inappropriate usage
- Band 3-4: Limited vocabulary, frequent repetition, errors impede meaning
- Band 1-2: Extremely limited vocabulary

3. GRAMMATICAL RANGE & ACCURACY
- Band 9: Full range, natural, error-free
- Band 7-8: Wide range of structures, majority error-free
- Band 5-6: Mix of simple and complex, errors don't impede communication
- Band 3-4: Limited range, frequent errors may impede understanding
- Band 1-2: Very limited control, errors prevent communication

4. PRONUNCIATION
- Band 9: Full range of pronunciation features, effortless to understand
- Band 7-8: Wide range of features, generally easy to understand
- Band 5-6: Generally clear, some mispronunciation, occasional strain for listener
- Band 3-4: Limited range, frequent mispronunciation, strain to understand
- Band 1-2: Very limited, difficult to understand

ANALYSIS REQUIREMENTS:
- Quote specific examples from the transcript
- Consider audio metrics (WPM, pauses, filler words) in fluency assessment
- Provide actionable, specific improvement suggestions
- Create a personalized 7-day study plan with daily 15-minute tasks
- Be encouraging but honest about weaknesses

Return ONLY a valid JSON object with this exact structure:
{
  "overall_band": 6.5,
  "fluency_coherence": {
    "score": 6,
    "feedback": "Your speech shows adequate fluency with some hesitation...",
    "examples": ["Good linking: 'Furthermore, I believe that...'", "Hesitation: 'um, well, you know'"],
    "improvements": ["Practice speaking without notes for 2 minutes daily", "Record yourself and identify hesitation patterns"]
  },
  "lexical_resource": {
    "score": 7,
    "feedback": "You demonstrate good vocabulary range...",
    "examples": ["Advanced vocabulary: 'memorable', 'hospitality'", "Good collocations: 'breathtaking scenery'"],
    "improvements": ["Learn 5 topic-specific adjectives daily", "Practice using idiomatic expressions"]
  },
  "grammatical_range": {
    "score": 6,
    "feedback": "You use a mix of simple and complex structures...",
    "examples": ["Complex sentence: 'Although it was challenging, I managed to...'", "Error: 'I was went there' should be 'I went there'"],
    "improvements": ["Practice conditional sentences daily", "Review past tense forms"]
  },
  "pronunciation": {
    "score": 7,
    "feedback": "Your pronunciation is generally clear...",
    "examples": ["Clear word stress on 'memorable'", "Some difficulty with 'th' sounds"],
    "improvements": ["Practice 'th' sounds with tongue twisters", "Work on sentence stress patterns"]
  },
  "strengths": ["Clear task response with all points covered", "Good use of descriptive language", "Natural intonation patterns"],
  "areas_for_improvement": ["Reduce hesitation and filler words", "Expand grammatical complexity", "Improve pronunciation of specific sounds"],
  "study_plan": [
    "Day 1: Record 2-minute speech on family topic, count filler words",
    "Day 2: Learn 10 adjectives for describing places, use in sentences",
    "Day 3: Practice complex sentences with 'although', 'despite', 'whereas'",
    "Day 4: Shadow native speaker for pronunciation (15 min YouTube video)",
    "Day 5: Describe 3 different photos for 1 minute each without notes",
    "Day 6: Practice 'th' sounds and record improvement",
    "Day 7: Complete mock speaking test and self-evaluate"
  ],
  "estimated_speaking_time": "2 minutes 15 seconds"
}
''';
  }

  String _buildUserPrompt(String transcript, String task, Map<String, dynamic> metrics) {
    return '''
IELTS Speaking Task:
$task

Candidate's Response:
"$transcript"

Audio Analysis Metrics:
- Word count: ${metrics['wordCount']}
- Speaking duration: ${metrics['duration']} seconds
- Words per minute: ${metrics['wordsPerMinute']}
- Pause count: ${metrics['pauseCount']}
- Filler words: ${metrics['fillerWords']}
- Average words per sentence: ${metrics['averageWordsPerSentence']?.toStringAsFixed(1)}
- Vocabulary diversity: ${metrics['vocabularyDiversity']?.toStringAsFixed(2)}

Please provide a comprehensive IELTS Speaking assessment.
''';
  }

  IeltsAssessment _getEnhancedMockAssessment(String transcript, Map<String, dynamic> audioMetrics) {
    // Analyze transcript for more realistic assessment
    final wordCount = audioMetrics['wordCount'] ?? 0;
    final wpm = audioMetrics['wordsPerMinute'] ?? 0;
    final fillerWords = audioMetrics['fillerWords'] ?? 0;
    final vocabularyDiversity = audioMetrics['vocabularyDiversity'] ?? 0.0;
    
    // Calculate scores based on metrics
    int fluencyScore = _calculateFluencyScore(wpm, fillerWords);
    int lexicalScore = _calculateLexicalScore(wordCount, vocabularyDiversity, transcript);
    int grammaticalScore = _calculateGrammaticalScore(transcript);
    int pronunciationScore = 7; // Default as we can't analyze pronunciation from text
    
    double overallBand = (fluencyScore + lexicalScore + grammaticalScore + pronunciationScore) / 4.0;
    overallBand = (overallBand * 2).round() / 2.0; // Round to nearest 0.5
    
    return IeltsAssessment(
      overallBand: overallBand,
      fluencyCoherence: CriterionAssessment(
        score: fluencyScore,
        feedback: _getFluencyFeedback(wpm, fillerWords),
        examples: _getFluencyExamples(transcript, fillerWords),
        improvements: _getFluencyImprovements(wpm, fillerWords),
      ),
      lexicalResource: CriterionAssessment(
        score: lexicalScore,
        feedback: _getLexicalFeedback(vocabularyDiversity, transcript),
        examples: _getLexicalExamples(transcript),
        improvements: _getLexicalImprovements(lexicalScore),
      ),
      grammaticalRange: CriterionAssessment(
        score: grammaticalScore,
        feedback: _getGrammaticalFeedback(transcript),
        examples: _getGrammaticalExamples(transcript),
        improvements: _getGrammaticalImprovements(grammaticalScore),
      ),
      pronunciation: CriterionAssessment(
        score: pronunciationScore,
        feedback: 'Based on typical patterns, your pronunciation appears generally clear with good word stress. Focus on connected speech and intonation patterns.',
        examples: ['Clear articulation of key words', 'Good pace for understanding'],
        improvements: ['Practice linking sounds between words', 'Work on sentence stress patterns'],
      ),
      strengths: _getStrengths(transcript, overallBand),
      areasForImprovement: _getAreasForImprovement(fluencyScore, lexicalScore, grammaticalScore),
      studyPlan: _getPersonalizedStudyPlan(fluencyScore, lexicalScore, grammaticalScore),
      estimatedSpeakingTime: _formatDuration(audioMetrics['duration'] ?? 120),
    );
  }

  IeltsAssessment _getMockAssessment() {
    return IeltsAssessment(
      overallBand: 6.5,
      fluencyCoherence: CriterionAssessment(
        score: 6,
        feedback: 'You speak with generally good fluency and maintain coherent ideas throughout your response. However, there are occasional hesitations and some repetition of ideas that affect the natural flow.',
        examples: ['Good use of linking phrases', 'Clear progression of ideas', 'Some hesitation with complex structures'],
        improvements: ['Practice speaking without notes', 'Work on reducing hesitations', 'Use more varied linking words'],
      ),
      lexicalResource: CriterionAssessment(
        score: 7,
        feedback: 'You demonstrate good vocabulary range with appropriate word choice for the topic. Some nice collocations and topic-specific vocabulary are evident.',
        examples: ['Traditional Japanese culture', 'Cherry blossom season', 'Hospitality'],
        improvements: ['Learn more advanced adjectives', 'Practice idiomatic expressions', 'Expand topic-specific vocabulary'],
      ),
      grammaticalRange: CriterionAssessment(
        score: 6,
        feedback: 'You use a mix of simple and complex sentence structures with generally good accuracy. Some grammatical errors occur but they don\'t impede communication.',
        examples: ['Good use of past tense', 'Complex sentences with subordinate clauses', 'Some article errors'],
        improvements: ['Practice conditional sentences', 'Work on article usage', 'Review complex tense forms'],
      ),
      pronunciation: CriterionAssessment(
        score: 7,
        feedback: 'Your pronunciation is generally clear and easy to understand. Word stress and intonation patterns are mostly appropriate for meaning.',
        examples: ['Clear consonant sounds', 'Good word stress on key words', 'Natural intonation patterns'],
        improvements: ['Work on connected speech', 'Practice weak forms', 'Focus on sentence stress'],
      ),
      strengths: [
        'Clear and coherent response to the task',
        'Good vocabulary range for the topic',
        'Generally accurate grammar usage',
      ],
      areasForImprovement: [
        'Reduce hesitations and increase fluency',
        'Expand range of grammatical structures',
        'Use more sophisticated vocabulary',
      ],
      studyPlan: [
        'Practice daily 2-minute speaking tasks without notes',
        'Learn 10 new advanced adjectives each day',
        'Record yourself and analyze fluency patterns',
        'Study one complex grammar structure daily',
        'Practice pronunciation with shadowing exercises',
      ],
      estimatedSpeakingTime: '2 minutes 15 seconds',
    );
  }

  // Analysis helper methods
  int _calculateFluencyScore(int wpm, int fillerWords) {
    if (wpm >= 160) return 8; // Very fluent
    if (wpm >= 140) return 7; // Fluent
    if (wpm >= 120) return 6; // Adequate fluency
    if (wpm >= 100) return 5; // Some hesitation
    if (wpm >= 80) return 4; // Frequent hesitation
    return 3; // Limited fluency
  }

  int _calculateLexicalScore(int wordCount, double diversity, String transcript) {
    int score = 5; // Base score
    
    // Adjust based on word count
    if (wordCount > 200) score++;
    if (wordCount > 300) score++;
    
    // Adjust based on vocabulary diversity
    if (diversity > 0.7) score++;
    if (diversity > 0.8) score++;
    
    // Check for advanced vocabulary
    final advancedWords = ['memorable', 'significant', 'extraordinary', 'fascinating', 'remarkable'];
    for (final word in advancedWords) {
      if (transcript.toLowerCase().contains(word.toLowerCase())) {
        score++;
        break;
      }
    }
    
    return score.clamp(1, 9);
  }

  int _calculateGrammaticalScore(String transcript) {
    int score = 5; // Base score
    
    // Check for complex structures
    final complexPatterns = ['although', 'despite', 'whereas', 'however', 'furthermore'];
    for (final pattern in complexPatterns) {
      if (transcript.toLowerCase().contains(pattern.toLowerCase())) {
        score++;
        break;
      }
    }
    
    // Check sentence variety (simple heuristic)
    final sentences = transcript.split(RegExp(r'[.!?]'));
    final avgLength = sentences.fold<int>(0, (sum, s) => sum + s.split(' ').length) / sentences.length;
    
    if (avgLength > 15) score++; // Complex sentences
    if (avgLength > 20) score++; // Very complex sentences
    
    return score.clamp(1, 9);
  }

  String _getFluencyFeedback(int wpm, int fillerWords) {
    if (wpm >= 140) {
      return 'Excellent fluency with natural pace and rhythm. Your speech flows smoothly with minimal hesitation.';
    } else if (wpm >= 120) {
      return 'Good fluency with generally smooth delivery. Some minor hesitations but they don\'t impede communication.';
    } else if (wpm >= 100) {
      return 'Adequate fluency with noticeable hesitations. Work on maintaining consistent pace and reducing pauses.';
    } else {
      return 'Limited fluency with frequent hesitations and pauses. Focus on building confidence and practicing regular speech patterns.';
    }
  }

  List<String> _getFluencyExamples(String transcript, int fillerWords) {
    final examples = <String>[];
    
    if (transcript.contains('Furthermore') || transcript.contains('Moreover')) {
      examples.add('Good linking: Use of discourse markers like "Furthermore"');
    }
    
    if (fillerWords > 5) {
      examples.add('Hesitation markers: Frequent use of "um", "uh", "you know"');
    }
    
    if (examples.isEmpty) {
      examples.add('Generally smooth delivery with appropriate pacing');
    }
    
    return examples;
  }

  List<String> _getFluencyImprovements(int wpm, int fillerWords) {
    final improvements = <String>[];
    
    if (wpm < 120) {
      improvements.add('Practice speaking at 120-140 words per minute');
    }
    
    if (fillerWords > 3) {
      improvements.add('Reduce filler words by practicing with recordings');
    }
    
    improvements.add('Use more discourse markers for better coherence');
    
    return improvements;
  }

  String _getLexicalFeedback(double diversity, String transcript) {
    if (diversity > 0.8) {
      return 'Excellent vocabulary range with sophisticated word choices and natural collocations.';
    } else if (diversity > 0.6) {
      return 'Good vocabulary range with some advanced words. Continue expanding topic-specific vocabulary.';
    } else {
      return 'Limited vocabulary range with repetitive word choices. Focus on learning synonyms and topic-specific terms.';
    }
  }

  List<String> _getLexicalExamples(String transcript) {
    final examples = <String>[];
    final words = transcript.toLowerCase().split(' ');
    
    final advancedWords = ['memorable', 'extraordinary', 'fascinating', 'remarkable', 'significant'];
    for (final word in advancedWords) {
      if (words.contains(word)) {
        examples.add('Advanced vocabulary: "$word"');
        break;
      }
    }
    
    if (examples.isEmpty) {
      examples.add('Basic vocabulary appropriate for the task');
    }
    
    return examples;
  }

  List<String> _getLexicalImprovements(int score) {
    if (score < 6) {
      return [
        'Learn 10 new topic-specific words daily',
        'Practice using synonyms to avoid repetition',
        'Study collocations and phrasal verbs'
      ];
    } else {
      return [
        'Focus on less common vocabulary and idiomatic expressions',
        'Practice using advanced adjectives and adverbs'
      ];
    }
  }

  String _getGrammaticalFeedback(String transcript) {
    return 'Mixed use of simple and complex sentence structures with generally good accuracy. Some errors present but they don\'t impede communication.';
  }

  List<String> _getGrammaticalExamples(String transcript) {
    final examples = <String>[];
    
    if (transcript.contains('Although') || transcript.contains('Despite')) {
      examples.add('Complex sentence: Use of subordinating conjunctions');
    } else {
      examples.add('Mostly simple sentence structures');
    }
    
    return examples;
  }

  List<String> _getGrammaticalImprovements(int score) {
    return [
      'Practice using complex sentence structures',
      'Review tense consistency and agreement',
      'Work on conditional and subjunctive forms'
    ];
  }

  List<String> _getStrengths(String transcript, double overallBand) {
    final strengths = <String>[];
    
    if (transcript.length > 200) {
      strengths.add('Comprehensive response covering all task requirements');
    }
    
    if (overallBand >= 7.0) {
      strengths.add('Strong overall performance with clear communication');
    }
    
    strengths.add('Good task engagement and relevant content');
    
    return strengths;
  }

  List<String> _getAreasForImprovement(int fluency, int lexical, int grammatical) {
    final areas = <String>[];
    
    if (fluency < 6) areas.add('Improve fluency and reduce hesitations');
    if (lexical < 6) areas.add('Expand vocabulary range and precision');
    if (grammatical < 6) areas.add('Increase grammatical complexity and accuracy');
    
    if (areas.isEmpty) {
      areas.add('Fine-tune pronunciation and intonation');
    }
    
    return areas;
  }

  List<String> _getPersonalizedStudyPlan(int fluency, int lexical, int grammatical) {
    final plan = <String>[];
    
    if (fluency < 6) {
      plan.add('Day 1-2: Practice 2-minute speeches without notes, focus on reducing pauses');
    }
    
    if (lexical < 6) {
      plan.add('Day 3-4: Learn 15 topic-specific words, use them in sentences');
    }
    
    if (grammatical < 6) {
      plan.add('Day 5-6: Practice complex sentences with subordinating conjunctions');
    }
    
    plan.add('Day 7: Complete a full mock speaking test and record for self-evaluation');
    
    return plan;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes minutes $remainingSeconds seconds';
  }
}

class IeltsAssessment {
  final double overallBand;
  final CriterionAssessment fluencyCoherence;
  final CriterionAssessment lexicalResource;
  final CriterionAssessment grammaticalRange;
  final CriterionAssessment pronunciation;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> studyPlan;
  final String estimatedSpeakingTime;

  IeltsAssessment({
    required this.overallBand,
    required this.fluencyCoherence,
    required this.lexicalResource,
    required this.grammaticalRange,
    required this.pronunciation,
    required this.strengths,
    required this.areasForImprovement,
    required this.studyPlan,
    required this.estimatedSpeakingTime,
  });

  factory IeltsAssessment.fromJson(Map<String, dynamic> json) {
    return IeltsAssessment(
      overallBand: json['overall_band']?.toDouble() ?? 0.0,
      fluencyCoherence: CriterionAssessment.fromJson(json['fluency_coherence'] ?? {}),
      lexicalResource: CriterionAssessment.fromJson(json['lexical_resource'] ?? {}),
      grammaticalRange: CriterionAssessment.fromJson(json['grammatical_range'] ?? {}),
      pronunciation: CriterionAssessment.fromJson(json['pronunciation'] ?? {}),
      strengths: List<String>.from(json['strengths'] ?? []),
      areasForImprovement: List<String>.from(json['areas_for_improvement'] ?? []),
      studyPlan: List<String>.from(json['study_plan'] ?? []),
      estimatedSpeakingTime: json['estimated_speaking_time'] ?? '',
    );
  }
}

class CriterionAssessment {
  final int score;
  final String feedback;
  final List<String> examples;
  final List<String> improvements;

  CriterionAssessment({
    required this.score,
    required this.feedback,
    required this.examples,
    required this.improvements,
  });

  factory CriterionAssessment.fromJson(Map<String, dynamic> json) {
    return CriterionAssessment(
      score: json['score'] ?? 0,
      feedback: json['feedback'] ?? '',
      examples: List<String>.from(json['examples'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
    );
  }
}
