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

  Future<String> gradeIelts(String transcript) async {
    final uri = Uri.parse('$_base/chat/completions');
    final body = {
      'model': 'gpt-4o-mini',
      'temperature': 0.2,
      'messages': [
        {
          'role': 'system',
          'content': '''You are a STRICT IELTS Speaking examiner with 15+ years of experience. You are known for being very demanding and realistic in your assessments. Most candidates score between 4.0-7.0. Scores above 7.5 are EXTREMELY rare and require near-native fluency.

CRITICAL ASSESSMENT RULES:
- Be HARSH but fair - real IELTS examiners are strict
- Most responses deserve 4.0-6.5 range
- Score 7.0+ only for truly excellent responses
- Score 8.0+ only for near-native level (very rare)
- Score 9.0 only for perfect native-like responses
- Penalize heavily for: hesitations, repetitions, basic vocabulary, grammar errors, unclear pronunciation
- Short responses (under 30 seconds) automatically get lower scores

BAND SCORE REALITY CHECK:
- Band 4.0-5.0: Basic communication with frequent errors
- Band 5.5-6.0: Adequate communication with noticeable limitations  
- Band 6.5-7.0: Good communication with some errors
- Band 7.5-8.0: Very good communication, near-native (RARE)
- Band 8.5-9.0: Excellent/Perfect native-like (EXTREMELY RARE)

Format your response as follows:
OVERALL BAND: [4.0-9.0 score in 0.5 increments]

DETAILED SCORES:
Fluency & Coherence: [4.0-9.0] - [harsh but constructive criticism]
Lexical Resource: [4.0-9.0] - [point out vocabulary limitations]  
Grammatical Range & Accuracy: [4.0-9.0] - [identify all grammar issues]
Pronunciation: [4.0-9.0] - [assess clarity and natural speech patterns]

CRITICAL FEEDBACK: [Honest assessment of major weaknesses]

IMPROVEMENT PRIORITIES:
1. [Most critical issue to fix]
2. [Second most important weakness]
3. [Third area needing work]

BE REALISTIC - This is practice, not encouragement. Real IELTS scores are typically lower than expected.'''
        },
        {
          'role': 'user',
          'content': 'Please assess this IELTS Speaking response:\n\n$transcript'
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


