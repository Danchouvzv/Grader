import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class AudioRecorderService {
  // Using Record (v4) API to match current dependency version
  final Record _recorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Initialize audio session for iOS compatibility
  Future<void> _initializeAudioSession() async {
    if (_isInitialized) return;
    
    try {
      // Configure audio session for iOS
      if (Platform.isIOS) {
        await _recorder.hasPermission(); // This initializes the audio session
        // Add a small delay to ensure session is properly activated
        await Future.delayed(const Duration(milliseconds: 100));
      }
      _isInitialized = true;
    } catch (e) {
      print('⚠️ Audio session initialization warning: $e');
      // Continue anyway - some devices might not need this
    }
  }

  Future<String> startRecording() async {
    try {
      // Initialize audio session first
      await _initializeAudioSession();
      
      // Check permissions
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception('No microphone permission. Please enable microphone access in Settings.');
      }

      // Check if already recording
      if (await _recorder.isRecording()) {
        throw Exception('Recording is already in progress');
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/ielts_${DateTime.now().millisecondsSinceEpoch}.m4a';

      print('🎤 Starting recording to: $path');

      // Start recording with iOS-compatible settings
      await _recorder.start(
        path: path,
        encoder: AudioEncoder.aacLc,
        numChannels: 1,
        // Note: sampleRate and bitRate are not supported in this version of record package
      );

      print('✅ Recording started successfully');
      return path;
    } catch (e) {
      print('❌ Failed to start recording: $e');
      
      // Provide user-friendly error messages
      if (e.toString().contains('Session activation failed')) {
        throw Exception('Microphone is busy. Please close other apps using the microphone and try again.');
      } else if (e.toString().contains('permission')) {
        throw Exception('Microphone permission denied. Please enable microphone access in Settings.');
      } else if (e.toString().contains('already')) {
        throw Exception('Recording is already in progress');
      } else {
        throw Exception('Failed to start recording: ${e.toString()}');
      }
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        print('🛑 Recording stopped: $path');
        return path;
      }
      return null;
    } catch (e) {
      print('❌ Failed to stop recording: $e');
      throw Exception('Failed to stop recording: $e');
    }
  }

  // Legacy methods for compatibility
  Future<String> start() async => startRecording();
  Future<String?> stop() async => stopRecording();

  Future<void> playRecording(String path) async {
    try {
      await _audioPlayer.play(DeviceFileSource(path));
    } catch (e) {
      throw Exception('Failed to play recording: $e');
    }
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    try {
      await _recorder.dispose();
      await _audioPlayer.dispose();
      _isInitialized = false;
    } catch (e) {
      print('⚠️ Error disposing audio services: $e');
    }
  }
}


