import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundPreset {
  final String name;
  final String url;
  final String iconEmoji;

  const SoundPreset({
    required this.name,
    required this.url,
    required this.iconEmoji,
  });
}

class SoundNotifier extends Notifier<SoundPreset?> {
  final AudioPlayer _player = AudioPlayer();

  @override
  SoundPreset? build() {
    return null; // No sound initially
  }

  bool get isPlaying => _player.state == PlayerState.playing;

  static const List<SoundPreset> presets = [
    SoundPreset(
      name: 'Heavy Rain',
      url:
          'https://assets.mixkit.co/active_storage/sfx/2434/2434-preview.mp3', // Bird/Rain mix
      iconEmoji: '🌧️',
    ),
    SoundPreset(
      name: 'Forest',
      url:
          'https://assets.mixkit.co/active_storage/sfx/2515/2515-preview.mp3', // Forest birds
      iconEmoji: '🌲',
    ),
    SoundPreset(
      name: 'Fireplace',
      url:
          'https://assets.mixkit.co/active_storage/sfx/249/249-preview.mp3', // Fire crackling
      iconEmoji: '🔥',
    ),
    SoundPreset(
      name: 'Coffee Shop',
      url:
          'https://assets.mixkit.co/active_storage/sfx/993/993-preview.mp3', // Cafe ambience
      iconEmoji: '☕',
    ),
  ];

  Future<void> play(SoundPreset preset) async {
    if (state == preset && _player.state == PlayerState.playing) {
      return; // Already playing this
    }

    try {
      await _player.stop();
      state = preset;

      // Use setSourceUrl for remote files
      await _player.play(UrlSource(preset.url));
      await _player.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing sound: $e');
      // Optionally reset state if error
      state = null;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = null;
  }
}

final soundProvider = NotifierProvider<SoundNotifier, SoundPreset?>(() {
  return SoundNotifier();
});
