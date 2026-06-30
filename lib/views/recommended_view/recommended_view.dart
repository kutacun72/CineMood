// Dosya: lib/views/recommended_view/recommended_view.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemood/app/theme.dart';
import 'package:cinemood/app/router.dart';
import 'package:cinemood/app/widgets/shimmer_loading.dart';
import 'package:cinemood/data/movie_manager.dart';

class RecommendedView extends StatefulWidget {
  const RecommendedView({super.key});

  @override
  State<RecommendedView> createState() => _RecommendedViewState();
}

class _RecommendedViewState extends State<RecommendedView> {
  @override
  void initState() {
    super.initState();
    MovieManager.instance.fetchAppTopRatedMovies();
    MovieManager.instance.fetchSmartRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MovieManager.instance,
      builder: (context, child) {
        final appTopRated = MovieManager.instance.appTopRatedMovies;
        final recommendedByGenre = MovieManager.instance
            .recommendByFavoriteGenres();
        final smartRecs = MovieManager.instance.smartRecommendations;
        final loadingSmart = MovieManager.instance.isLoadingRecommendations;
        final isDark = MovieManager.instance.isDarkMode;

        return Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          body: CustomScrollView(
            slivers: [
              // --- GRADIENT HEADER ---
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: AppTheme.backgroundBlack,
                // GERİ TUŞU EKLENDİ
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
                  onPressed: () => context.go(AppRouters.home),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orangeAccent.withValues(
                            alpha: isDark ? 0.3 : 0.15,
                          ),
                          AppTheme.backgroundBlack,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'FOR YOU',
                        style: TextStyle(
                          color: AppTheme.textColor, // Mavi/Beyaz
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.orangeAccent.withValues(alpha: 0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- 0. KISIM: AKILLI ÖNERİLER (Senin için seçildi) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _buildSectionTitle(
                    context,
                    'Picked For You',
                    Icons.auto_awesome,
                  ),
                ),
              ),
              _buildSmartRecsSliver(context, smartRecs, loadingSmart),

              SliverToBoxAdapter(child: const SizedBox(height: 30)),

              // --- 1. KISIM: KULLANICI PUANLI FİLMLER ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildSectionTitle(
                    context,
                    'Users\' Choice (App Rated > 6)',
                    Icons.stars,
                  ),
                ),
              ),

              _buildMovieListSliver(
                context,
                appTopRated,
                'No ratings yet. Rate some movies to see them here!',
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 30)),

              // --- 2. KISIM: FAVORİ TÜR ÖNERİLERİ ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionTitle(
                    context,
                    'Based on Your Favorites',
                    Icons.category,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 10)),

              _buildMovieListSliver(
                context,
                recommendedByGenre,
                'Add favorites to get genre recommendations.',
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmartRecsSliver(
    BuildContext context,
    List<Movie> movies,
    bool loading,
  ) {
    // Yuklenirken shimmer poster iskeletleri goster.
    if (loading && movies.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 210,
          child: Shimmer(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Shimmer.box(
                width: 130,
                height: 195,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    if (movies.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppTheme.textColor.withValues(alpha: 0.1)),
            ),
            child: Text(
              "Favorite or watch a few movies to get personal picks.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 230,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: movies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final movie = movies[index];
            return GestureDetector(
              onTap: () => context.push('/movie-detail', extra: movie),
              child: SizedBox(
                width: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: movie.poster,
                        width: 130,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(
                          width: 130,
                          height: 180,
                          color: AppTheme.surfaceDark,
                        ),
                        errorWidget: (c, u, e) => Container(
                          width: 130,
                          height: 180,
                          color: Colors.grey,
                          child: const Icon(Icons.movie, color: Colors.white),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 13),
                        const SizedBox(width: 2),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppTheme.textColor.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.textColor, // Mavi/Beyaz
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieListSliver(
    BuildContext context,
    List<Movie> movies,
    String emptyMessage,
  ) {
    if (movies.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.textColor.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final movie = movies[index];
        final isFav = MovieManager.instance.isFavorite(movie);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              onTap: () => context.push('/movie-detail', extra: movie),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie.poster,
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (c, o, s) =>
                      Container(width: 50, height: 75, color: Colors.grey),
                ),
              ),
              title: Text(
                movie.title,
                style: TextStyle(
                  color: AppTheme.textColor, // Mavi/Beyaz
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    movie.genres.isNotEmpty ? movie.genres.first : 'Movie',
                    style: TextStyle(
                      color: AppTheme.textColor.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  if (movie.appRating != null && movie.appRating! > 0)
                    Text(
                      ' • ⭐ ${movie.appRating!.toStringAsFixed(1)} (App)',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav
                      ? Colors.redAccent
                      : AppTheme.iconColor.withValues(alpha: 0.5),
                ),
                onPressed: () => MovieManager.instance.toggleFavorite(movie),
              ),
            ),
          ),
        );
      }, childCount: movies.length),
    );
  }
}
