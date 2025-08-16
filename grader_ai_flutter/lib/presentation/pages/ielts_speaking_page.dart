import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/animated_background.dart';
import '../widgets/gradient_button.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/ielts_assessment_service.dart';
import 'ielts_results_page.dart';

class IeltsSpeakingPage extends StatefulWidget {
  const IeltsSpeakingPage({super.key});

  @override
  State<IeltsSpeakingPage> createState() => _IeltsSpeakingPageState();
}

class _IeltsSpeakingPageState extends State<IeltsSpeakingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  final Record _audioRecorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SpeechService _speechService = SpeechService();
  final IeltsAssessmentService _assessmentService = IeltsAssessmentService();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  bool _isProcessing = false;
  
  String? _recordingPath;
  String _transcript = '';
  String _partialTranscript = '';
  
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  
  // IELTS Speaking Task
  final String _currentTask = "Describe a memorable journey you have taken. You should say:\n"
      "• Where you went\n"
      "• Who you went with\n"
      "• What you did there\n"
      "• And explain why this journey was memorable for you\n\n"
      "You have 1-2 minutes to speak.";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // _requestPermissions(); // Временно отключено для тестирования UI
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  Future<void> _requestPermissions() async {
    final microphoneStatus = await Permission.microphone.status;
    
    if (microphoneStatus.isDenied) {
      final result = await Permission.microphone.request();
      if (result != PermissionStatus.granted) {
        _showPermissionDialog();
      }
    } else if (microphoneStatus.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.mic,
              color: const Color(0xFF1976D2),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Microphone Access',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To provide accurate IELTS Speaking assessment, we need access to your microphone to:',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            _buildPermissionReason('Record your speaking response'),
            _buildPermissionReason('Analyze pronunciation and fluency'),
            _buildPermissionReason('Provide detailed feedback'),
            SizedBox(height: 12.h),
            Text(
              'Please enable microphone access in Settings.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Open Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionReason(String reason) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 4.h,
            margin: EdgeInsets.only(right: 8.w, top: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Expanded(
            child: Text(
              reason,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(),
                  SizedBox(height: 30.h),
                  _buildTaskCard(),
                  SizedBox(height: 30.h),
                  _buildRecordingSection(),
                  if (_transcript.isNotEmpty || _partialTranscript.isNotEmpty) ...[
                    SizedBox(height: 30.h),
                    _buildTranscriptSection(),
                  ],
                  if (_hasRecording) ...[
                    SizedBox(height: 30.h),
                    _buildPlaybackSection(),
                  ],
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: const Color(0xFF1976D2),
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IELTS Speaking',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  'Part 2 - Individual Long Turn',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    'Speaking Task',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _currentTask,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Recording Duration
            if (_isRecording || _hasRecording)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _isRecording 
                      ? const Color(0xFFE53935).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _formatDuration(_recordingDuration),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: _isRecording 
                        ? const Color(0xFFE53935)
                        : const Color(0xFF2C3E50),
                  ),
                ),
              ),
            
            SizedBox(height: 24.h),
            
            // Recording Button
            GestureDetector(
              onTap: _isProcessing ? null : _toggleRecording,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isRecording
                              ? [const Color(0xFFE53935), const Color(0xFFD32F2F)]
                              : [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording 
                                ? const Color(0xFFE53935)
                                : const Color(0xFF4CAF50)).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isProcessing
                            ? SizedBox(
                                width: 40.w,
                                height: 40.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 48.sp,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 20.h),
            
            Text(
              _isProcessing
                  ? 'Processing...'
                  : _isRecording
                      ? 'Recording... Tap to stop'
                      : 'Tap to start recording',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            
            if (_partialTranscript.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 16.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Live: $_partialTranscript',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1976D2),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_snippet,
                  color: const Color(0xFF1976D2),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Transcript',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                _transcript.isEmpty ? 'Your speech will appear here...' : _transcript,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: _transcript.isEmpty ? Colors.grey[500] : const Color(0xFF2C3E50),
                  height: 1.5,
                ),
              ),
            ),
            if (_transcript.isNotEmpty) ...[
              SizedBox(height: 16.h),
              GradientButton(
                text: 'Get IELTS Assessment',
                icon: Icons.assessment,
                onPressed: _getIeltsAssessment,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: const Color(0xFF1976D2),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Playback',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    onPressed: _togglePlayback,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recording Duration: ${_formatDuration(_recordingDuration)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _isPlaying ? 'Playing...' : 'Ready to play',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    // final hasPermission = await Permission.microphone.isGranted;
    // if (!hasPermission) {
    //   _showPermissionDialog();
    //   return;
    // }
    
    // Временно пропускаем проверку разрешений для тестирования UI

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String filePath = '${directory.path}/recording_$timestamp.m4a';
      
      try {
        // Попробуем сначала AAC (лучший для iOS)
        await _audioRecorder.start(
          path: filePath,
          encoder: AudioEncoder.aacLc,
          numChannels: 1,
        );
      } catch (aacError) {
        // Fallback: попробуем WAV
        print('AAC failed, trying WAV: $aacError');
        filePath = '${directory.path}/recording_$timestamp.wav';
        await _audioRecorder.start(
          path: filePath,
          encoder: AudioEncoder.wav,
          numChannels: 1,
        );
      }

      setState(() {
        _isRecording = true;
        _recordingPath = filePath;
        _recordingDuration = Duration.zero;
        _transcript = '';
        _partialTranscript = '';
      });

      _pulseController.repeat(reverse: true);
      
      // Start timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration = Duration(seconds: timer.tick);
        });
      });

      // TODO: Start real-time transcription here
      _startRealtimeTranscription();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();
      _pulseController.stop();

      setState(() {
        _isRecording = false;
        _hasRecording = true;
        _isProcessing = true;
      });

      // TODO: Process the recording for final transcription
      await _processRecording();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }

  void _startRealtimeTranscription() {
    // TODO: Implement Google Speech-to-Text streaming
    // Simulate real-time transcription for now
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _partialTranscript = 'I think this journey was really memorable because...';
      });
    });
  }

  Future<void> _processRecording() async {
    if (_recordingPath == null) return;
    
    try {
      final transcript = await _speechService.transcribeFile(_recordingPath!);
      
      setState(() {
        _transcript = transcript;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process recording: $e')),
      );
    }
  }

  Future<void> _togglePlayback() async {
    if (_recordingPath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.setFilePath(_recordingPath!);
        await _audioPlayer.play();
        setState(() {
          _isPlaying = true;
        });

        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play recording: $e')),
      );
    }
  }

  void _getIeltsAssessment() async {
    if (_transcript.isEmpty || _recordingPath == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Analyze audio metrics
      final audioMetrics = _speechService.analyzeAudioMetrics(_recordingPath!, _transcript);
      
      // Get IELTS assessment
      final assessment = await _assessmentService.assessSpeaking(
        transcript: _transcript,
        task: _currentTask,
        audioMetrics: audioMetrics,
      );
      
      setState(() {
        _isProcessing = false;
      });
      
      // Navigate to results page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IeltsResultsPage(
            assessment: assessment,
            transcript: _transcript,
          ),
        ),
      );
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get assessment: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }
}
