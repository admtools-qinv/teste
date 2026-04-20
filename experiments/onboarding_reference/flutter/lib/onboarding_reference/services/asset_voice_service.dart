import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'voice_service.dart';

/// Plays pre-recorded ElevenLabs audio assets mapped by onboarding step ID.
///
/// Pass a [locale] code (e.g. `'en'`, `'pt'`) so the service resolves
/// assets from the correct `assets/audio/<locale>/` folder.
class AssetVoiceService implements VoiceService {
  final AudioPlayer _player = AudioPlayer();
  final String locale;
  Duration _totalDuration = Duration.zero;
  bool _isActive = false;
  StreamSubscription<PlayerState>? _stateSub;

  static const _package = 'onboarding_reference';

  /// Step-ID → filename (without locale prefix).
  static const _fileNames = <String, String>{
    'showcaseWelcome': 'voice_showcase_01_welcome.mp3',
    'showcaseAnalysis': 'voice_showcase_03_ai.mp3',
    'showcaseAI': 'voice_showcase_02_analysis.mp3',
    'showcaseReviews': 'voice_showcase_04_reviews.mp3',
    'welcome': 'voice_01_welcome.mp3',
    'accountType': 'voice_01b_account_type.mp3',
    'experience': 'voice_02_experience.mp3',
    'goal': 'voice_03_goal.mp3',
    'comfort': 'voice_04_risk.mp3',
    'fullName': 'voice_05_name.mp3',
    'email': 'voice_06_email.mp3',
    'emailCode': 'voice_07_verify.mp3',
    'phone': 'voice_08_phone.mp3',
    'pin': 'voice_09_pin.mp3',
    'confirmPin': 'voice_10_pin_confirm.mp3',
    'trial': 'voice_11_done.mp3',
    'timeHorizon': 'voice_12_time_horizon.mp3',
    'lossReaction': 'voice_13_loss_reaction.mp3',
    'allocation': 'voice_14_allocation.mp3',
    'analysing': 'voice_15_analysing.mp3',
    'pep': 'voice_16_pep.mp3',
    'cep': 'voice_17_cep.mp3',
  };

  AssetVoiceService({this.locale = 'en'}) {
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
    final fileName = stepId != null ? _fileNames[stepId] : null;
    if (fileName == null) return;

    try {
      await _player.stop();
      final duration = await _player.setAsset(
        'assets/audio/$locale/$fileName',
        package: _package,
      );
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
