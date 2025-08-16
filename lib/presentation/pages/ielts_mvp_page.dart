import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio_recorder_service.dart';
import '../../core/openai_service.dart';
import '../../features/ielts/domain/entities/ielts_result.dart';
import '../widgets/ielts_types.dart';
import '../widgets/header_section.dart';
import '../widgets/controls_section.dart';
import '../widgets/summary_card.dart';
import '../widgets/scores_grid.dart';
import '../widgets/transcript_section.dart';
import '../widgets/tips_section.dart';
import '../widgets/actions_section.dart';

class IeltsMvpPage extends StatefulWidget {
  const IeltsMvpPage({super.key});

  @override
  State<IeltsMvpPage> createState() => _IeltsMvpPageState();
}

class _IeltsMvpPageState extends State<IeltsMvpPage> {
  final _rec = AudioRecorderService();
  static const _openAiKey = String.fromEnvironment('OPENAI_KEY', defaultValue: 'sk-REPLACE_ME_FOR_MVP_ONLY');
  late final _ai = OpenAIService(_openAiKey);

  IeltsStatus _status = IeltsStatus.idle;
  String? _audioPath;
  String? _audioFileName;
  String? _duration;
  IeltsResult? _result;
  String? _error;

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
        _error = e.toString();
        _status = IeltsStatus.error;
      });
    }
  }

  bool get _isRecording => _status == IeltsStatus.recording;

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
      // Transcribe audio
      final text = await _ai.transcribeAudio(_audioPath!);
      
      setState(() {
        _status = IeltsStatus.grading;
      });

      // Grade IELTS response
      final feedback = await _ai.gradeIelts(text);
      
      // Parse the feedback (for now, use mock data)
      // TODO: Parse actual OpenAI response into structured format
      final result = IeltsResult.mock();
      
      setState(() {
        _result = result;
        _status = IeltsStatus.done;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _status = IeltsStatus.error;
      });
    }
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
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        title: const Text(
          'IELTS Speaking MVP',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: HeaderSection(
                status: _status,
                topic: 'Practice Speaking',
                onHistoryTap: () {
                  // TODO: Navigate to history
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History coming soon')),
                  );
                },
              ),
            ),

            // Controls
            SliverToBoxAdapter(
              child: ControlsSection(
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _error = null),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ),

            // Results sections (only show when done)
            if (_result != null) ...[
              // Summary card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SummaryCard(
                    overallBand: _result!.overallBand,
                    summary: _result!.summary,
                  ),
                ),
              ),

              // Scores grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ScoresGrid(
                    bands: _result!.bands,
                    reasons: _result!.reasons,
                  ),
                ),
              ),

              // Transcript section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TranscriptSection(
                    transcript: _result!.transcript,
                  ),
                ),
              ),

              // Tips section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TipsSection(
                    tips: _result!.tips,
                  ),
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
                  ),
                ),
              ),
            ],

            // Loading states
            if (_status == IeltsStatus.transcribing || _status == IeltsStatus.grading)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _status == IeltsStatus.transcribing 
                              ? Colors.orange 
                              : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _status == IeltsStatus.transcribing 
                            ? 'Transcribing audio... (~20s)'
                            : 'Grading your response...',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
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
}
