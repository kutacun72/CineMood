import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemood/app/router.dart';
import 'package:cinemood/app/theme.dart';
import 'package:cinemood/app/widgets/empty_state.dart';
import 'package:cinemood/app/widgets/shimmer_loading.dart';
import 'package:cinemood/models/movie_model.dart';
import 'package:cinemood/models/person_model.dart';

class FavoriteMovieGrid extends StatelessWidget {
  const FavoriteMovieGrid({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const EmptyState(
        icon: Icons.movie_outlined,
        title: 'No favorite movies yet',
        message: 'Tap the heart on a movie to see it here.',
      );
    }

    return _FavoriteGrid(
      itemCount: movies.length,
      childAspectRatio: 0.6,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () => context.push(AppRouters.movieDetail, extra: movie),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: movie.poster,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Shimmer(
                      child: Shimmer.box(borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                movie.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FavoritePeopleGrid extends StatelessWidget {
  const FavoritePeopleGrid({super.key, required this.people});

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return const EmptyState(
        icon: Icons.person_outline_rounded,
        title: 'No favorites here yet',
        message: 'Add actors or directors to build your list.',
      );
    }

    return _FavoriteGrid(
      itemCount: people.length,
      childAspectRatio: 0.75,
      itemBuilder: (context, index) {
        final person = people[index];
        return GestureDetector(
          onTap: () => context.push(AppRouters.personDetail, extra: person),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(person.profilePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FavoriteGrid extends StatelessWidget {
  const _FavoriteGrid({
    required this.itemCount,
    required this.childAspectRatio,
    required this.itemBuilder,
  });

  final int itemCount;
  final double childAspectRatio;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
