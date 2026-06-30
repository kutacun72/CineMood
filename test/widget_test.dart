import 'package:flutter_test/flutter_test.dart';

import 'package:cinemood/models/movie_model.dart';

void main() {
  group('Movie model', () {
    test('creates a movie from a TMDB response', () {
      final movie = Movie.fromTMDB(
        {
          'id': 42,
          'title': 'CineMood Test',
          'vote_average': 8.5,
          'poster_path': '/poster.jpg',
          'genre_ids': [18],
          'overview': 'A model test.',
          'release_date': '2026-06-30',
        },
        {18: 'Drama'},
      );

      expect(movie.id, 42);
      expect(movie.title, 'CineMood Test');
      expect(movie.rating, 8.5);
      expect(movie.genres, ['Drama']);
      expect(movie.poster, endsWith('/poster.jpg'));
    });

    test('round-trips persisted movie data', () {
      final original = Movie(
        id: 7,
        title: 'Saved Movie',
        rating: 7.4,
        poster: 'poster-url',
        genres: const ['Action'],
        genreIds: const [28],
        plot: 'A saved movie.',
        director: 'Director',
        releaseDate: '2025-01-01',
      );

      final restored = Movie.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.plot, original.plot);
      expect(restored.director, original.director);
      expect(restored.releaseDate, original.releaseDate);
    });
  });
}
