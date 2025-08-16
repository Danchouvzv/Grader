import 'package:flutter/material.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../shared/themes/app_icons.dart';
import '../../shared/themes/app_animations.dart';
import '../pages/career_guidance_page.dart';
import '../../core/services/career_guidance_service.dart';

class CareerTestSection extends StatefulWidget {
  final Function(CareerTestResult) onTestCompleted;
  final Function(String) onTestError;

  const CareerTestSection({
    super.key,
    required this.onTestCompleted,
    required this.onTestError,
  });

  @override
  State<CareerTestSection> createState() => _CareerTestSectionState();
}

class _CareerTestSectionState extends State<CareerTestSection>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _questionController;
  late Animation<double> _progressAnimation;
  late Animation<double> _questionAnimation;

  int _currentQuestionIndex = 0;
  int _currentTestPhase = 0; // 0: RIASEC, 1: Big Five, 2: MBTI, 3: Klimov
  Map<String, double> _riasecScores = {};
  Map<String, double> _bigFiveScores = {};
  String _mbtiType = '';
  String _klimovType = '';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _riasecQuestions = [
    {
      'question': 'I enjoy working with tools and machines',
      'category': 'R',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I like to solve complex problems',
      'category': 'I',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I enjoy creating art or music',
      'category': 'A',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I like helping others learn',
      'category': 'S',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I enjoy leading and organizing',
      'category': 'E',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I prefer following established procedures',
      'category': 'C',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
  ];

  final List<Map<String, dynamic>> _bigFiveQuestions = [
    {
      'question': 'I am open to new experiences',
      'category': 'O',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I am organized and reliable',
      'category': 'C',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I am outgoing and social',
      'category': 'E',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I am cooperative and trusting',
      'category': 'A',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
    {
      'question': 'I am sensitive and emotional',
      'category': 'N',
      'options': ['Strongly Disagree', 'Disagree', 'Neutral', 'Agree', 'Strongly Agree']
    },
  ];

  final List<Map<String, dynamic>> _mbtiQuestions = [
    {
      'question': 'I prefer to focus on the outer world',
      'category': 'E',
      'options': ['Extrovert', 'Introvert']
    },
    {
      'question': 'I focus on facts and details',
      'category': 'S',
      'options': ['Sensing', 'Intuition']
    },
    {
      'question': 'I make decisions based on logic',
      'category': 'T',
      'options': ['Thinking', 'Feeling']
    },
    {
      'question': 'I prefer to keep options open',
      'category': 'P',
      'options': ['Perceiving', 'Judging']
    },
  ];

  final List<Map<String, dynamic>> _klimovQuestions = [
    {
      'question': 'I enjoy working with technology and machines',
      'category': 'Ч-Т',
      'options': ['Yes', 'No']
    },
    {
      'question': 'I like working with numbers and data',
      'category': 'Ч-З',
      'options': ['Yes', 'No']
    },
    {
      'question': 'I enjoy working with people',
      'category': 'Ч-Ч',
      'options': ['Yes', 'No']
    },
    {
      'question': 'I appreciate art and creativity',
      'category': 'Ч-Х',
      'options': ['Yes', 'No']
    },
    {
      'question': 'I love nature and animals',
      'category': 'Ч-П',
      'options': ['Yes', 'No']
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _questionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionController,
      curve: Curves.easeOut,
    ));

    _progressController.forward();
    _questionController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(String answer) {
    setState(() {
      _isLoading = true;
    });

    // Simulate processing time
    Future.delayed(const Duration(milliseconds: 500), () {
      _processAnswer(answer);
      
      if (_currentQuestionIndex < _getCurrentQuestions().length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isLoading = false;
        });
        _questionController.reset();
        _questionController.forward();
      } else {
        _completeCurrentPhase();
      }
    });
  }

  void _processAnswer(String answer) {
    final currentQuestion = _getCurrentQuestions()[_currentQuestionIndex];
    final category = currentQuestion['category'] as String;
    final options = currentQuestion['options'] as List<String>;
    final score = options.indexOf(answer) + 1.0;

    switch (_currentTestPhase) {
      case 0: // RIASEC
        _riasecScores[category] = (_riasecScores[category] ?? 0) + score;
        break;
      case 1: // Big Five
        _bigFiveScores[category] = (_bigFiveScores[category] ?? 0) + score;
        break;
      case 2: // MBTI
        _mbtiType += category;
        break;
      case 3: // Klimov
        _klimovType = category;
        break;
    }
  }

  void _completeCurrentPhase() {
    if (_currentTestPhase < 3) {
      setState(() {
        _currentTestPhase++;
        _currentQuestionIndex = 0;
        _isLoading = false;
      });
      _questionController.reset();
      _questionController.forward();
    } else {
      _completeTest();
    }
  }

  Future<void> _completeTest() async {
    // Normalize scores
    _normalizeScores();
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Use OpenAI API for career analysis
      final service = CareerGuidanceService();
      final apiResponse = await service.analyzeCareerProfile(
        riasecScores: _riasecScores,
        bigFiveScores: _bigFiveScores,
        mbtiType: _mbtiType,
        klimovType: _klimovType,
      );

      // Add the scores to the API response
      apiResponse['riasecScores'] = _riasecScores;
      apiResponse['bigFiveScores'] = _bigFiveScores;
      apiResponse['mbtiType'] = _mbtiType;
      apiResponse['klimovType'] = _klimovType;

      final result = CareerTestResult.fromApiResponse(apiResponse);
      widget.onTestCompleted(result);
    } catch (e) {
      print('Error completing test: $e');
      widget.onTestError('Failed to analyze career profile. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _normalizeScores() {
    // Normalize RIASEC scores (0-100 scale)
    final maxRiasecScore = _riasecQuestions.length * 5.0;
    _riasecScores.forEach((key, value) {
      _riasecScores[key] = (value / maxRiasecScore) * 100;
    });

    // Normalize Big Five scores (0-100 scale)
    final maxBigFiveScore = _bigFiveQuestions.length * 5.0;
    _bigFiveScores.forEach((key, value) {
      _bigFiveScores[key] = (value / maxBigFiveScore) * 100;
    });
  }



  List<Map<String, dynamic>> _getCurrentQuestions() {
    switch (_currentTestPhase) {
      case 0:
        return _riasecQuestions;
      case 1:
        return _bigFiveQuestions;
      case 2:
        return _mbtiQuestions;
      case 3:
        return _klimovQuestions;
      default:
        return [];
    }
  }

  String _getCurrentPhaseTitle() {
    switch (_currentTestPhase) {
      case 0:
        return 'RIASEC Assessment';
      case 1:
        return 'Big Five Personality';
      case 2:
        return 'MBTI Type Indicator';
      case 3:
        return 'Klimov Interest Test';
      default:
        return '';
    }
  }

  String _getCurrentPhaseDescription() {
    switch (_currentTestPhase) {
      case 0:
        return 'Discover your career interests with Holland\'s proven model';
      case 1:
        return 'Understand your personality traits and work preferences';
      case 2:
        return 'Identify your cognitive preferences and decision-making style';
      case 3:
        return 'Explore your interest in different work environments';
      default:
        return '';
    }
  }

  double _getProgress() {
    final totalQuestions = _riasecQuestions.length + 
                          _bigFiveQuestions.length + 
                          _mbtiQuestions.length + 
                          _klimovQuestions.length;
    final answeredQuestions = (_currentTestPhase * _getCurrentQuestions().length) + 
                             _currentQuestionIndex;
    return answeredQuestions / totalQuestions;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestions = _getCurrentQuestions();
    final currentQuestion = currentQuestions[_currentQuestionIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Progress section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getCurrentPhaseTitle(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCurrentPhaseDescription(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_currentTestPhase + 1}/4',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}/${currentQuestions.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      '${(_getProgress() * 100).toInt()}% Complete',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _getProgress(),
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Question card
          AnimatedBuilder(
            animation: _questionAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _questionAnimation.value,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion['question'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        (currentQuestion['options'] as List<String>).length,
                        (index) => _buildAnswerOption(
                          currentQuestion['options'][index],
                          index,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (_isLoading) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing your answer...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String option, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _isLoading ? null : () => _onAnswerSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFF3F4F6),
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D, E
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
