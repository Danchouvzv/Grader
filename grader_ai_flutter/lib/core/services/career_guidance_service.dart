import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CareerGuidanceService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4';

  Future<Map<String, dynamic>> analyzeCareerProfile({
    required Map<String, double> riasecScores,
    required Map<String, double> bigFiveScores,
    required String mbtiType,
    required String klimovType,
  }) async {
    try {
      final prompt = _buildAnalysisPrompt(
        riasecScores: riasecScores,
        bigFiveScores: bigFiveScores,
        mbtiType: mbtiType,
        klimovType: klimovType,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional career counselor with expertise in RIASEC, Big Five, MBTI, and Klimov models. Provide detailed career analysis and recommendations based on assessment results.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseOpenAIResponse(content);
      } else {
        throw Exception('API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in career guidance service: $e');
      // Fallback to mock data if API fails
      return _generateMockRecommendations(
        riasecScores: riasecScores,
        bigFiveScores: bigFiveScores,
        mbtiType: mbtiType,
        klimovType: klimovType,
      );
    }
  }

  String _buildAnalysisPrompt({
    required Map<String, double> riasecScores,
    required Map<String, double> bigFiveScores,
    required String mbtiType,
    required String klimovType,
  }) {
    final topRiasec = _getTopRiasecCodes(riasecScores);
    
    return '''
Analyze this career assessment profile and provide detailed recommendations:

RIASEC Scores (0-100):
${riasecScores.entries.map((e) => '${_getRiasecLabel(e.key)}: ${e.value.toInt()}%').join('\n')}

Top RIASEC Code: $topRiasec

Big Five Personality (0-100):
${bigFiveScores.entries.map((e) => '${_getBigFiveLabel(e.key)}: ${e.value.toInt()}%').join('\n')}

MBTI Type: $mbtiType
Klimov Type: $klimovType

Please provide:
1. Top 3 career recommendations with match percentages (80-95%)
2. Required skills for each career
3. Education requirements
4. Salary ranges
5. Pros and cons
6. Career development insights
7. Next steps

Format the response as JSON with this structure:
{
  "topRiasecCode": "$topRiasec",
  "riasecInterpretation": "Brief explanation of the top RIASEC code",
  "personalityInsights": "Analysis of Big Five traits for career success",
  "recommendations": [
    {
      "profession": "Job title",
      "description": "Brief description",
      "matchScore": 85.0,
      "requiredSkills": ["skill1", "skill2"],
      "educationLevel": "Bachelor's Degree",
      "salaryRange": r"\$50,000 - \$90,000",
      "pros": ["pro1", "pro2"],
      "cons": ["con1", "con2"]
    }
  ],
  "insights": [
    {
      "title": "Insight title",
      "description": "Insight description"
    }
  ],
  "nextSteps": [
    {
      "number": "1",
      "title": "Step title",
      "description": "Step description"
    }
  ]
}
''';
  }

  String _getTopRiasecCodes(Map<String, double> scores) {
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(3).map((e) => e.key).join('');
  }

  String _getRiasecLabel(String code) {
    switch (code) {
      case 'R': return 'Realistic';
      case 'I': return 'Investigative';
      case 'A': return 'Artistic';
      case 'S': return 'Social';
      case 'E': return 'Enterprising';
      case 'C': return 'Conventional';
      default: return code;
    }
  }

  String _getBigFiveLabel(String code) {
    switch (code) {
      case 'O': return 'Openness';
      case 'C': return 'Conscientiousness';
      case 'E': return 'Extraversion';
      case 'A': return 'Agreeableness';
      case 'N': return 'Neuroticism';
      default: return code;
    }
  }

  Map<String, dynamic> _parseOpenAIResponse(String content) {
    try {
      // Try to extract JSON from the response
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonContent = content.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonContent);
      }
      
      // If no JSON found, return mock data
      throw Exception('No JSON found in response');
    } catch (e) {
      print('Failed to parse OpenAI response: $e');
      return _generateMockRecommendations(
        riasecScores: {},
        bigFiveScores: {},
        mbtiType: '',
        klimovType: '',
      );
    }
  }

  Map<String, dynamic> _generateMockRecommendations({
    required Map<String, double> riasecScores,
    required Map<String, double> bigFiveScores,
    required String mbtiType,
    required String klimovType,
  }) {
    final topRiasec = _getTopRiasecCodes(riasecScores);
    
    return {
      'topRiasecCode': topRiasec.isNotEmpty ? topRiasec : 'IRE',
      'riasecInterpretation': 'Your profile shows strong analytical and creative thinking patterns, making you well-suited for innovative and research-oriented careers.',
      'personalityInsights': 'Your balanced personality traits suggest adaptability and strong interpersonal skills, valuable in collaborative work environments.',
      'recommendations': [
        {
          'profession': 'Software Engineer',
          'description': 'Develop innovative software solutions and applications',
          'matchScore': 87.0,
          'requiredSkills': ['Programming', 'Problem Solving', 'Analytical Thinking', 'Teamwork'],
          'educationLevel': 'Bachelor\'s Degree',
          'salaryRange': r'\$60,000 - \$130,000',
          'pros': ['High demand', 'Excellent salary', 'Creative work', 'Remote opportunities'],
          'cons': ['Long hours', 'Constant learning', 'High pressure'],
        },
        {
          'profession': 'Data Scientist',
          'description': 'Analyze complex data to drive business decisions',
          'matchScore': 84.0,
          'requiredSkills': ['Statistics', 'Machine Learning', 'Python/R', 'Business Acumen'],
          'educationLevel': 'Master\'s Degree',
          'salaryRange': r'\$70,000 - \$140,000',
          'pros': ['High impact', 'Growing field', 'Intellectual challenge'],
          'cons': ['Complex work', 'High expectations', 'Rapid changes'],
        },
        {
          'profession': 'Product Manager',
          'description': 'Lead product development and strategy',
          'matchScore': 82.0,
          'requiredSkills': ['Leadership', 'Communication', 'Strategic Thinking', 'User Research'],
          'educationLevel': 'Bachelor\'s Degree',
          'salaryRange': r'\$65,000 - \$120,000',
          'pros': ['Leadership role', 'High visibility', 'Creative control'],
          'cons': ['High responsibility', 'Stressful', 'Many stakeholders'],
        },
      ],
      'insights': [
        {
          'title': 'Technical Foundation',
          'description': 'Focus on building strong technical skills in your chosen field.',
        },
        {
          'title': 'Soft Skills Development',
          'description': 'Continue developing communication and leadership abilities.',
        },
        {
          'title': 'Continuous Learning',
          'description': 'Stay updated with industry trends and new technologies.',
        },
      ],
      'nextSteps': [
        {
          'number': '1',
          'title': 'Research Careers',
          'description': 'Learn more about the recommended professions and their requirements.',
        },
        {
          'number': '2',
          'title': 'Network',
          'description': 'Connect with professionals in your target field for guidance.',
        },
        {
          'number': '3',
          'title': 'Take Action',
          'description': 'Start working towards your career goals with concrete steps.',
        },
      ],
    };
  }
}
