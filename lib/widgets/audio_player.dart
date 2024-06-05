import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scmu_2024_smartconnect/utils/my_preferences.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String soundAsset;

  const AudioPlayerWidget({required this.soundAsset, Key? key}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playAudioOnInit();
  }

  Future<void> _playAudioOnInit() async {
    try {
      bool? allow = await MyPreferences.loadData<bool>("PROFILE_AUDIO");
      if(allow != null && allow) {
        await _audioPlayer.setAsset(widget.soundAsset);
        if (!_audioPlayer.playing) {
          _audioPlayer.setLoopMode(LoopMode.off);
          _audioPlayer.play();
        }
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
