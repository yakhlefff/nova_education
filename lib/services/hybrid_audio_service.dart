import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:just_audio/just_audio.dart';

import 'tts_service.dart';

class HybridAudioService {

  static final HybridAudioService I = HybridAudioService._();

  HybridAudioService._();

  final AudioPlayer _player = AudioPlayer();

  Future<bool> _hasInternet() async {

    final result = await Connectivity().checkConnectivity();

    return result != ConnectivityResult.none;

  }

  // 🔊 تشغيل mp3 من رابط مع cache (مرة أولى يحمل، من بعد يشتغل من التخزين)

  Future<void> _playMp3Url(String url) async {

    final File file = await DefaultCacheManager().getSingleFile(url);

    await _player.stop();

    await _player.setFilePath(file.path);

    await _player.play();

  }

  // ✅ تشغيل تشجيع: mp3 إذا ممكن، وإلا TTS Offline

  Future<void> playFeedback({

    required String languageCode,

    required bool correct,

  }) async {

    // جملة fallback للـ TTS

    final ttsPhrase = _ttsPhrase(languageCode, correct);

    // إذا ما كاينش نت -> مباشرة TTS

    if (!await _hasInternet()) {

      await TtsService.I.init(languageCode);

      await TtsService.I.speak(ttsPhrase);

      return;

    }

    // إذا كاين نت -> جرّب mp3

    final url = _mp3Url(languageCode, correct);

    // إذا ماعندكش روابط mp3 دابا، غادي يرجع TTS مباشرة

    if (url == null) {

      await TtsService.I.init(languageCode);

      await TtsService.I.speak(ttsPhrase);

      return;

    }

    try {

      await _playMp3Url(url);

    } catch (_) {

      // أي فشل -> fallback TTS

      await TtsService.I.init(languageCode);

      await TtsService.I.speak(ttsPhrase);

    }

  }

  // ✅ هنا كتحدّد روابط mp3 ديالك (Firebase Storage مثلا)

  // رجّع null إذا مازال ماحطّيتيش الملفات.

  String? _mp3Url(String lang, bool correct) {

    // ⚠️ بدّل هاد الروابط بروابط ديالك:

    // مثال:

    // https://firebasestorage.googleapis.com/v0/b/...../o/ar_good_1.mp3?alt=media

    if (lang == "ar") {

      return correct

          ? null // <-- حط رابط ar_good.mp3

          : null; // <-- حط رابط ar_tryagain.mp3

    }

    if (lang == "fr") {

      return correct ? null : null;

    }

    return correct ? null : null;

  }

  String _ttsPhrase(String lang, bool correct) {

    if (lang == "ar") return correct ? "ممتاز" : "حاول مرة أخرى";

    if (lang == "fr") return correct ? "Bravo" : "Essaie encore";

    return correct ? "Great" : "Try again";

  }

  Future<void> dispose() async {

    await _player.dispose();

  }

}