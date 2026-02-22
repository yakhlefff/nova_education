import 'package:flutter_tts/flutter_tts.dart';

class TtsService {

  static final TtsService I = TtsService._();

  TtsService._();

  final FlutterTts _tts = FlutterTts();

  Future<void> init(String languageCode) async {

    // ar / fr / en

    if (languageCode == "ar") {

      await _tts.setLanguage("ar");

      await _tts.setSpeechRate(0.45);

    } else if (languageCode == "fr") {

      await _tts.setLanguage("fr-FR");

      await _tts.setSpeechRate(0.48);

    } else {

      await _tts.setLanguage("en-US");

      await _tts.setSpeechRate(0.48);

    }

  }

  Future<void> speak(String text) async {

    await _tts.stop();

    await _tts.speak(text);

  }

  Future<void> stop() async {

    await _tts.stop();

  }

}