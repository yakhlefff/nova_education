import 'package:flutter/material.dart';

import 'math_home_screen.dart';

class PrimarySubjectsScreen extends StatelessWidget {

  final String languageCode;

  const PrimarySubjectsScreen({super.key, required this.languageCode});

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("المواد - الابتدائي")),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            _button(

              context,

              "📘 الرياضيات",

              () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => MathHomeScreen(languageCode: languageCode),

                  ),

                );

              },

            ),

            const SizedBox(height: 12),

            _button(

              context,

              "🔤 العربية (قريباً)",

              () {

                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(content: Text("سنضيف ألعاب الحروف قريباً")),

                );

              },

            ),

          ],

        ),

      ),

    );

  }

  Widget _button(BuildContext context, String text, VoidCallback onTap) {

    return InkWell(

      onTap: onTap,

      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(18),

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