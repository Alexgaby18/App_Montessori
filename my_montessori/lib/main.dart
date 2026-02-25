import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_montessori/presentation/screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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