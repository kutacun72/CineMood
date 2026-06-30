// Dosya: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // EKLENDİ: Bu olmadan hata verir
import 'package:cinemood/app/router.dart';
import 'package:cinemood/app/theme.dart';
import 'package:cinemood/data/movie_manager.dart';
import 'package:cinemood/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await MovieManager.instance.fetchGenres();

  if (FirebaseAuth.instance.currentUser != null) {
    await MovieManager.instance.loadUserTheme();
  }

  await MovieManager.instance.fetchNextPageMovies(initial: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MovieManager.instance,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'CineMood',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.currentTheme,

          routerConfig: router,
        );
      },
    );
  }
}
