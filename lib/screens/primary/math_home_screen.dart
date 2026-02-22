import 'package:flutter/material.dart';
// تعلم الأرقام 
import 'numbers_learn_screen.dart';
//الجمع
import 'add_game_screen.dart';

class MathHomeScreen extends StatelessWidget {

  final String languageCode;

  const MathHomeScreen({super.key, required this.languageCode});

  String t(String key) {

    final ar = {

      "title": "الرياضيات",

      "numbers": "تعلم الأعداد",

      "add": "الجمع",

      "sub": "الطرح",

      "mul": "الضرب",

      "soon": "قريباً...",

    };

    final fr = {

      "title": "Mathématiques",

      "numbers": "Apprendre les nombres",

      "add": "Addition",

      "sub": "Soustraction",

      "mul": "Multiplication",

      "soon": "Bientôt...",

    };

    final en = {

      "title": "Math",

      "numbers": "Learn Numbers",

      "add": "Addition",

      "sub": "Subtraction",

      "mul": "Multiplication",

      "soon": "Coming soon...",

    };

    final map = languageCode == "ar"

        ? ar

        : languageCode == "fr"

            ? fr

            : en;

    return map[key] ?? key;

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text(t("title"))),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            _btn(

              context,

              "🔢 ${t("numbers")}",

              () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>

                        NumbersLearnScreen(languageCode: languageCode),

                  ),

                );

              },

            ),

            const SizedBox(height: 12),

            _btn(context, "➕ ${t("add")}", () {

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) => AddGameScreen(languageCode: languageCode),

    ),

  );

}),

            const SizedBox(height: 12),

            _btn(context, "➖ ${t("sub")}", () {

              _toast(context, t("soon"));

            }),

            const SizedBox(height: 12),

            _btn(context, "✖️ ${t("mul")}", () {

              _toast(context, t("soon"));

            }),

          ],

        ),

      ),

    );

  }

  void _toast(BuildContext context, String msg) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(msg)),

    );

  }

  Widget _btn(BuildContext context, String text, VoidCallback onTap) {

    return InkWell(

      borderRadius: BorderRadius.circular(16),

      onTap: onTap,

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: Colors.black12),

        ),

        child: Text(

          text,

          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

        ),

      ),

    );

  }

}