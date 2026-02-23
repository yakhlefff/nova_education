import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'tts_service.dart';

class HybridFeedbackService {
  static final HybridFeedbackService I = HybridFeedbackService._();
  HybridFeedbackService._();

  final AudioPlayer _player = AudioPlayer();

  // ✅ هنا غادي تحط روابط mp3 ديالك (من أي استضافة)
  // نصيحة: دير 3-5 أصوات لكل حالة باش يختار عشوائياً
  List<String> _urlsFor({required String lang, required bool correct}) {
    // ⚠️ بدّل هاد الروابط بروابطك أنت (GitHub Releases / Cloudflare / Supabase / ...)
    if (lang == "ar") {
      return correct
          ? [
              // "https://YOUR_HOST/ar_good_1.mp3",
              // "https://YOUR_HOST/ar_good_2.mp3",
            ]
          : [
              // "https://YOUR_HOST/ar_try_1.mp3",
              // "https://YOUR_HOST/ar_try_2.mp3",
            ];
    }
    if (lang == "fr") {
      return correct
          ? [
              // "https://YOUR_HOST/fr_good_1.mp3",
            ]
          : [
              // "https://YOUR_HOST/fr_try_1.mp3",
            ];
    }
    // en
    return correct
        ? [
            // "https://YOUR_HOST/en_good_1.mp3",
          ]
        : [
            // "https://YOUR_HOST/en_try_1.mp3",
          ];
  }

  String _ttsFallbackPhrase(String lang, bool correct) {
    if (lang == "ar") return correct ? "ممتاز" : "حاول مرة أخرى";
    if (lang == "fr") return correct ? "Bravo" : "Essaie encore";
    return correct ? "Great" : "Try again";
  }

  Future<void> playFeedback({
    required String languageCode,
    required bool correct,
  }) async {
    final urls = _urlsFor(lang: languageCode, correct: correct);

    // ✅ إذا ما كاين حتى URL -> مباشرة TTS
    if (urls.isEmpty) {
      await TtsService.I.init(languageCode);
      await TtsService.I.speak(_ttsFallbackPhrase(languageCode, correct));
      return;
    }

    // ✅ اختار رابط عشوائي
    final url = urls[DateTime.now().millisecondsSinceEpoch % urls.length];

    // ✅ جرّب mp3 (download + cache) وإذا فشل رجّع TTS
    try {
      final File file = await DefaultCacheManager().getSingleFile(url);

      await _player.stop();
      await _player.setFilePath(file.path);
      await _player.play();
    } catch (_) {
      await TtsService.I.init(languageCode);
      await TtsService.I.speak(_ttsFallbackPhrase(languageCode, correct));
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}