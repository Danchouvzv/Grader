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

IMPORTANT: You MUST provide scores in this EXACT format:

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

CRITICAL REQUIREMENTS:
- Scores must be between 4.0-9.0
- Each score must have a specific reason
- Feedback must be based on the actual transcript
- Tips must be actionable and specific
- No generic responses - everything must be personalized'''
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
}


