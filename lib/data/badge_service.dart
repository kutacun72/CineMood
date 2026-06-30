// Dosya: lib/data/badge_service.dart
//
// Kullanicinin izleme/favori verisinden basari rozetleri (achievements)
// hesaplar. Tamamen yerel veriden uretilir; ekstra Firestore okumasi yoktur.

import 'package:flutter/material.dart';
import 'package:cinemood/models/movie_model.dart';

class BadgeInfo {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  /// Su anki ilerleme (orn. 7 izlenen film).
  final int progress;

  /// Rozetin acilmasi icin gereken hedef (orn. 10).
  final int goal;

  const BadgeInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.progress,
    required this.goal,
  });

  bool get unlocked => progress >= goal;

  /// 0.0 - 1.0 arasi ilerleme orani.
  double get fraction => goal == 0 ? 0 : (progress / goal).clamp(0.0, 1.0);
}

class BadgeService {
  BadgeService._();

  /// Verilen izleme ve favori listelerinden tum rozetleri hesaplar.
  /// Acilan rozetler once gelecek sekilde siralanir.
  static List<BadgeInfo> computeBadges({
    required List<Movie> watched,
    required List<Movie> favorites,
  }) {
    // Tur sayimi (izlenenler uzerinden).
    final Map<String, int> genreCounts = {};
    for (final m in watched) {
      for (final g in m.genres) {
        if (g.isEmpty || g == 'Unknown') continue;
        genreCounts[g] = (genreCounts[g] ?? 0) + 1;
      }
    }

    int genre(String name) => genreCounts[name] ?? 0;

    final badges = <BadgeInfo>[
      // --- Izleme kilometre taslari ---
      BadgeInfo(
        id: 'first_watch',
        title: 'First Steps',
        description: 'Watch your first movie',
        icon: Icons.play_circle_fill_rounded,
        color: Colors.tealAccent,
        progress: watched.length,
        goal: 1,
      ),
      BadgeInfo(
        id: 'watch_10',
        title: 'Movie Buff',
        description: 'Watch 10 movies',
        icon: Icons.local_movies_rounded,
        color: Colors.lightBlueAccent,
        progress: watched.length,
        goal: 10,
      ),
      BadgeInfo(
        id: 'watch_50',
        title: 'Cinephile',
        description: 'Watch 50 movies',
        icon: Icons.theaters_rounded,
        color: Colors.purpleAccent,
        progress: watched.length,
        goal: 50,
      ),
      BadgeInfo(
        id: 'watch_100',
        title: 'Legend',
        description: 'Watch 100 movies',
        icon: Icons.emoji_events_rounded,
        color: Colors.amber,
        progress: watched.length,
        goal: 100,
      ),

      // --- Favori rozeti ---
      BadgeInfo(
        id: 'fav_10',
        title: 'Collector',
        description: 'Add 10 favorites',
        icon: Icons.favorite_rounded,
        color: Colors.redAccent,
        progress: favorites.length,
        goal: 10,
      ),

      // --- Tur ustaliklari ---
      BadgeInfo(
        id: 'horror_master',
        title: 'Horror Master',
        description: 'Watch 5 Horror movies',
        icon: Icons.dark_mode_rounded,
        color: Colors.deepPurpleAccent,
        progress: genre('Horror'),
        goal: 5,
      ),
      BadgeInfo(
        id: 'comedy_fan',
        title: 'Comedian',
        description: 'Watch 5 Comedy movies',
        icon: Icons.sentiment_very_satisfied_rounded,
        color: Colors.orangeAccent,
        progress: genre('Comedy'),
        goal: 5,
      ),
      BadgeInfo(
        id: 'action_hero',
        title: 'Action Hero',
        description: 'Watch 5 Action movies',
        icon: Icons.local_fire_department_rounded,
        color: Colors.deepOrangeAccent,
        progress: genre('Action'),
        goal: 5,
      ),
      BadgeInfo(
        id: 'romantic',
        title: 'Hopeless Romantic',
        description: 'Watch 5 Romance movies',
        icon: Icons.favorite_border_rounded,
        color: Colors.pinkAccent,
        progress: genre('Romance'),
        goal: 5,
      ),
      BadgeInfo(
        id: 'sci_fi',
        title: 'Time Traveler',
        description: 'Watch 5 Sci-Fi movies',
        icon: Icons.rocket_launch_rounded,
        color: Colors.cyanAccent,
        progress: genre('Science Fiction'),
        goal: 5,
      ),
    ];

    // Acilanlar once, sonra ilerlemeye en yakin olanlar.
    badges.sort((a, b) {
      if (a.unlocked != b.unlocked) return a.unlocked ? -1 : 1;
      return b.fraction.compareTo(a.fraction);
    });

    return badges;
  }
}
