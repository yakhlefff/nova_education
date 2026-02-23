import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/tts_service.dart';
import '../../services/hybrid_feedback_service.dart';

class NumberDictationScreen extends StatefulWidget {
  final String languageCode; // ar / fr / en
  const NumberDictationScreen({super.key, required this.languageCode});

  @override
  State<NumberDictationScreen> createState() => _NumberDictationScreenState();
}

class _NumberDictationScreenState extends State<NumberDictationScreen> {
  final _rng = math.Random();
  final _controller = TextEditingController();

  int _level = 1; // 1..5
  int _levelCorrect = 0;
  int _levelWrong = 0;

  int _score = 0; // صحيح عام
  int _stars = 0; // نجوم
  int _target = 0;

  bool _checked = false;
  bool _correct = false;

  bool _showAnswer = true;
  String? _hint;

  static const int _needCorrectToPass = 10;

  bool get isAr => widget.languageCode == "ar";

  final List<Color> _palette = const [
    Color(0xFF5B8DEF),
    Color(0xFF7C5CFF),
    Color(0xFF00B8A9),
    Color(0xFFFF7A59),
    Color(0xFFFBBF24),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
  ];

  Color get _accent => _palette[_target.abs() % _palette.length];

  String t(String key) {
    final ar = {
      "title": "إملاء الأعداد",
      "level": "المستوى",
      "progress": "تقدم المستوى",
      "score": "النقاط",
      "stars": "نجوم",
      "listen": "اسمع الرقم",
      "type": "اكتب الرقم هنا",
      "check": "تحقق",
      "next": "التالي",
      "good": "ممتاز ✅",
      "bad": "حاول مرة أخرى ❌",
      "hint": "تلميح",
      "hintText": "أول رقم:",
      "showAns": "إظهار الجواب",
      "hideAns": "إخفاء الجواب",
      "passed": "👏 أحسنت! انتقلت للمستوى التالي",
      "show": "الجواب الصحيح هو",
      "tip": "اكتب بالأرقام (مثال: 12)",
      "stats": "إحصائيات",
      "correct": "صحيح",
      "wrong": "خطأ",
      "reset": "تصفير التقدم",
      "close": "إغلاق",
    };

    final fr = {
      "title": "Dictée de nombres",
      "level": "Niveau",
      "progress": "Progression",
      "score": "Score",
      "stars": "Étoiles",
      "listen": "Écouter",
      "type": "Écris le nombre",
      "check": "Vérifier",
      "next": "Suivant",
      "good": "Bravo ✅",
      "bad": "Essaie encore ❌",
      "hint": "Indice",
      "hintText": "Premier chiffre :",
      "showAns": "Afficher réponse",
      "hideAns": "Cacher réponse",
      "passed": "👏 Super ! Niveau suivant",
      "show": "La bonne réponse est",
      "tip": "Écris en chiffres (ex: 12)",
      "stats": "Statistiques",
      "correct": "Juste",
      "wrong": "Faux",
      "reset": "Réinitialiser",
      "close": "Fermer",
    };

    final en = {
      "title": "Number Dictation",
      "level": "Level",
      "progress": "Progress",
      "score": "Score",
      "stars": "Stars",
      "listen": "Listen",
      "type": "Type the number",
      "check": "Check",
      "next": "Next",
      "good": "Great ✅",
      "bad": "Try again ❌",
      "hint": "Hint",
      "hintText": "First digit:",
      "showAns": "Show answer",
      "hideAns": "Hide answer",
      "passed": "👏 Awesome! Next level",
      "show": "Correct answer is",
      "tip": "Type digits (e.g. 12)",
      "stats": "Stats",
      "correct": "Correct",
      "wrong": "Wrong",
      "reset": "Reset progress",
      "close": "Close",
    };

    final map = widget.languageCode == "ar"
        ? ar
        : widget.languageCode == "fr"
            ? fr
            : en;

    return map[key] ?? key;
  }

  int _maxForLevel(int level) {
    switch (level) {
      case 1:
        return 9; // 0..9
      case 2:
        return 20; // 0..20
      case 3:
        return 50; // 0..50
      case 4:
        return 100; // 0..100
      default:
        return 200; // 0..200
    }
  }

  int get _maxN => _maxForLevel(_level);

  // Keys
  String _kStars() => "nd_stars";
  String _kLevel() => "nd_level";
  String _kScore() => "nd_score";
  String _kLevelCorrect() => "nd_level_correct";
  String _kLevelWrong() => "nd_level_wrong";

  String _kCorrectFor(int level) => "nd_correct_L$level";
  String _kWrongFor(int level) => "nd_wrong_L$level";

  @override
  void initState() {
    super.initState();
    TtsService.I.init(widget.languageCode);
    _loadProgress().then((_) => _newQuestion(autoSpeak: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    TtsService.I.stop();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stars = prefs.getInt(_kStars()) ?? 0;
      _level = prefs.getInt(_kLevel()) ?? 1;
      _score = prefs.getInt(_kScore()) ?? 0;
      _levelCorrect = prefs.getInt(_kLevelCorrect()) ?? 0;
      _levelWrong = prefs.getInt(_kLevelWrong()) ?? 0;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStars(), _stars);
    await prefs.setInt(_kLevel(), _level);
    await prefs.setInt(_kScore(), _score);
    await prefs.setInt(_kLevelCorrect(), _levelCorrect);
    await prefs.setInt(_kLevelWrong(), _levelWrong);
  }

  Future<void> _incStats({required bool ok}) async {
    final prefs = await SharedPreferences.getInstance();
    final cKey = _kCorrectFor(_level);
    final wKey = _kWrongFor(_level);
    if (ok) {
      await prefs.setInt(cKey, (prefs.getInt(cKey) ?? 0) + 1);
    } else {
      await prefs.setInt(wKey, (prefs.getInt(wKey) ?? 0) + 1);
    }
  }

  Future<Map<String, int>> _readStats() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, int>{};
    for (int l = 1; l <= 5; l++) {
      map["c$l"] = prefs.getInt(_kCorrectFor(l)) ?? 0;
      map["w$l"] = prefs.getInt(_kWrongFor(l)) ?? 0;
    }
    return map;
  }

  Future<void> _resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStars());
    await prefs.remove(_kLevel());
    await prefs.remove(_kScore());
    await prefs.remove(_kLevelCorrect());
    await prefs.remove(_kLevelWrong());
    for (int l = 1; l <= 5; l++) {
      await prefs.remove(_kCorrectFor(l));
      await prefs.remove(_kWrongFor(l));
    }
    setState(() {
      _stars = 0;
      _level = 1;
      _score = 0;
      _levelCorrect = 0;
      _levelWrong = 0;
    });
    _newQuestion(autoSpeak: true);
  }

  void _newQuestion({bool autoSpeak = false}) {
    _target = _rng.nextInt(_maxN + 1);
    _controller.clear();
    _checked = false;
    _correct = false;
    _hint = null;
    setState(() {});
    if (autoSpeak) _speakNumber();
  }

  Future<void> _speakNumber() async {
    await TtsService.I.init(widget.languageCode);
    await TtsService.I.speak(_target.toString());
  }

  void _makeHint() {
    final s = _target.toString();
    if (s.length >= 2) {
      setState(() => _hint = s[0]);
    } else {
      setState(() => _hint = s);
    }
  }

  Future<void> _check() async {
    final text = _controller.text.trim();
    final parsed = int.tryParse(text);
    final ok = (parsed == _target);

    setState(() {
      _checked = true;
      _correct = ok;

      if (ok) {
        _score++;
        _levelCorrect++;
      } else {
        _levelWrong++;
      }
    });

    // ✅ stats + save
    await _incStats(ok: ok);
    await _saveProgress();

    // ✅ Hybrid feedback: mp3 if available else TTS
    await HybridFeedbackService.I.playFeedback(
      languageCode: widget.languageCode,
      correct: ok,
    );

    // ✅ pass level -> +⭐ and next level
    if (_levelCorrect >= _needCorrectToPass) {
      setState(() {
        _stars++;
        _level++;
        _levelCorrect = 0;
        _levelWrong = 0;
      });
      await _saveProgress();

      // صوت انتقال المستوى (TTS)
      await TtsService.I.init(widget.languageCode);
      await TtsService.I.speak(t("passed"));
    }
  }

  void _next() {
    _newQuestion(autoSpeak: true);
  }

  Future<void> _openStats() async {
    final stats = await _readStats();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("stats")),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (i) {
              final l = i + 1;
              final c = stats["c$l"] ?? 0;
              final w = stats["w$l"] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "${t("level")} $l — ${t("correct")}: $c  |  ${t("wrong")}: $w",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllProgress();
            },
            child: Text(t("reset")),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t("close")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_levelCorrect / _needCorrectToPass).clamp(0.0, 1.0);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t("title")),
          actions: [
            IconButton(
              tooltip: t("stats"),
              icon: const Icon(Icons.bar_chart),
              onPressed: _openStats,
            ),
            IconButton(
              tooltip: t("listen"),
              icon: const Icon(Icons.volume_up),
              onPressed: _speakNumber,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip("${t("level")}: $_level"),
                _chip("${t("progress")}: $_levelCorrect/$_needCorrectToPass"),
                _chip("${t("score")}: $_score"),
                _chip("⭐ ${t("stars")}: $_stars"),
              ],
            ),
            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.black.withOpacity(.06),
                valueColor: AlwaysStoppedAnimation<Color>(_accent),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [_accent.withOpacity(.95), _accent.withOpacity(.60)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t("tip"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _speakNumber,
                          icon: const Icon(Icons.volume_up, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "?",
                      style: TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(.95),
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (_hint != null)
                      Text(
                        "${t("hintText")} $_hint",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: t("type"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!_checked) _check();
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _hint == null ? _makeHint : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(t("hint")),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _checked ? null : _check,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                t("check"),
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SwitchListTile(
                      value: _showAnswer,
                      onChanged: (v) => setState(() => _showAnswer = v),
                      title: Text(
                        _showAnswer ? t("showAns") : t("hideAns"),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                      activeColor: Colors.white,
                    ),

                    const SizedBox(height: 6),

                    if (_checked)
                      Text(
                        _correct
                            ? t("good")
                            : (_showAnswer
                                ? "${t("bad")} — ${t("show")} $_target"
                                : t("bad")),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _checked ? _next : null,
                icon: const Icon(Icons.navigate_next),
                label: Text(t("next")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.06),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}