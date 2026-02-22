import 'dart:math' as math;

import 'package:flutter/material.dart';

class AddGameScreen extends StatefulWidget {

  final String languageCode; // ar / fr / en

  const AddGameScreen({super.key, required this.languageCode});

  @override

  State<AddGameScreen> createState() => _AddGameScreenState();

}

class _AddGameScreenState extends State<AddGameScreen> {

  final _rng = math.Random();

  int _stage = 1; // 1=>2 choices, 2=>3, 3=>4

  int _questionIndex = 1;

  final int _total = 15;

  int _a = 0, _b = 0, _answer = 0;

  List<int> _choices = [];

  int _score = 0;

  bool _locked = false;

  int? _picked;

  bool get isAr => widget.languageCode == "ar";

  String t(String key) {

    final ar = {

      "title": "لعبة الجمع",

      "q": "سؤال",

      "of": "من",

      "score": "النقاط",

      "choose": "اختر الجواب",

      "next": "التالي",

      "finish": "إنهاء",

      "good": "ممتاز ✅",

      "bad": "خطأ ❌",

      "doneTitle": "انتهت اللعبة",

      "doneMsg": "نتيجتك",

      "again": "أعد اللعب",

      "back": "رجوع",

    };

    final fr = {

      "title": "Jeu d’addition",

      "q": "Question",

      "of": "sur",

      "score": "Score",

      "choose": "Choisis la réponse",

      "next": "Suivant",

      "finish": "Terminer",

      "good": "Bravo ✅",

      "bad": "Faux ❌",

      "doneTitle": "Jeu terminé",

      "doneMsg": "Ton score",

      "again": "Rejouer",

      "back": "Retour",

    };

    final en = {

      "title": "Addition Game",

      "q": "Question",

      "of": "of",

      "score": "Score",

      "choose": "Pick the answer",

      "next": "Next",

      "finish": "Finish",

      "good": "Great ✅",

      "bad": "Wrong ❌",

      "doneTitle": "Game finished",

      "doneMsg": "Your score",

      "again": "Play again",

      "back": "Back",

    };

    final map = widget.languageCode == "ar"

        ? ar

        : widget.languageCode == "fr"

            ? fr

            : en;

    return map[key] ?? key;

  }

  int choicesCount() => _stage == 1 ? 2 : _stage == 2 ? 3 : 4;

  int maxNumber() {

    if (_stage == 1) return 9;

    if (_stage == 2) return 20;

    return 50;

  }

  @override

  void initState() {

    super.initState();

    _newQuestion();

  }

  void _newQuestion() {

    final maxVal = maxNumber();

    _a = _rng.nextInt(maxVal + 1);

    _b = _rng.nextInt(maxVal + 1);

    _answer = _a + _b;

    final set = <int>{_answer};

    while (set.length < choicesCount()) {

      final delta = _rng.nextInt(9) - 4; // -4..+4

      final int candidate = math.max(0, _answer + delta);

      set.add(candidate);

    }

    _choices = set.toList()..shuffle(_rng);

    _locked = false;

    _picked = null;

    setState(() {});

  }

  void _pick(int v) {

    if (_locked) return;

    _locked = true;

    _picked = v;

    if (v == _answer) _score++;

    setState(() {});

  }

  void _next() {

    if (_questionIndex >= _total) {

      _showDone();

      return;

    }

    setState(() {

      _questionIndex++;

      // تدرج: 1..5 stage1, 6..10 stage2, 11..15 stage3

      if (_questionIndex == 6) _stage = 2;

      if (_questionIndex == 11) _stage = 3;

    });

    _newQuestion();

  }

  void _restart() {

    setState(() {

      _stage = 1;

      _questionIndex = 1;

      _score = 0;

    });

    _newQuestion();

  }

  void _showDone() {

    showDialog(

      context: context,

      builder: (_) => AlertDialog(

        title: Text(t("doneTitle")),

        content: Text("${t("doneMsg")}: $_score / $_total"),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(context);

              _restart();

            },

            child: Text(t("again")),

          ),

          TextButton(

            onPressed: () {

              Navigator.pop(context);

              Navigator.pop(context);

            },

            child: Text(t("back")),

          ),

        ],

      ),

    );

  }

  Color? _choiceBg(int v) {

    if (!_locked) return null;

    if (v == _answer) return Colors.green.withOpacity(0.18);

    if (_picked == v && v != _answer) return Colors.red.withOpacity(0.18);

    return null;

  }

  @override

  Widget build(BuildContext context) {

    return Directionality(

      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(

        appBar: AppBar(

          title: Text(t("title")),

        ),

        body: ListView(

          padding: const EdgeInsets.all(16),

          children: [

            Row(

              children: [

                Expanded(

                  child: _chip("${t("q")}: $_questionIndex ${t("of")} $_total"),

                ),

                const SizedBox(width: 10),

                Expanded(

                  child: _chip("${t("score")}: $_score"),

                ),

              ],

            ),

            const SizedBox(height: 14),

            Card(

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

              child: Padding(

                padding: const EdgeInsets.all(18),

                child: Column(

                  children: [

                    Text(t("choose")),

                    const SizedBox(height: 10),

                    Text(

                      "$_a + $_b = ?",

                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),

                    ),

                    const SizedBox(height: 10),

                    if (_locked)

                      Text(

                        _picked == _answer ? t("good") : t("bad"),

                        style: TextStyle(

                          fontWeight: FontWeight.w900,

                          color: _picked == _answer ? Colors.green : Colors.red,

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

                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),

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

                label: Text(_questionIndex >= _total ? t("finish") : t("next")),

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