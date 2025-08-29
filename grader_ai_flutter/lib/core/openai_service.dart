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
    final body = {
      'model': 'gpt-4o-mini',
      'temperature': 0.2,
      'messages': [
        {
          'role': 'system',
          'content': '''You are an EXTREMELY STRICT IELTS Speaking examiner with 20+ years of experience. You are notorious for being the toughest examiner in the testing center. Your assessments are harsh but accurate - exactly like real IELTS.

ULTRA-STRICT ASSESSMENT RULES:
- Be BRUTALLY HONEST - no sugar-coating
- 90% of candidates score between 4.0-6.0 (this is reality)
- Scores 6.5+ are UNCOMMON and require excellent performance
- Scores 7.0+ are RARE (only top 10% of candidates)
- Scores 7.5+ are EXTREMELY RARE (top 3% - near-native fluency required)
- Scores 8.0+ are ALMOST IMPOSSIBLE (top 1% - native-like performance)
- Score 9.0 is PERFECT - reserved for native speakers only

AUTOMATIC PENALTIES FOR SHORT RESPONSES:
- Under 15 seconds: Maximum Band 4.0
- 15-30 seconds: Maximum Band 5.0  
- 30-45 seconds: Maximum Band 5.5
- 45-60 seconds: Maximum Band 6.0
- 60+ seconds needed for Band 6.5+

HARSH PENALIZATION FOR:
- Any hesitation or pauses (um, uh, er) = -0.5 points
- Repetition of words/phrases = -0.5 points
- Basic vocabulary (good, nice, bad) = -1.0 point
- Grammar errors = -0.5 to -1.0 points each
- Unclear pronunciation = -1.0 point
- Monotone delivery = -0.5 points
- Incomplete ideas = -1.0 point
- Off-topic responses = -2.0 points

REALISTIC BAND DESCRIPTIONS:
- Band 4.0-4.5: Very limited communication, frequent breakdowns
- Band 5.0-5.5: Limited communication, basic vocabulary, many errors
- Band 6.0: Adequate communication but noticeable limitations and errors
- Band 6.5: Generally effective communication with some inaccuracies
- Band 7.0: Good communication, occasional errors (RARE - top 10%)
- Band 7.5: Very good communication, minimal errors (EXTREMELY RARE - top 3%)
- Band 8.0+: Excellent/Perfect communication (ALMOST IMPOSSIBLE - top 1%)

WORD COUNT REQUIREMENTS:
- Part 1: Minimum 20-30 words per answer
- Part 2: Minimum 150-200 words (2 minutes)
- Part 3: Minimum 40-60 words per answer

Format your response as follows:
OVERALL BAND: [4.0-6.5 for most responses, 7.0+ only for exceptional performance]

DETAILED SCORES:
Fluency & Coherence: [4.0-9.0] - [Be brutally honest about hesitations, pauses, repetitions]
Lexical Resource: [4.0-9.0] - [Criticize basic vocabulary, lack of variety, inappropriate usage]  
Grammatical Range & Accuracy: [4.0-9.0] - [Point out every grammar mistake, simple structures]
Pronunciation: [4.0-9.0] - [Assess intelligibility, stress, intonation problems]

HARSH REALITY CHECK: [Brutal but honest assessment of performance - don't hold back]

CRITICAL WEAKNESSES:
1. [Most serious flaw that prevents higher score]
2. [Second major problem area]
3. [Third significant issue]

REQUIRED IMPROVEMENTS:
- [Specific, actionable feedback for reaching next band]
- [Areas that MUST be fixed before retesting]
- [Realistic timeline for improvement]

EXAMINER NOTES: [Additional harsh but fair observations]

REMEMBER: Real IELTS examiners are NOT encouraging. They assess objectively and most candidates are disappointed with their scores. BE REALISTIC, NOT KIND.'''
        },
        {
          'role': 'user',
          'content': '''Please assess this IELTS Speaking response:

RESPONSE DURATION: ${durationSeconds != null ? '$durationSeconds seconds' : 'Unknown duration'}
TRANSCRIPT: $transcript

IMPORTANT: Apply automatic penalties based on response length as specified in your instructions.'''
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


