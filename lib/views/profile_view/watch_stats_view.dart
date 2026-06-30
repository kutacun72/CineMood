// Dosya: lib/views/profile_view/watch_stats_view.dart
//
// Kullanicinin izledigi filmlerden cikarilan izleme istatistikleri:
//  - Toplam izlenen film ve ortalama puan ozet kartlari
//  - En cok izlenen turler (animasyonlu bar grafik)
//  - En yuksek puanli izlenen filmler seridi

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemood/app/theme.dart';
import 'package:cinemood/app/widgets/badge_widget.dart';
import 'package:cinemood/data/badge_service.dart';
import 'package:cinemood/data/movie_manager.dart';

class WatchStatsView extends StatelessWidget {
  const WatchStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MovieManager.instance,
      builder: (context, _) {
        final watched = MovieManager.instance.watchedMovies;

        return Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundBlack,
            title: const Text("My Stats"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
              onPressed: () => context.pop(),
            ),
          ),
          body: watched.isEmpty
              ? _buildEmptyWithBadges(context)
              : _buildStats(context, watched),
        );
      },
    );
  }

  // Hic izleme yokken: tesvik mesaji + hedef olarak (kilitli) rozetler.
  Widget _buildEmptyWithBadges(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue.withValues(alpha: 0.12),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 44,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Start your journey",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Mark movies as watched to unlock these badges and build your stats.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textColor.withValues(alpha: 0.6),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        // watched bos -> tum rozetler kilitli (hedef) olarak gosterilir.
        _buildBadges(const []),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStats(BuildContext context, List<Movie> watched) {
    // Tur dagilimi
    final Map<String, int> genreCounts = {};
    double ratingSum = 0;
    int ratingCount = 0;
    for (final m in watched) {
      for (final g in m.genres) {
        if (g.isEmpty || g == 'Unknown') continue;
        genreCounts[g] = (genreCounts[g] ?? 0) + 1;
      }
      if (m.rating > 0) {
        ratingSum += m.rating;
        ratingCount++;
      }
    }

    final sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGenres = sortedGenres.take(6).toList();
    final maxGenre = topGenres.isEmpty ? 1 : topGenres.first.value;

    final avgRating = ratingCount > 0 ? ratingSum / ratingCount : 0.0;

    final topRated = [...watched]
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.visibility,
                value: watched.length.toString(),
                label: "Movies watched",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                icon: Icons.star_rounded,
                iconColor: Colors.amber,
                value: avgRating.toStringAsFixed(1),
                label: "Avg. rating",
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        if (topGenres.isNotEmpty) ...[
          _sectionTitle("Top genres"),
          const SizedBox(height: 14),
          ...topGenres.map(
            (e) => _genreBar(e.key, e.value, maxGenre),
          ),
          const SizedBox(height: 28),
        ],

        // --- ROZETLER ---
        _buildBadges(watched),
        const SizedBox(height: 28),

        _sectionTitle("Highest rated"),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topRated.length > 10 ? 10 : topRated.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = topRated[index];
              return GestureDetector(
                onTap: () => context.push('/movie-detail', extra: movie),
                child: SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: movie.poster,
                            width: 110,
                            fit: BoxFit.cover,
                            placeholder: (c, u) =>
                                Container(color: AppTheme.surfaceDark),
                            errorWidget: (c, u, e) =>
                                Container(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: TextStyle(
          color: AppTheme.textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _buildBadges(List<Movie> watched) {
    final badges = BadgeService.computeBadges(
      watched: watched,
      favorites: MovieManager.instance.favoriteMovies,
    );
    final unlockedCount = badges.where((b) => b.unlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle("Badges"),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$unlockedCount / ${badges.length}",
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) => BadgeTile(badge: badges[index]),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? AppTheme.primaryBlue, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _genreBar(String genre, int count, int maxCount) {
    final fraction = (count / maxCount).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                genre,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: AppTheme.textColor.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: AppTheme.surfaceDark,
                ),
                // Animasyonlu dolum
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: fraction),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.accentPink,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
