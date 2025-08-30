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
          'content': '''You are a professional IELTS Speaking examiner with 15+ years of experience. You provide fair, accurate, and personalized assessments based on the actual performance of each candidate.

ASSESSMENT APPROACH:
- Evaluate based on REAL performance, not predetermined scores
- Consider response length, content quality, and language skills
- Be honest but constructive - identify both strengths and areas for improvement
- Scores should reflect actual performance: 4.0-9.0 range
- Consider response duration: shorter responses typically score lower
- Provide unique, personalized feedback for each response

EVALUATION CRITERIA:
1. FLUENCY & COHERENCE: Flow, logical organization, minimal hesitation
2. LEXICAL RESOURCE: Vocabulary range, accuracy, appropriateness
3. GRAMMATICAL RANGE & ACCURACY: Grammar structures, error frequency
4. PRONUNCIATION: Intelligibility, stress, intonation

RESPONSE LENGTH CONSIDERATIONS:
- Very short responses (under 30 seconds): Usually 4.0-5.5
- Short responses (30-60 seconds): Usually 5.0-6.0
- Adequate responses (1-2 minutes): Usually 5.5-7.0
- Good responses (2+ minutes): Can reach 6.5-8.0

IMPORTANT: Provide a detailed, personalized assessment that reflects the actual quality of this specific response. Each assessment should be unique and tailored to the candidate's performance.'''
        },
        {
          'role': 'user',
          'content': '''Please assess this IELTS Speaking response:

RESPONSE TEXT: "$transcript"
RESPONSE DURATION: ${durationSeconds != null ? '$durationSeconds seconds' : 'Unknown duration'}
WORD COUNT: $wordCount words

Please provide a detailed, personalized assessment with:
1. OVERALL BAND SCORE (4.0-9.0) - based on actual performance
2. Individual scores for each criterion with specific reasoning
3. Unique strengths and weaknesses for this particular response
4. Constructive, personalized feedback for improvement

Base your assessment on the actual quality of this response. Be honest but fair. Each assessment should be unique and reflect the specific performance of this candidate.'''
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


