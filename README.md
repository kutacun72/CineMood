# CineMood

CineMood is a social movie discovery application developed with Flutter for
the EE471 course. It combines movie exploration, personal collections, reviews,
recommendations, and community features in one responsive application.

## Project Information

- Course: EE471
- Student: Kutay Kutacun
- Platform: Flutter (Android and Web)
- Database and authentication: Firebase
- Movie data: TMDB

## Features

- Discover popular movies and browse by genre
- Search for movies, actors, and directors
- View movie details, trailers, cast information, ratings, and reviews
- Mark movies, actors, and directors as favorites
- Create, rename, share, and manage custom lists
- Track watched movies and viewing statistics
- Add spoiler-protected reviews and replies
- Add friends, send notifications, and use direct messaging
- Create groups and share movies or lists in group conversations
- Earn and share viewing achievement badges
- Switch between dark and light themes
- Moderate users, groups, and reviews through the moderator dashboard

## Requirements

- Flutter SDK 3.35 or newer
- Dart SDK 3.9 or newer
- A configured Firebase project
- An internet connection for Firebase and TMDB requests

## Installation

Clone the repository and enter the project directory:

```bash
git clone https://github.com/kutacun72/CineMood.git
cd CineMood
```

Install the dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

To run it in Chrome:

```bash
flutter run -d chrome
```

## Validation

Run the automated checks with:

```bash
flutter analyze
flutter test
flutter build web
```

## Project Structure

```text
lib/
  app/        Application routing, theme, and shared UI
  data/       Movie, genre, badge, and review management
  models/     Domain models
  services/   Firebase social services and TMDB integration
  views/      Feature screens and reusable feature widgets
```

## Author

Kutay Kutacun
EE471 Course Project
