import 'package:flutter/material.dart';
import '../../features/ielts/models/ielts_speaking_test.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';

class IeltsSpeakingTestPage extends StatefulWidget {
  final IeltsSpeakingTest test;

  const IeltsSpeakingTestPage({
    super.key,
    required this.test,
  });

  @override
  State<IeltsSpeakingTestPage> createState() => _IeltsSpeakingTestPageState();
}

class _IeltsSpeakingTestPageState extends State<IeltsSpeakingTestPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentPartIndex = 0;
  int _currentQuestionIndex = 0;
  Map<String, String> _answers = {};
  bool _isTestCompleted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.test.parts.length,
      vsync: this,
    );
    
    // Инициализируем ответы
    for (final part in widget.test.parts) {
      for (final question in part.questions) {
        _answers[question.id] = '';
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.test.title,
          style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => _showExitConfirmation(),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _currentPartIndex = index;
              _currentQuestionIndex = 0;
            });
          },
          tabs: widget.test.parts.map((part) {
            return Tab(
              child: Column(
                children: [
                  Text(
                    'Part ${part.partNumber}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    part.title.split(' ').take(2).join(' '),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // Прогресс
          _buildProgressBar(),
          
          // Содержимое теста
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.test.parts.map((part) {
                return _buildPartContent(part);
              }).toList(),
            ),
          ),
          
          // Навигация
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final currentPart = widget.test.parts[_currentPartIndex];
    final totalQuestions = currentPart.questions.length;
    final progress = _currentQuestionIndex / (totalQuestions - 1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Прогресс по части
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Part ${currentPart.partNumber}: ${currentPart.title}',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_currentQuestionIndex + 1} / $totalQuestions',
                                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Прогресс бар
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          
          const SizedBox(height: 8),
          
          // Инструкции
          Text(
            currentPart.instructions,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPartContent(IeltsSpeakingPart part) {
    if (part.partNumber == 2) {
      // Part 2: Cue Card с подготовкой
      return _buildCueCardPart(part);
    } else {
      // Part 1 и 3: Вопросы
      return _buildQuestionsPart(part);
    }
  }

  Widget _buildQuestionsPart(IeltsSpeakingPart part) {
    final currentQuestion = part.questions[_currentQuestionIndex];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Вопрос
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  currentQuestion.question,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                if (currentQuestion.followUp != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    currentQuestion.followUp!,
                                      style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Поле для ответа
          TextField(
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              _answers[currentQuestion.id] = value;
            },
            controller: TextEditingController(
              text: _answers[currentQuestion.id] ?? '',
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Советы
          if (part.tips.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for this part:',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  ...part.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Словарь (если есть)
          if (currentQuestion.vocabulary != null &&
              currentQuestion.vocabulary!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Useful Vocabulary:',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentQuestion.vocabulary!.map((word) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          word,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 100), // Место для навигации
        ],
      ),
    );
  }

  Widget _buildCueCardPart(IeltsSpeakingPart part) {
    final currentQuestion = part.questions.first;
    final isPreparationTime = _currentQuestionIndex == 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cue Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cue Card',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  currentQuestion.question,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Точки для обсуждения
                if (currentQuestion.sampleAnswers != null) ...[
                  Text(
                    'Points to discuss:',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  ...currentQuestion.sampleAnswers!.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Таймер подготовки
          if (isPreparationTime) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.timer,
                    color: AppColors.warning,
                    size: 32,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Preparation Time',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'You have ${part.preparationTime} seconds to prepare your answer',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Start Speaking',
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Поле для ответа
            TextField(
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Speak for 1-2 minutes about the topic...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                _answers[currentQuestion.id] = value;
              },
              controller: TextEditingController(
                text: _answers[currentQuestion.id] ?? '',
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Советы
          if (part.tips.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for Part 2:',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  ...part.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: AppTypography.body.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 100), // Место для навигации
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final currentPart = widget.test.parts[_currentPartIndex];
    final totalQuestions = currentPart.questions.length;
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;
    final isLastPart = _currentPartIndex == widget.test.parts.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Кнопка "Назад"
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back),
                    const SizedBox(width: 8),
                    Text('Previous'),
                  ],
                ),
              ),
            ),
          
          if (_currentQuestionIndex > 0) const SizedBox(width: 12),
          
          // Кнопка "Далее" или "Завершить"
          Expanded(
            flex: _currentQuestionIndex > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: () {
                if (isLastQuestion) {
                  if (isLastPart) {
                    _completeTest();
                  } else {
                    _nextPart();
                  }
                } else {
                  _nextQuestion();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLastQuestion && isLastPart)
                    Icon(Icons.check)
                  else
                    Icon(Icons.arrow_forward),
                  const SizedBox(width: 8),
                  Text(
                    isLastQuestion && isLastPart
                        ? 'Complete Test'
                        : isLastQuestion
                            ? 'Next Part'
                            : 'Next Question',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
    });
  }

  void _nextPart() {
    setState(() {
      _currentPartIndex++;
      _currentQuestionIndex = 0;
    });
    _tabController.animateTo(_currentPartIndex);
  }

  void _completeTest() {
    setState(() {
      _isTestCompleted = true;
    });
    
    // Показать результаты
    _showResults();
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Test Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Congratulations! You have completed the IELTS Speaking test.'),
            SizedBox(height: 16),
            Text('Your answers have been saved.'),
            SizedBox(height: 16),
            Text('You can review your answers or start a new test.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Back to Topics'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Review Answers'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Test?'),
        content: Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }
}
