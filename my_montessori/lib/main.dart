import 'package:flutter/material.dart';
import 'package:my_montessori/presentation/screens/home.dart';
import 'package:my_montessori/presentation/screens/learn/learn_letter.dart';
import 'package:my_montessori/presentation/screens/complete/complete_letter.dart';
import 'package:my_montessori/presentation/screens/selection/selection_word.dart';
import 'package:my_montessori/presentation/screens/practice/practice_letter.dart';
import 'package:my_montessori/presentation/screens/conect/conect_letter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Montessori',
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}