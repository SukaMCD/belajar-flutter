import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:belajar_flutter/providers/favorite_provider.dart';
import 'package:belajar_flutter/providers/audio_player_provider.dart';
import 'package:provider/provider.dart';
import 'pages/splash_page.dart';
import 'package:belajar_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final favProvider = FavoriteProvider();
  await favProvider.initStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioPlayerProvider>(
          create: (_) => AudioPlayerProvider(),
        ),
        ChangeNotifierProvider<FavoriteProvider>.value(value: favProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1118),
      ),
      home: const SplashScreen(),
    );
  }
}
