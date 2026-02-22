import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {

  final Future<void> Function(String code) onPick;

  const LanguageScreen({super.key, required this.onPick});

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

          ),

        ),

        child: SafeArea(

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                const SizedBox(height: 26),

                Container(

                  width: 88,

                  height: 88,

                  decoration: BoxDecoration(

                    color: Colors.white.withOpacity(0.16),

                    borderRadius: BorderRadius.circular(24),

                    border: Border.all(color: Colors.white24),

                  ),

                  child: const Icon(Icons.school_rounded, size: 48, color: Colors.white),

                ),

                const SizedBox(height: 14),

                const Text(

                  "Nova education",

                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),

                ),

                const SizedBox(height: 8),

                Text(

                  "اختر لغتك للمتابعة\nChoisissez votre langue\nChoose your language",

                  textAlign: TextAlign.center,

                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.35),

                ),

                const Spacer(),

                _langTile("العربية", "Arabic", "🇲🇦", () => onPick("ar")),

                const SizedBox(height: 12),

                _langTile("Français", "French", "🇫🇷", () => onPick("fr")),

                const SizedBox(height: 12),

                _langTile("English", "English", "🇬🇧", () => onPick("en")),

                const SizedBox(height: 18),

              ],

            ),

          ),

        ),

      ),

    );

  }

  Widget _langTile(String t, String s, String flag, Future<void> Function() onTap) {

    return InkWell(

      borderRadius: BorderRadius.circular(18),

      onTap: () async {

        await onTap();

        // ✅ لا Navigator هنا

      },

      child: Container(

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(

          color: Colors.white.withOpacity(0.12),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: Colors.white24),

        ),

        child: Row(

          children: [

            Text(flag, style: const TextStyle(fontSize: 22)),

            const SizedBox(width: 12),

            Expanded(

              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(t, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),

                Text(s, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),

              ]),

            ),

            const Icon(Icons.chevron_right, color: Colors.white),

          ],

        ),

      ),

    );

  }

}