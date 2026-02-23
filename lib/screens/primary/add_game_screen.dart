import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/tts_service.dart';
import '../../services/hybrid_feedback_service.dart';

class AddGameScreen extends StatefulWidget {
  final String languageCode; // ar / fr / en
  const AddGameScreen({super.key, required this.languageCode});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _rng = math.Random();

  int _level = 1; // 1..5
  int _levelCorrect = 0;
  int _levelWrong = 0;

  int _score = 0;
  int _stars = 0;

  int _a = 0, _b = 0, _answer = 0;
  List<int> _choices = [];

  bool _locked = false;
  int? _picked;
  bool _showAnswer = true;
  bool _correct = false; // ✅ FIX

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

  Color get _accent => _palette[(_a + _b) % _palette.length];

  String t(String key) {
    final ar = {
      "title": "لعبة الجمع",
      "level": "المستوى",
      "progress": "تقدم المستوى",
      "score": "النقاط",
      "stars": "نجوم",
      "choose": "اختر الجواب",
      "good": "ممتاز ✅",
      "bad": "حاول مرة أخرى ❌",
      "next": "التالي",
      "passed": "👏 أحسنت! انتقلت للمستوى التالي",
      "showAns": "إظهار الجواب",
      "hideAns": "إخفاء الجواب",
      "stats": "إحصائيات",
      "correct": "صحيح",
      "wrong": "خطأ",
      "reset": "تصفير التقدم",
      "close": "إغلاق",
      "show": "الجواب الصحيح هو",
    };

    final fr = {
      "title": "Jeu d’addition",
      "level": "Niveau",
      "progress": "Progression",
      "score": "Score",
      "stars": "Étoiles",
      "choose": "Choisis la réponse",
      "good": "Bravo ✅",
      "bad": "Essaie encore ❌",
      "next": "Suivant",
      "passed": "👏 Super ! Niveau suivant",
      "showAns": "Afficher réponse",
      "hideAns": "Cacher réponse",
      "stats": "Statistiques",
      "correct": "Juste",
      "wrong": "Faux",
      "reset": "Réinitialiser",
      "close": "Fermer",
      "show": "La bonne réponse est",
    };

    final en = {
      "title": "Addition Game",
      "level": "Level",
      "progress": "Progress",
      "score": "Score",
      "stars": "Stars",
      "choose": "Pick the answer",
      "good": "Great ✅",
      "bad": "Try again ❌",
      "next": "Next",
      "passed": "👏 Awesome! Next level",
      "showAns": "Show answer",
      "hideAns": "Hide answer",
      "stats": "Stats",
      "correct": "Correct",
      "wrong": "Wrong",
      "reset": "Reset progress",
      "close": "Close",
      "show": "Correct answer is",
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
        return 9;
      case 2:
        return 20;
      case 3:
        return 50;
      case 4:
        return 100;
      default:
        return 200;
    }
  }

  int _choicesCountForLevel(int level) {
    if (level == 1) return 2;
    if (level == 2) return 3;
    return 4;
  }

  // Keys (offline save)
  String _kStars() => "add_stars";
  String _kLevel() => "add_level";
  String _kScore() => "add_score";
  String _kLevelCorrect() => "add_level_correct";
  String _kLevelWrong() => "add_level_wrong";
  String _kCorrectFor(int level) => "add_correct_L$level";
  String _kWrongFor(int level) => "add_wrong_L$level";

  @override
  void initState() {
    super.initState();
    TtsService.I.init(widget.languageCode);
    _loadProgress().then((_) => _newQuestion());
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
    _newQuestion();
  }

  void _newQuestion() {
    final maxVal = _maxForLevel(_level);

    _a = _rng.nextInt(maxVal + 1);
    _b = _rng.nextInt(maxVal + 1);
    _answer = _a + _b;

    final count = _choicesCountForLevel(_level);
    final set = <int>{_answer};

    while (set.length < count) {
      final delta = _rng.nextInt(9) - 4;
      final int candidate = math.max(0, _answer + delta);
      set.add(candidate);
    }

    _choices = set.toList()..shuffle(_rng);
    _locked = false;
    _picked = null;
    _correct = false; // ✅ FIX

    setState(() {});
  }

  Future<void> _pick(int v) async {
    if (_locked) return;

    final ok = (v == _answer);

    setState(() {
      _locked = true;
      _picked = v;
      _correct = ok; // ✅ FIX

      if (ok) {
        _score++;
        _levelCorrect++;
      } else {
        _levelWrong++;
      }
    });

    await _incStats(ok: ok);
    await _saveProgress();

    await HybridFeedbackService.I.playFeedback(
      languageCode: widget.languageCode,
      correct: ok,
    );

    if (ok && _levelCorrect >= _needCorrectToPass) {
      setState(() {
        _stars++;
        _level++;
        _levelCorrect = 0;
        _levelWrong = 0;
      });
      await _saveProgress();

      await TtsService.I.init(widget.languageCode);
      await TtsService.I.speak(t("passed"));
    }
  }

  void _next() => _newQuestion();

  Color? _choiceBg(int v) {
    if (!_locked) return null;
    if (v == _answer) return Colors.green.withOpacity(0.18);
    if (_picked == v && v != _answer) return Colors.red.withOpacity(0.18);
    return null;
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
                    Text(
                      t("choose"),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "$_a + $_b = ?",
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(.95),
                      ),
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

                    if (_locked && !_correct && _showAnswer)
                      Text(
                        "${t("bad")} — ${t("show")} $_answer",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    else if (_locked && _correct)
                      Text(
                        t("good"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            ..._choices.map((v) {
              final bg = _choiceBg(v);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _pick(v),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      "$v",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 6),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _locked ? _next : null,
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
