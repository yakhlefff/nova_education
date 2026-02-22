import 'package:flutter/material.dart';

import '../../services/tts_service.dart';

class NumbersLearnScreen extends StatefulWidget {

  final String languageCode; // ar / fr / en

  const NumbersLearnScreen({super.key, required this.languageCode});

  @override

  State<NumbersLearnScreen> createState() => _NumbersLearnScreenState();

}

class _NumbersLearnScreenState extends State<NumbersLearnScreen> {

  int n = 0;

  final int maxN = 20; // دابا 0..20 (من بعد نرفعوها)

  bool get isAr => widget.languageCode == "ar";

  String tr(String ar, String fr, String en) {

    if (widget.languageCode == "ar") return ar;

    if (widget.languageCode == "fr") return fr;

    return en;

  }

  @override

  void initState() {

    super.initState();

    TtsService.I.init(widget.languageCode);

  }

  Future<void> speakCurrent() async {

    await TtsService.I.init(widget.languageCode);

    await TtsService.I.speak(n.toString());

  }

  void next() {

    if (n >= maxN) return;

    setState(() => n++);

    speakCurrent();

  }

  void prev() {

    if (n <= 0) return;

    setState(() => n--);

    speakCurrent();

  }

  @override

  void dispose() {

    TtsService.I.stop();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return Directionality(

      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(

        appBar: AppBar(

          title: Text(tr("تعلم الأعداد", "Nombres", "Numbers")),

          actions: [

            IconButton(

              tooltip: tr("نطق", "Prononcer", "Speak"),

              icon: const Icon(Icons.volume_up),

              onPressed: speakCurrent,

            ),

          ],

        ),

        body: Padding(

          padding: const EdgeInsets.all(18),

          child: Column(

            children: [

              const SizedBox(height: 12),

              Expanded(

                child: Center(

                  child: Text(

                    "$n",

                    style: const TextStyle(

                      fontSize: 110,

                      fontWeight: FontWeight.w900,

                    ),

                  ),

                ),

              ),

              Row(

                children: [

                  Expanded(

                    child: ElevatedButton.icon(

                      onPressed: n > 0 ? prev : null,

                      icon: const Icon(Icons.chevron_left),

                      label: Text(tr("السابق", "Précédent", "Prev")),

                    ),

                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child: ElevatedButton.icon(

                      onPressed: n < maxN ? next : null,

                      icon: const Icon(Icons.chevron_right),

                      label: Text(tr("التالي", "Suivant", "Next")),

                    ),

                  ),

                ],

              ),

              const SizedBox(height: 12),

              SizedBox(

                width: double.infinity,

                height: 52,

                child: OutlinedButton.icon(

                  onPressed: speakCurrent,

                  icon: const Icon(Icons.volume_up),

                  label: Text(tr("اسمع الرقم", "Écouter", "Listen")),

                ),

              ),

              const SizedBox(height: 8),

              Text(

                tr(

                  "إذا لم يعمل الصوت: ثبّت أصوات اللغة في إعدادات الهاتف.",

                  "Si le son ne marche pas: installe la voix dans les paramètres du téléphone.",

                  "If no sound: install language voice in phone settings.",

                ),

                textAlign: TextAlign.center,

              ),

              const SizedBox(height: 8),

            ],

          ),

        ),

      ),

    );

  }

}