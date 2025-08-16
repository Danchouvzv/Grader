import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderService {
  // Using Record (v4) API to match current dependency version
  final Record _recorder = Record();

  Future<String> start() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('No microphone permission');
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/ielts_${DateTime.now().millisecondsSinceEpoch}.m4a';

    // Start recording (v4 API: pass params directly)
    await _recorder.start(
      path: path,
      encoder: AudioEncoder.aacLc,
      numChannels: 1,
      // sampleRate is not supported in v4 start signature we use
    );

    return path;
  }

  Future<String?> stop() async {
    if (await _recorder.isRecording()) {
      return await _recorder.stop();
    }
    return null;
  }

  Future<void> dispose() async {
    _recorder.dispose();
  }
}


