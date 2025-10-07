import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

class OpenAIService {
  OpenAIService(this.apiKey);

  final String apiKey;

  static const String _base = 'https://api.openai.com/v1';

  Future<String> transcribeAudio(String audioPath) async {
    final uri = Uri.parse('$_base/audio/transcriptions');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = 'whisper-1'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        audioPath,
        filename: audioPath.split('/').last,
        contentType: http_parser.MediaType('audio', 'mp4'),
      ));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['text'] as String).trim();
    }
    throw Exception('Transcription failed: ${res.statusCode} ${res.body}');
  }

  Future<String> gradeIelts(String transcript, {int? durationSeconds}) async {
    final uri = Uri.parse('$_base/chat/completions');
    
    // Calculate response length penalty
    final wordCount = transcript.split(' ').length;
    final responseLength = durationSeconds ?? 0;
    
    final body = {
      'model': 'gpt-4o-mini',
      'temperature': 0.8, // Higher temperature for more varied responses
      'max_tokens': 1000,
      'messages': [
        {
          'role': 'system',
          'content': '''You are a professional IELTS Speaking examiner with 15+ years of experience. You MUST provide detailed, structured assessments with specific scores for each criterion.

CRITICAL REQUIREMENTS:
- You MUST give a score for EACH of the 4 criteria (Fluency, Lexical, Grammar, Pronunciation)
- Each score must be between 4.0-9.0 with decimal points (e.g., 6.5, 7.0, 4.5)
- Every score must have a specific reason based on the actual response
- No generic feedback - everything must be personalized to the transcript
- Follow the exact format requested in the user prompt

EVALUATION CRITERIA:
1. FLUENCY & COHERENCE: Flow, logical organization, minimal hesitation, coherence
2. LEXICAL RESOURCE: Vocabulary range, accuracy, appropriateness, variety
3. GRAMMATICAL RANGE & ACCURACY: Grammar structures, error frequency, complexity
4. PRONUNCIATION: Intelligibility, stress, intonation, clarity

SCORING GUIDELINES:
- 3.0-3.5: Extremely limited, major breakdowns, very basic vocabulary
- 4.0-4.5: Very limited, frequent breakdowns, basic vocabulary
- 5.0-5.5: Limited, noticeable errors, simple structures
- 6.0-6.5: Adequate, some errors, generally effective
- 7.0-7.5: Good, occasional errors, varied language (RARE)
- 8.0-9.0: Excellent, minimal errors, near-native (VERY RARE)

RESPONSE LENGTH IMPACT:
- Under 30 seconds: Maximum 5.5 (too short for full assessment)
- 30-60 seconds: Maximum 6.0 (limited content)
- 1-2 minutes: Can reach 7.0+ (adequate length)
- 2+ minutes: Can reach 8.0+ (good length)

REMEMBER: You are assessing REAL performance. Be honest, specific, and provide actionable feedback.'''
        },
        {
          'role': 'user',
          'content': '''Please assess this IELTS Speaking response:

RESPONSE TEXT: "$transcript"
RESPONSE DURATION: ${durationSeconds != null ? '$durationSeconds seconds' : 'Unknown duration'}
WORD COUNT: $wordCount words

CRITICAL: You MUST follow this EXACT format with NO deviations:

OVERALL BAND: [X.X]

DETAILED SCORES:
Fluency & Coherence: [X.X] - [specific reason]
Lexical Resource: [X.X] - [specific reason]
Grammatical Range & Accuracy: [X.X] - [specific reason]
Pronunciation: [X.X] - [specific reason]

STRENGTHS:
- [specific strength 1]
- [specific strength 2]
- [specific strength 3]

AREAS FOR IMPROVEMENT:
- [specific improvement 1]
- [specific improvement 2]
- [specific improvement 3]

DETAILED FEEDBACK:
[2-3 sentences of specific, actionable feedback based on the actual response]

PRACTICE TIPS:
- [specific tip 1]
- [specific tip 2]
- [specific tip 3]

MANDATORY REQUIREMENTS:
- You MUST include "OVERALL BAND:" followed by a number
- You MUST include "DETAILED SCORES:" with all 4 criteria
- Each criterion MUST have format: "Name: [X.X] - [reason]"
- Scores MUST be between 3.0-9.0 with decimal points
- Do NOT add extra sections or change the format'''
        }
      ]
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = data['choices'][0]['message']['content'] as String;
      return text.trim();
    }
    throw Exception('Chat failed: ${res.statusCode} ${res.body}');
  }

  /// Generates an improved version of the user's speaking response targeting Band 8 tone.
  /// Returns a JSON string with keys:
  /// - improved: string (the improved transcript)
  /// - advanced_phrases: string[] (phrases and collocations used)
  /// - rationale: string (what was improved and why)
  Future<Map<String, dynamic>> enhanceSpeech(String transcript) async {
    final uri = Uri.parse('$_base/chat/completions');
    final body = {
      'model': 'gpt-4o-mini',
      'temperature': 0.5,
      'max_tokens': 800,
      'response_format': { 'type': 'json_object' },
      'messages': [
        {
          'role': 'system',
          'content': 'You are an IELTS Speaking coach. Rewrite learner responses to sound like Band 8 while preserving the original meaning, naturalness, and personal voice. Produce a complete answer that fits a real Part 2/3 response. Return valid JSON only.'
        },
        {
          'role': 'user',
          'content': '''Rewrite the following IELTS Speaking response to a Band 8 version while preserving meaning and personal voice. Avoid over‑polishing. Keep everyday natural vocabulary, add a few advanced but natural phrases, improve coherence, fix grammar, and vary sentence lengths.

LENGTH REQUIREMENT:
- Output MUST be a coherent, self-contained answer of 120–140 words (approx.).

Return strict JSON with this schema:
{
  "improved": string,                // the improved transcript
  "advanced_phrases": string[],      // 5-10 natural higher-level phrases you used
  "rationale": string                // what you changed and why (2-3 sentences)
}

ORIGINAL_RESPONSE: """
$transcript
"""'''
        }
      ]
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String;
      try {
        final parsed = jsonDecode(content) as Map<String, dynamic>;
        return parsed;
      } catch (_) {
        // Fallback: wrap raw text if model did not return JSON
        return {
          'improved': content.trim(),
          'advanced_phrases': <String>[],
          'rationale': 'Model returned unstructured text; showing improved version only.'
        };
      }
    }
    throw Exception('Enhance speech failed: ${res.statusCode} ${res.body}');
  }

  /// Produces transcript-specific, actionable tips: counts of repeated words,
  /// C1-level synonyms, and short example rewrites. Returns a JSON map with:
  /// {
  ///   repeated_words: [{ word: string, count: number, c1_synonyms: string[], note: string }],
  ///   simple_words: [{ word: string, count: number, c1_synonyms: string[], example: string }],
  ///   priority_tips: [string]
  /// }
  Future<Map<String, dynamic>> actionableTips(String transcript) async {
    final uri = Uri.parse('$_base/chat/completions');
    final body = {
      'model': 'gpt-4o-mini',
      'temperature': 0.4,
      'max_tokens': 900,
      'response_format': { 'type': 'json_object' },
      'messages': [
        {
          'role': 'system',
          'content': 'You are an IELTS Speaking coach. Analyze the transcript and return laser-specific, actionable feedback only. Do not be generic. Return strict JSON only.'
        },
        {
          'role': 'user',
          'content': '''Analyze this transcript and return JSON with:
{
  "repeated_words": [
    { "word": string, "count": number, "c1_synonyms": string[], "note": string }
  ],
  "simple_words": [
    { "word": string, "count": number, "c1_synonyms": string[], "example": string }
  ],
  "priority_tips": string[]
}

Rules:
- repeated_words: only include if used ≥ 3 times; focus on fillers or overused lexis.
- simple_words: pick 5–10 overly basic words used; provide precise C1-level alternatives and ONE short example rewrite from this transcript context.
- priority_tips: 3–5 short commands like "Replace 'really' with 'highly' or 'substantially' in descriptions".

TRANSCRIPT:"""
$transcript
"""'''
        }
      ]
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String;
      try {
        final parsed = jsonDecode(content) as Map<String, dynamic>;
        return parsed;
      } catch (_) {
        return {
          'repeated_words': <Map<String, dynamic>>[],
          'simple_words': <Map<String, dynamic>>[],
          'priority_tips': <String>[],
        };
      }
    }
    throw Exception('Actionable tips failed: ${res.statusCode} ${res.body}');
  }

  /// Generates a 7-day personalized Band-8 coach plan with daily micro-missions,
  /// target lexis/grammar, and measurable checkpoints, based on user's transcript
  /// and assessment bands. Returns a JSON map:
  /// {
  ///   week_goal: string,
  ///   rationale: string,
  ///   focus_bands: { fluency: string, lexical: string, grammar: string, pronunciation: string },
  ///   days: [
  ///     { day: 1, title: string, missions: [string], target_phrases: [string], checkpoint: string }
  ///   ]
  /// }
  Future<Map<String, dynamic>> generateCoachPlan({
    required String transcript,
    required Map<String, double> bands,
  }) async {
    final uri = Uri.parse('$_base/chat/completions');
    final body = {
      'model': 'gpt-4o-mini',
      'temperature': 0.4,
      'max_tokens': 1200,
      'response_format': { 'type': 'json_object' },
      'messages': [
        {
          'role': 'system',
          'content': 'You are an expert IELTS Speaking coach. Create a 7-day, Band-8 oriented micro-coaching plan with concrete daily missions, realistic time (10–15 min), and measurable checkpoints. Return strict JSON only.'
        },
        {
          'role': 'user',
          'content': '''Build a 7-day plan from this data.
TRANSCRIPT:"""
$transcript
"""
ASSESSMENT BANDS (0-9): ${bands.toString()}

JSON SHAPE:
{
  "week_goal": string,
  "rationale": string,
  "focus_bands": {"fluency": string, "lexical": string, "grammar": string, "pronunciation": string},
  "days": [
    {"day": 1, "title": string, "missions": [string], "target_phrases": [string], "checkpoint": string},
    {"day": 2, "title": string, "missions": [string], "target_phrases": [string], "checkpoint": string},
    {"day": 3, "title": string, "missions": [string], "target_phrases": [string], "checkpoint": string},
    {"day": 4, "title": string, "missions": [string], "target_phrases": [string], "checkpoint": string},
    {"day": 5, "title": string, "missions": [string], "target_phrases": [string], "checkpoint": string},
    {"day": 6, "title": string, "missions": [string], "target_phrases": [string], "checkpoint": string},
    {"day": 7, "title": string, "missions": [string], "target_phrases": [string], "checkpoint": string}
  ]
}

Rules:
- Avoid generic advice; tie missions to transcript weaknesses.
- Keep missions short and actionable; include 5–10 target phrases across the week.
- Use natural C1 lexis; avoid over-polishing.
'''
        }
      ]
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String;
      try {
        return jsonDecode(content) as Map<String, dynamic>;
      } catch (_) {
        return {
          'week_goal': 'Improve speaking performance',
          'rationale': 'Model returned non-JSON; fallback minimal plan.',
          'focus_bands': {
            'fluency': 'coherence & reduced hesitation',
            'lexical': 'C1 synonyms and collocations',
            'grammar': 'complex sentences correctness',
            'pronunciation': 'stress & intonation'
          },
          'days': <Map<String, dynamic>>[],
        };
      }
    }
    throw Exception('Coach plan failed: ${res.statusCode} ${res.body}');
  }
}


