import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(VoiceRecorderApp());
}

class VoiceRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VoiceRecorderPage(),
    );
  }
}

class VoiceRecorderPage extends StatefulWidget {
  @override
  _VoiceRecorderPageState createState() => _VoiceRecorderPageState();
}

class _VoiceRecorderPageState extends State<VoiceRecorderPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    // Request microphone permission
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/recorded_audio.aac';
    await _recorder.startRecorder(toFile: _filePath);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _playRecording() async {
    if (_filePath != null) {
      await _player.startPlayer(
        fromURI: _filePath,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _stopPlaying() async {
    await _player.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 50,
                color: _isRecording ? Colors.red : Colors.blue,
              ),
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.stop : Icons.play_arrow,
                size: 50,
                color: _isPlaying ? Colors.red : Colors.green,
              ),
              onPressed: _isPlaying ? _stopPlaying : _playRecording,
            ),
          ],
        ),
      ),
    );
  }
}
