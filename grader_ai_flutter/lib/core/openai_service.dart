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
          'content': '''You are an expert IELTS Speaking examiner. Analyze the candidate's response and provide a detailed assessment.

Format your response as follows:
OVERALL BAND: [0-9 score]

DETAILED SCORES:
Fluency & Coherence: [0-9 score] - [brief reason]
Lexical Resource: [0-9 score] - [brief reason]  
Grammatical Range & Accuracy: [0-9 score] - [brief reason]
Pronunciation: [0-9 score] - [brief reason]

SUMMARY: [One paragraph summary of performance]

IMPROVEMENT TIPS:
1. [Specific actionable tip]
2. [Specific actionable tip]
3. [Specific actionable tip]

Be precise, constructive, and follow IELTS band descriptors.'''
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


