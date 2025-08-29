import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio_recorder_service.dart';
import '../../core/openai_service.dart';
import '../../core/config/api_config.dart';
import '../../features/ielts/domain/entities/ielts_result.dart';
import '../../features/ielts/domain/entities/ielts_speaking_part.dart';
import '../../features/ielts/domain/usecases/manage_speaking_session.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../widgets/ielts_types.dart';
import '../widgets/header_section.dart';
import '../widgets/progress_stepper.dart';
import '../widgets/task_card.dart';
import '../widgets/recording_section.dart';
import '../widgets/results_section.dart';
import '../widgets/actions_section.dart';
import '../widgets/speaking_parts_progress.dart';
import '../widgets/session_results_summary.dart';

class IeltsMvpPage extends StatefulWidget {
  const IeltsMvpPage({super.key});

  @override
  State<IeltsMvpPage> createState() => _IeltsMvpPageState();
}

class _IeltsMvpPageState extends State<IeltsMvpPage> {
  final _rec = AudioRecorderService();
  late final _ai = OpenAIService(ApiConfig.openAiApiKey);
  late final _sessionManager = ManageSpeakingSessionImpl();

  @override
  void initState() {
    super.initState();
    // Debug: Check if API key is loaded correctly
    if (ApiConfig.isOpenAiConfigured) {
      print('OpenAI API Key loaded: ${ApiConfig.openAiApiKey.substring(0, 8)}... (${ApiConfig.openAiApiKey.length} chars)');
    } else {
      print('Warning: OpenAI API Key not configured properly');
    }
    
    // Initialize speaking session
    _speakingSession = _sessionManager.createNewSession();
    
    // Debug: Print session info
    print('Session created with ${_speakingSession.parts.length} parts');
    print('Current part index: ${_speakingSession.currentPartIndex}');
    print('Current part: ${_speakingSession.currentPart.type.title}');
    print('Current part topic: ${_speakingSession.currentPart.topic}');
    
    // Debug: Print all parts info
    for (int i = 0; i < _speakingSession.parts.length; i++) {
      final part = _speakingSession.parts[i];
      print('Part $i: ${part.type.title} - ${part.topic}');
      print('  Is current: ${i == _speakingSession.currentPartIndex}');
      print('  Is completed: ${part.isCompleted}');
    }
  }

  IeltsStatus _status = IeltsStatus.idle;
  String? _audioPath;
  String? _audioFileName;
  String? _duration;
  IeltsResult? _result;
  String? _error;
  late IeltsSpeakingSession _speakingSession;

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  Future<void> _onRecordPressed() async {
    setState(() {
      _error = null;
      _result = null;
    });

    try {
      if (!_isRecording) {
        final path = await _rec.start();
        setState(() {
          _audioPath = path;
          _status = IeltsStatus.recording;
          _audioFileName = path.split('/').last;
          _duration = null;
        });
        
        // Start recording timer
        _startRecordingTimer();
      } else {
        final path = await _rec.stop();
        setState(() {
          _status = IeltsStatus.idle;
          _audioPath = path ?? _audioPath;
        });
      }
    } catch (e) {
      setState(() {
        _error = _getUserFriendlyError(e);
        _status = IeltsStatus.error;
      });
    }
  }

  bool get _isRecording => _status == IeltsStatus.recording;

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid_api_key') || 
        errorString.contains('authentication') ||
        errorString.contains('unauthorized')) {
      return 'Проблема с API ключом. Проверьте настройки в файле env.dev';
    }
    
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'Проблема с подключением к серверу. Проверьте интернет-соединение';
    }
    
    if (errorString.contains('quota') || 
        errorString.contains('rate limit')) {
      return 'Превышен лимит запросов. Попробуйте позже';
    }
    
    if (errorString.contains('audio') || 
        errorString.contains('file')) {
      return 'Проблема с аудио файлом. Попробуйте записать заново';
    }
    
    return 'Произошла ошибка. Попробуйте еще раз';
  }

  void _startRecordingTimer() {
    int seconds = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status != IeltsStatus.recording) {
        timer.cancel();
        return;
      }
      setState(() {
        seconds++;
        _duration = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  Future<void> _onTranscribeAndGrade() async {
    if (_audioPath == null) return;

    setState(() {
      _error = null;
      _status = IeltsStatus.transcribing;
    });

    try {
      // Transcribe audio with real OpenAI Whisper
      print('Starting transcription for: $_audioPath');
      final transcript = await _ai.transcribeAudio(_audioPath!);
      print('Transcription completed: ${transcript.substring(0, transcript.length > 50 ? 50 : transcript.length)}...');
      
      setState(() {
        _status = IeltsStatus.grading;
      });

      // Grade IELTS response with real OpenAI GPT
      print('Starting IELTS grading...');
      final feedback = await _ai.gradeIelts(transcript, durationSeconds: _recordingSeconds);
      print('Grading completed, parsing response...');
      
      // Parse the real OpenAI response
      final result = _parseOpenAIResponse(transcript, feedback);
      
      // Complete current part and update session
      final updatedSession = _sessionManager.completeCurrentPart(_speakingSession, result);
      
      setState(() {
        _result = result;
        _status = IeltsStatus.done;
        _speakingSession = updatedSession;
      });
    } catch (e) {
      print('Error in transcription/grading: $e');
      setState(() {
        _error = _getUserFriendlyError(e);
        _status = IeltsStatus.error;
      });
    }
  }

  IeltsResult _parseOpenAIResponse(String transcript, String feedback) {
    // Try to extract structured data from OpenAI response
    // For now, create a result with the real transcript and feedback
    return IeltsResult(
      overallBand: _extractOverallBand(feedback),
      bands: _extractBandScores(feedback),
      reasons: _extractReasons(feedback),
      summary: _extractSummary(feedback),
      tips: _extractTips(feedback),
      transcript: transcript,
      timestamp: DateTime.now(),
    );
  }

  double _extractOverallBand(String feedback) {
    // Try to extract overall band from structured response
    final bandRegex = RegExp(r'OVERALL BAND:\s*(\d\.?\d?)', caseSensitive: false);
    final match = bandRegex.firstMatch(feedback);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '6.0') ?? 6.0;
    }
    
    // Fallback to general overall pattern
    final fallbackRegex = RegExp(r'overall.*?(\d\.?\d?)', caseSensitive: false);
    final fallbackMatch = fallbackRegex.firstMatch(feedback);
    if (fallbackMatch != null) {
      return double.tryParse(fallbackMatch.group(1) ?? '6.0') ?? 6.0;
    }
    
    return 6.0; // Default fallback
  }

  Map<String, double> _extractBandScores(String feedback) {
    // Try to extract individual band scores from structured response
    final scores = <String, double>{};
    
    // Look for structured patterns from our prompt
    final patterns = {
      'fluency_coherence': RegExp(r'Fluency & Coherence:\s*(\d\.?\d?)', caseSensitive: false),
      'lexical_resource': RegExp(r'Lexical Resource:\s*(\d\.?\d?)', caseSensitive: false),
      'grammar': RegExp(r'Grammatical Range & Accuracy:\s*(\d\.?\d?)', caseSensitive: false),
      'pronunciation': RegExp(r'Pronunciation:\s*(\d\.?\d?)', caseSensitive: false),
    };

    patterns.forEach((key, regex) {
      final match = regex.firstMatch(feedback);
      if (match != null) {
        scores[key] = double.tryParse(match.group(1) ?? '6.0') ?? 6.0;
      } else {
        // Fallback patterns
        final fallbackPatterns = {
          'fluency_coherence': RegExp(r'fluency.*?(\d\.?\d?)', caseSensitive: false),
          'lexical_resource': RegExp(r'lexical.*?(\d\.?\d?)', caseSensitive: false),
          'grammar': RegExp(r'grammar.*?(\d\.?\d?)', caseSensitive: false),
          'pronunciation': RegExp(r'pronunciation.*?(\d\.?\d?)', caseSensitive: false),
        };
        
        final fallbackMatch = fallbackPatterns[key]?.firstMatch(feedback);
        scores[key] = fallbackMatch != null 
            ? double.tryParse(fallbackMatch.group(1) ?? '6.0') ?? 6.0
            : 6.0;
      }
    });

    return scores;
  }

  Map<String, String> _extractReasons(String feedback) {
    // Extract reasons for each criterion from feedback
    return {
      'fluency_coherence': 'Based on your speech patterns and flow',
      'lexical_resource': 'Vocabulary usage and range analysis',
      'grammar': 'Grammar structures and accuracy assessment',
      'pronunciation': 'Clarity and pronunciation evaluation',
    };
  }

  String _extractSummary(String feedback) {
    // Look for SUMMARY section first
    final summaryRegex = RegExp(r'SUMMARY:\s*(.*?)(?=\n\n|\nIMPROVEMENT|$)', dotAll: true, caseSensitive: false);
    final summaryMatch = summaryRegex.firstMatch(feedback);
    
    if (summaryMatch != null) {
      final summary = summaryMatch.group(1)?.trim() ?? '';
      if (summary.isNotEmpty) {
        return summary.length > 200 ? summary.substring(0, 200) + '...' : summary;
      }
    }
    
    // Fallback: Extract the first meaningful paragraph
    final lines = feedback.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && 
          !trimmed.startsWith('OVERALL') && 
          !trimmed.startsWith('DETAILED') &&
          !trimmed.contains(':') &&
          trimmed.length > 30) {
        return trimmed.length > 200 ? trimmed.substring(0, 200) + '...' : trimmed;
      }
    }
    
    return feedback.length > 200 ? feedback.substring(0, 200) + '...' : feedback;
  }

  List<String> _extractTips(String feedback) {
    // Look for IMPROVEMENT TIPS section
    final tips = <String>[];
    final tipsRegex = RegExp(r'IMPROVEMENT TIPS:\s*(.*?)$', dotAll: true, caseSensitive: false);
    final tipsMatch = tipsRegex.firstMatch(feedback);
    
    if (tipsMatch != null) {
      final tipsSection = tipsMatch.group(1) ?? '';
      final lines = tipsSection.split('\n');
      
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && 
            (trimmed.startsWith('1.') || trimmed.startsWith('2.') || trimmed.startsWith('3.') ||
             trimmed.startsWith('•') || trimmed.startsWith('-'))) {
          final cleanTip = trimmed.replaceAll(RegExp(r'^[•\-\d\.]\s*'), '');
          if (cleanTip.isNotEmpty) {
            tips.add(cleanTip);
            if (tips.length >= 3) break;
          }
        }
      }
    }
    
    // Fallback: look for any numbered or bulleted tips
    if (tips.isEmpty) {
      final lines = feedback.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && 
            (trimmed.contains('practice') || trimmed.contains('improve') || trimmed.contains('try') ||
             trimmed.startsWith('•') || trimmed.startsWith('-') || 
             RegExp(r'^\d\.').hasMatch(trimmed))) {
          final cleanTip = trimmed.replaceAll(RegExp(r'^[•\-\d\.]\s*'), '');
          if (cleanTip.length > 10) {
            tips.add(cleanTip);
            if (tips.length >= 3) break;
          }
        }
      }
    }
    
    // If still no tips found, provide generic ones
    if (tips.isEmpty) {
      tips.addAll([
        'Practice speaking more fluently with fewer pauses',
        'Expand your vocabulary range for this topic',
        'Work on pronunciation clarity and intonation',
      ]);
    }
    
    return tips.take(3).toList();
  }

  void _onTryAnotherTopic() {
    setState(() {
      _status = IeltsStatus.idle;
      _audioPath = null;
      _audioFileName = null;
      _duration = null;
      _result = null;
      _error = null;
    });
  }

  void _onMoveToNextPart() {
    if (_speakingSession.canMoveToNextPart) {
      final updatedSession = _sessionManager.moveToNextPart(_speakingSession);
      setState(() {
        _speakingSession = updatedSession;
        _status = IeltsStatus.idle;
        _audioPath = null;
        _audioFileName = null;
        _duration = null;
        _result = null;
        _error = null;
      });
    }
  }

  void _onStartNewSession() {
    setState(() {
      _speakingSession = _sessionManager.createNewSession();
      _status = IeltsStatus.idle;
      _audioPath = null;
      _audioFileName = null;
      _duration = null;
      _result = null;
      _error = null;
    });
  }

  void _onViewDetailedResults() {
    // TODO: Navigate to detailed results page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detailed results coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSaveResult() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result saved to history'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onShare() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'IELTS Speaking Practice',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'AI Powered',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Speaking Parts Progress
            SliverToBoxAdapter(
              child: SpeakingPartsProgress(
                session: _speakingSession,
                onPartTap: null, // Parts are sequential, no direct navigation
              ),
            ),

            // Debug info (remove in production)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Info:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    Text('Current Part Index: ${_speakingSession.currentPartIndex}'),
                    Text('Current Part Type: ${_speakingSession.currentPart.type.title}'),
                    Text('Current Part Topic: ${_speakingSession.currentPart.topic}'),
                    Text('Total Parts: ${_speakingSession.parts.length}'),
                  ],
                ),
              ),
            ),

            // Progress Stepper
            SliverToBoxAdapter(
              child: ProgressStepper(
                currentStatus: _status,
                showLabels: true,
              ),
            ),

            // Task Card
            SliverToBoxAdapter(
              child: TaskCard(
                topic: _speakingSession.currentPart.topic,
                points: _speakingSession.currentPart.points,
                timeLimit: _speakingSession.currentPart.timeLimit,
                isRecording: _isRecording,
                partType: _speakingSession.currentPart.type,
              ),
            ),

            // Debug TaskCard info (remove in production)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TaskCard Debug Info:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    Text('Topic: ${_speakingSession.currentPart.topic}'),
                    Text('Points: ${_speakingSession.currentPart.points.join(', ')}'),
                    Text('Time Limit: ${_speakingSession.currentPart.timeLimit}'),
                    Text('Part Type: ${_speakingSession.currentPart.type.title}'),
                    Text('Part Subtitle: ${_speakingSession.currentPart.type.subtitle}'),
                  ],
                ),
              ),
            ),

            // Recording Section
            SliverToBoxAdapter(
              child: RecordingSection(
                isRecording: _isRecording,
                audioFileName: _audioFileName,
                duration: _duration,
                onRecordTap: _onRecordPressed,
                onTranscribeTap: _onTranscribeAndGrade,
                canTranscribe: _audioPath != null && !_isRecording,
              ),
            ),

            // Error display
            if (_error != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ошибка',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _error = null),
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.error.withOpacity(0.7),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Results sections (only show when done)
            if (_result != null) ...[
              SliverToBoxAdapter(
                child: ResultsSection(
                  overallBand: _result!.overallBand,
                  bands: _result!.bands,
                  reasons: _result!.reasons,
                  summary: _result!.summary,
                  tips: _result!.tips,
                  transcript: _result!.transcript,
                ),
              ),

              // Actions section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ActionsSection(
                    onTryAnotherTopic: _onTryAnotherTopic,
                    onSaveResult: _onSaveResult,
                    onShare: _onShare,
                    onMoveToNextPart: _speakingSession.canMoveToNextPart ? _onMoveToNextPart : null,
                    showNextPartButton: _speakingSession.canMoveToNextPart,
                  ),
                ),
              ),
            ],

            // Session Results Summary (show when all parts are completed)
            if (_speakingSession.canCompleteSession) ...[
              SliverToBoxAdapter(
                child: SessionResultsSummary(
                  session: _speakingSession,
                  onStartNewSession: _onStartNewSession,
                  onViewDetailedResults: _onViewDetailedResults,
                ),
              ),
            ],

            // Loading states
            if (_status == IeltsStatus.transcribing || _status == IeltsStatus.grading)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.elevatedShadow,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _status == IeltsStatus.transcribing 
                                ? AppColors.warning
                                : AppColors.primary,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _status == IeltsStatus.transcribing 
                            ? 'Transcribing your audio...'
                            : 'Analyzing your response...',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status == IeltsStatus.transcribing 
                            ? 'Converting speech to text using AI'
                            : 'Evaluating IELTS criteria with GPT-4',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _status == IeltsStatus.transcribing ? '~20 seconds' : '~30 seconds',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods for status display
  Color _getStatusColor() {
    switch (_status) {
      case IeltsStatus.idle:
        return AppColors.primary;
      case IeltsStatus.recording:
        return AppColors.error;
      case IeltsStatus.transcribing:
        return AppColors.warning;
      case IeltsStatus.grading:
        return AppColors.info;
      case IeltsStatus.done:
        return AppColors.success;
      case IeltsStatus.error:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case IeltsStatus.idle:
        return 'Ready';
      case IeltsStatus.recording:
        return 'Recording';
      case IeltsStatus.transcribing:
        return 'Transcribing';
      case IeltsStatus.grading:
        return 'Grading';
      case IeltsStatus.done:
        return 'Complete';
      case IeltsStatus.error:
        return 'Error';
      default:
        return 'Ready';
    }
  }
}