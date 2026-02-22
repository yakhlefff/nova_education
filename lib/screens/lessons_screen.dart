import 'package:flutter/material.dart';

import 'activities_screen.dart';

class LessonsScreen extends StatefulWidget {

  final String languageCode;

  final Future<void> Function() onChangeLanguage;

  const LessonsScreen({

    super.key,

    required this.languageCode,

    required this.onChangeLanguage,

  });

  @override

  State<LessonsScreen> createState() => _LessonsScreenState();

}

class _LessonsScreenState extends State<LessonsScreen> {

  static const cycles = ["primaire", "college", "lycee"];

  String cycle = "primaire";

  String tr(String ar, String fr, String en) {

    if (widget.languageCode == "ar") return ar;

    if (widget.languageCode == "fr") return fr;

    return en;

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(tr("الدروس", "Leçons", "Lessons")),

        actions: [

          IconButton(

            icon: const Icon(Icons.language),

            onPressed: () async {

              await widget.onChangeLanguage();

            },

          )

        ],

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            DropdownButtonFormField<String>(

              value: cycle,

              decoration: const InputDecoration(

                border: OutlineInputBorder(),

              ),

              items: cycles

                  .map((c) => DropdownMenuItem(

                        value: c,

                        child: Text(c),

                      ))

                  .toList(),

              onChanged: (v) {

                if (v == null) return;

                setState(() => cycle = v);

              },

            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              height: 50,

              child: ElevatedButton(

                child: Text(tr("التالي", "Suivant", "Next")),

                onPressed: () {

                  if (cycle == "primaire") {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) => ActivitiesScreen(

                          languageCode: widget.languageCode,

                        ),

                      ),

                    );

                    return;

                  }

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(

                      content: Text("College & Lycee coming later"),

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }

}