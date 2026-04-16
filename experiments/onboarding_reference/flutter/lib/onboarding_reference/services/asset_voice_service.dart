import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'voice_service.dart';

/// Plays pre-recorded ElevenLabs audio assets mapped by onboarding step ID.
class AssetVoiceService implements VoiceService {
  final AudioPlayer _player = AudioPlayer();
  Duration _totalDuration = Duration.zero;
  bool _isActive = false;
  StreamSubscription<PlayerState>? _stateSub;

  static const _package = 'onboarding_reference';

  static const _assets = <String, String>{
    'welcome': 'audio/voice_01_welcome.mp3',
    'experience': 'audio/voice_02_experience.mp3',
    'goal': 'audio/voice_03_goal.mp3',
    'comfort': 'audio/voice_04_risk.mp3',
    'fullName': 'audio/voice_05_name.mp3',
    'email': 'audio/voice_06_email.mp3',
    'emailCode': 'audio/voice_07_verify.mp3',
    'phone': 'audio/voice_08_phone.mp3',
    'pin': 'audio/voice_09_pin.mp3',
    'confirmPin': 'audio/voice_10_pin_confirm.mp3',
    'trial': 'audio/voice_11_done.mp3',
    'timeHorizon': 'audio/voice_12_time_horizon.mp3',
    'lossReaction': 'audio/voice_13_loss_reaction.mp3',
    'allocation': 'audio/voice_14_allocation.mp3',
    'analysing': 'audio/voice_15_analysing.mp3',
  };

  AssetVoiceService() {
    _stateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed ||
          state.processingState == ProcessingState.idle) {
        _isActive = false;
      }
    });
  }

  @override
  Future<void> initialize() async {}

  @override
  Stream<double> get progressStream => _player.positionStream.map((pos) {
        if (!_isActive) return 1.0;
        if (_totalDuration.inMilliseconds <= 0) return 0.0;
        return (pos.inMilliseconds / _totalDuration.inMilliseconds)
            .clamp(0.0, 1.0);
      });

  @override
  Stream<int> get positionMsStream => _player.positionStream.map((pos) {
        if (!_isActive) return -1;
        return pos.inMilliseconds;
      });

  @override
  Future<void> speak(String text, {String? stepId}) async {
    final asset = stepId != null ? _assets[stepId] : null;
    if (asset == null) return;

    try {
      await _player.stop();
      final duration =
          await _player.setAsset('assets/$asset', package: _package);
      _totalDuration = duration ?? Duration.zero;
      _isActive = true;
      await _player.play();
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    _isActive = false;
    try {
      await _player.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    _isActive = false;
    _stateSub?.cancel();
    await _player.dispose();
  }
}
