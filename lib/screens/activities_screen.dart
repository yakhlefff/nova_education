import 'package:flutter/material.dart';

import 'primary/math_home_screen.dart';

class ActivitiesScreen extends StatelessWidget {

  final String languageCode;

  const ActivitiesScreen({super.key, required this.languageCode});

  bool get isAr => languageCode == "ar";

  String tr(String ar, String fr, String en) {

    if (languageCode == "ar") return ar;

    if (languageCode == "fr") return fr;

    return en;

  }

  @override

  Widget build(BuildContext context) {

    return Directionality(

      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(

        appBar: AppBar(

          title: Text(tr("الابتدائي - المواد", "Primaire - Matières", "Primary - Subjects")),

        ),

        body: Padding(

          padding: const EdgeInsets.all(16),

          child: Column(

            children: [

              _tile(

                context,

                Icons.calculate,

                tr("الرياضيات", "Mathématiques", "Mathematics"),

                () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) => MathHomeScreen(

                        languageCode: languageCode,

                      ),

                    ),

                  );

                },

              ),

              const SizedBox(height: 12),

              _tile(

                context,

                Icons.abc,

                tr("العربية (قريباً)", "Arabe (bientôt)", "Arabic (soon)"),

                () {

                  ScaffoldMessenger.of(context).showSnackBar(

                    SnackBar(content: Text(tr("قريباً", "Bientôt", "Coming soon"))),

                  );

                },

              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap) {

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(16),

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: Colors.black12),

        ),

        child: Row(

          children: [

            Icon(icon, size: 28),

            const SizedBox(width: 12),

            Expanded(

              child: Text(title,

                  style: const TextStyle(

                      fontSize: 18, fontWeight: FontWeight.bold)),

            ),

            const Icon(Icons.arrow_forward_ios, size: 16),

          ],

        ),

      ),

    );

  }

}