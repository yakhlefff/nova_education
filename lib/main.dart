import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';

import 'screens/language_screen.dart';

import 'screens/lessons_screen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const NovaEducationApp());

}

class NovaEducationApp extends StatefulWidget {

  const NovaEducationApp({super.key});

  @override

  State<NovaEducationApp> createState() => _NovaEducationAppState();

}

class _NovaEducationAppState extends State<NovaEducationApp> {

  String? _languageCode; // ar / fr / en

  bool _loading = true;

  @override

  void initState() {

    super.initState();

    _loadSavedLanguage();

  }

  Future<void> _loadSavedLanguage() async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {

      _languageCode = prefs.getString('language');

      _loading = false;

    });

  }

  Future<void> _setLanguage(String code) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('language', code);

    setState(() => _languageCode = code);

  }

  Future<void> _resetLanguage() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('language');

    setState(() => _languageCode = null);

  }

  @override

  Widget build(BuildContext context) {

    if (_loading) {

      return const MaterialApp(

        debugShowCheckedModeBanner: false,

        home: Scaffold(

          body: Center(child: CircularProgressIndicator()),

        ),

      );

    }

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Nova Education',

      theme: ThemeData(

        useMaterial3: true,

        colorSchemeSeed: Colors.indigo,

      ),

      home: _languageCode == null

          ? LanguageScreen(onPick: _setLanguage)

          : LessonsScreen(

              languageCode: _languageCode!,

              onChangeLanguage: _resetLanguage,

            ),

    );

  }

}