import 'package:flutter/material.dart';

class LessonTile extends StatelessWidget {

  final String title;

  final String description;

  const LessonTile({

    super.key,

    required this.title,

    required this.description,

  });

  @override

  Widget build(BuildContext context) {

    return Card(

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(

        leading: const Icon(Icons.play_lesson_rounded),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),

        subtitle: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),

      ),

    );

  }

}