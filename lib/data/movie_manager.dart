// Dosya: lib/data/movie_manager.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cinemood/models/movie_model.dart';
import 'package:cinemood/models/person_model.dart';

import 'package:cinemood/data/genre_service.dart';
import 'package:cinemood/services/tmdb_service.dart';
import 'package:cinemood/services/social_service.dart';

export 'package:cinemood/models/movie_model.dart';
export 'package:cinemood/models/person_model.dart';

class MovieManager extends ChangeNotifier {
  static final MovieManager instance = MovieManager._privateConstructor();
  MovieManager._privateConstructor();

  bool isDarkMode = true;
  int currentBgColor = 0xFF12141C;

  bool areNotificationsEnabled = true;
  String? currentChatPartnerId;

  void toggleNotifications(bool value) {
    areNotificationsEnabled = value;
    notifyListeners();
  }

  void enterChat(String partnerId) {
    currentChatPartnerId = partnerId;
  }

  void exitChat() {
    currentChatPartnerId = null;
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;

    if (isDarkMode) {
      currentBgColor = 0xFF12141C;
    } else {
      currentBgColor = 0xFFCFD8DC;
    }

    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'is_dark_mode': isDarkMode,
      });
    }
  }

  Future<void> loadUserTheme() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('is_dark_mode')) {
          isDarkMode = data['is_dark_mode'];
          if (isDarkMode) {
            currentBgColor = 0xFF12141C;
          } else {
            currentBgColor = 0xFFCFD8DC;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Tema yüklenirken hata: $e");
    }
  }

  Future<void> ensureUserExistsInFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'created_at': FieldValue.serverTimestamp(),
        'profile_icon_id': 0,
        'is_dark_mode': true,
      });
    } else {
      await loadUserTheme();
    }
  }

  void changeBackgroundColor(int colorValue) {
    currentBgColor = colorValue;
    notifyListeners();
  }

  final TmdbService _tmdbService = TmdbService.instance;
  final SocialService _socialService = SocialService.instance;

  Map<int, String> _genreMap = {};
  Map<int, String> get genreMap => _genreMap;
  Map<String, int> get genreNameToId =>
      _genreMap.map((key, value) => MapEntry(value, key));
  List<String> get allGenreNames => _genreMap.values.toList();

  final List<String> profileIcons = [
    "https://api.dicebear.com/7.x/bottts/png?seed=Robot1",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Felix",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Chloe",
    "https://api.dicebear.com/7.x/fun-emoji/png?seed=Cool",
    "https://api.dicebear.com/7.x/identicon/png?seed=Abstract",
    "https://api.dicebear.com/7.x/thumbs/png?seed=Bandit",
    "https://api.dicebear.com/7.x/lorelei/png?seed=Artist",
    "https://api.dicebear.com/7.x/notionists/png?seed=Playful",
    "https://api.dicebear.com/7.x/big-ears/png?seed=Mouse",
    "https://api.dicebear.com/7.x/micah/png?seed=Cool",
  ];

  final List<String> groupIcons = [
    "https://api.dicebear.com/7.x/shapes/png?seed=Group1",
    "https://api.dicebear.com/7.x/shapes/png?seed=Group2",
    "https://api.dicebear.com/7.x/shapes/png?seed=Group3",
    "https://api.dicebear.com/7.x/icons/png?seed=Movie",
    "https://api.dicebear.com/7.x/icons/png?seed=Popcorn",
    "https://api.dicebear.com/7.x/identicon/png?seed=Team",
    "https://api.dicebear.com/7.x/initials/png?seed=FC",
    "https://api.dicebear.com/7.x/initials/png?seed=MV",
  ];

  final List<Movie> _allMovies = [];
  List<dynamic> _searchResults = [];
  final List<Movie> _trendingMovies = [];

  final List<Movie> _favoriteMovies = [];
  final List<Movie> _watchedMovies = [];
  final List<Person> _favoriteActors = [];
  final List<Person> _favoriteDirectors = [];
  List<Movie> _appTopRatedMovies = [];
  Set<String> _friendIds = {};

  int _currentPage = 1;
  bool _isFetching = false;
  bool _hasMorePages = true;

  List<int> activeGenreFilters = [];
  bool filterActor = false;
  bool filterDirector = false;

  List<Movie> get allMovies => _allMovies;
  List<dynamic> get searchResults => _searchResults;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get favoriteMovies => _favoriteMovies;
  List<Movie> get watchedMovies => _watchedMovies;
  List<Person> get favoriteActors => _favoriteActors;
  List<Person> get favoriteDirectors => _favoriteDirectors;
  List<Movie> get appTopRatedMovies => _appTopRatedMovies;
  bool get isFetching => _isFetching;

  bool isFavorite(Movie movie) =>
      _favoriteMovies.any((fav) => fav.id == movie.id);
  bool isWatched(Movie movie) =>
      _watchedMovies.any((w) => w.id == movie.id);
  bool isPersonFavorite(Person person) {
    if (person.knownFor == 'Directing') {
      return _favoriteDirectors.any((p) => p.id == person.id);
    }
    return _favoriteActors.any((p) => p.id == person.id);
  }

  bool isFriend(String uid) => _friendIds.contains(uid);

  Future<void> fetchGenres() async {
    if (_genreMap.isNotEmpty) return;
    _genreMap = await _tmdbService.fetchGenres();
    GenreService.instance.setGenreMapping(_genreMap);
    _genreMap.forEach(
      (id, name) => GenreService.instance.fetchGenrePosterUrl(name, id),
    );
    notifyListeners();
  }

  Future<void> fetchNextPageMovies({bool initial = false}) async {
    if (!initial && (_isFetching || !_hasMorePages)) return;
    _isFetching = true;
    if (initial) {
      _currentPage = 1;
      _allMovies.clear();
      _trendingMovies.clear();
      _hasMorePages = true;
      if (_genreMap.isEmpty) await fetchGenres();
    }

    final result = await _tmdbService.fetchPopularMovies(
      _currentPage,
      _genreMap,
    );
    _allMovies.addAll(result['movies']);
    if (initial) _trendingMovies.addAll(result['movies'].take(10));

    if ((result['totalPages']) <= _currentPage) {
      _hasMorePages = false;
    } else {
      _currentPage++;
    }
    _isFetching = false;
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty && activeGenreFilters.isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }
    if (_genreMap.isEmpty) await fetchGenres();

    if (filterActor || filterDirector) {
      List<Person> people = await _tmdbService.searchPersonOnly(query);
      if (activeGenreFilters.isNotEmpty) {
        List<Movie> filteredMovies = [];
        for (var person in people.take(3)) {
          await _tmdbService.fetchPersonDetails(person, _genreMap);
          var matches = person.filmography
              .where(
                (m) => m.genreIds.any((id) => activeGenreFilters.contains(id)),
              )
              .toList();
          filteredMovies.addAll(matches);
        }
        final ids = <int>{};
        _searchResults = filteredMovies.where((m) => ids.add(m.id)).toList();
      } else {
        if (filterActor && !filterDirector) {
          _searchResults = people.where((p) => p.knownFor == 'Acting').toList();
        } else if (!filterActor && filterDirector) {
          _searchResults = people
              .where((p) => p.knownFor == 'Directing')
              .toList();
        } else {
          _searchResults = people;
        }
      }
    } else {
      if (query.isEmpty && activeGenreFilters.isNotEmpty) {
        final genreString = activeGenreFilters.join(',');
        _searchResults = await _tmdbService.discoverMoviesByGenre(
          genreString,
          _genreMap,
        );
      } else {
        Map<String, List<dynamic>> results = await _tmdbService.searchMulti(
          query,
          _genreMap,
        );
        List<dynamic> combined = [];
        for (var m in results['movies']!) {
          if (activeGenreFilters.isEmpty ||
              (m as Movie).genreIds.any(
                (id) => activeGenreFilters.contains(id),
              )) {
            combined.add(m);
          }
        }
        if (activeGenreFilters.isEmpty) combined.addAll(results['people']!);
        _searchResults = combined;
      }
    }
    notifyListeners();
  }

  Future<void> fetchPersonDetails(Person person) async {
    await _tmdbService.fetchPersonDetails(person, _genreMap);
    notifyListeners();
  }

  Future<void> fetchCast(Movie movie) async {
    if (movie.castDetails.isNotEmpty && movie.director != "Unknown") return;
    await _tmdbService.fetchMovieExtras(movie);
    notifyListeners();
  }

  Future<void> fetchTrailerId(Movie movie) async {
    if (movie.trailerId.isNotEmpty) return;
    await _tmdbService.fetchMovieExtras(movie);
    notifyListeners();
  }

  Future<Movie?> getMovieById(int id) async {
    return await _tmdbService.getMovieById(id, _genreMap);
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie)) {
      _favoriteMovies.removeWhere((m) => m.id == movie.id);
      await _socialService.updateFavoriteMovie(movie, false);
    } else {
      _favoriteMovies.add(movie);
      await _socialService.updateFavoriteMovie(movie, true);
    }
    notifyListeners();
  }

  Future<void> toggleWatched(Movie movie) async {
    if (isWatched(movie)) {
      _watchedMovies.removeWhere((m) => m.id == movie.id);
      await _socialService.updateWatchedMovie(movie, false);
    } else {
      _watchedMovies.add(movie);
      await _socialService.updateWatchedMovie(movie, true);
    }
    notifyListeners();
  }

  Future<void> togglePersonFavorite(Person person) async {
    bool isDirector = person.knownFor == 'Directing';
    List<Person> targetList = isDirector ? _favoriteDirectors : _favoriteActors;
    if (isPersonFavorite(person)) {
      targetList.removeWhere((p) => p.id == person.id);
      await _socialService.updateFavoritePerson(person, false);
    } else {
      targetList.add(person);
      await _socialService.updateFavoritePerson(person, true);
    }
    notifyListeners();
  }

  Future<void> loadFavoritesFromFirebase() async {
    final data = await _socialService.fetchAllFavorites();

    if (data.isNotEmpty) {
      if (data.containsKey('favorites_movies')) {
        _favoriteMovies.clear();
        final list = data['favorites_movies'] as List? ?? [];
        for (var item in list) {
          _favoriteMovies.add(Movie.fromMap(item));
        }
      } else if (data.containsKey('favorites')) {
        _favoriteMovies.clear();
        final list = data['favorites'] as List? ?? [];
        for (var item in list) {
          _favoriteMovies.add(Movie.fromMap(item));
        }
      }

      if (data.containsKey('watched_movies')) {
        _watchedMovies.clear();
        final list = data['watched_movies'] as List? ?? [];
        for (var item in list) {
          _watchedMovies.add(Movie.fromMap(item));
        }
      }

      if (data.containsKey('favorites_actors')) {
        _favoriteActors.clear();
        final list = data['favorites_actors'] as List? ?? [];
        for (var item in list) {
          _favoriteActors.add(Person.fromTMDB(item));
        }
      }

      if (data.containsKey('favorites_directors')) {
        _favoriteDirectors.clear();
        final list = data['favorites_directors'] as List? ?? [];
        for (var item in list) {
          _favoriteDirectors.add(Person.fromTMDB(item));
        }
      }
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> getUserListsStream() =>
      _socialService.getUserListsStream();

  Future<void> createCustomList(String name, String type) async =>
      await _socialService.createList(name, type);

  Future<void> addMovieToCustomList(String listId, Movie movie) async =>
      await _socialService.addToList(listId, movie.toMap());

  Future<void> addItemToCustomList(
    String listId,
    Map<String, dynamic> item,
  ) async => await _socialService.addToList(listId, item);

  Future<void> removeMovieFromCustomList(
    String listId,
    Map<String, dynamic> item,
  ) async => await _socialService.removeFromList(listId, item);

  Future<void> deleteCustomList(String listId) async =>
      await _socialService.deleteList(listId);

  Future<void> ensureUserExists() async =>
      await _socialService.ensureUserExists();

  Future<void> updateProfileIcon(int iconIndex) async {
    await _socialService.updateProfileIcon(iconIndex);
    notifyListeners();
  }

  Stream<int> getCurrentUserIconIndex() =>
      _socialService.getUserIconIndexStream();

  Future<List<Map<String, dynamic>>> searchUsersByEmail(String q) =>
      _socialService.searchUsersByEmail(q);

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _socialService.changePassword(currentPassword, newPassword);
  }

  Stream<QuerySnapshot> getFriendsStream() => _socialService.getFriendsStream();
  Stream<QuerySnapshot> getFriendRequestsStream() =>
      _socialService.getFriendRequestsStream();

  Future<void> sendFriendRequest(String uid) async {
    await _socialService.sendFriendRequest(uid, "Unknown");
  }

  Future<void> acceptFriendRequest(String uid, String email) async =>
      await _socialService.acceptFriendRequest(uid, email);

  Future<void> removeFriend(String uid) async =>
      await _socialService.removeFriend(uid);

  void listenToFriendsList() {
    getFriendsStream().listen((snapshot) {
      _friendIds = snapshot.docs.map((d) => d.id).toSet();
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String receiverUid,
    required String text,
    Movie? sharedMovie,
    Map<String, dynamic>? sharedList,
  }) async {
    await _socialService.sendMessage(
      receiverUid,
      text,
      sharedMovie: sharedMovie,
      sharedList: sharedList,
    );
  }

  Stream<QuerySnapshot> getMessagesStream(String uid) =>
      _socialService.getMessagesStream(uid);

  Stream<DocumentSnapshot> getMovieLiveRating(int id) =>
      _socialService.getMovieLiveRating(id);
  Stream<QuerySnapshot> getReviewsStream(int id) =>
      _socialService.getReviewsStream(id);
  Stream<QuerySnapshot> getRepliesStream(String id) =>
      _socialService.getRepliesStream(id);

  Future<void> addReview(
    Movie movie,
    double rating,
    String comment, {
    bool isSpoiler = false,
  }) async {
    await _socialService.addReview(
      movie,
      rating,
      comment,
      isSpoiler: isSpoiler,
    );
    fetchAppTopRatedMovies();
  }

  Future<void> deleteReview(String id) async {
    await _socialService.deleteReview(id);
    fetchAppTopRatedMovies();
  }

  Future<void> editReview(String id, String c, double r) async =>
      await _socialService.editReview(id, c);
  Future<void> toggleLikeReview(String id) async =>
      await _socialService.toggleLikeReview(id);
  Future<void> replyToReview(String id, String t, {bool isSpoiler = false}) async =>
      await _socialService.replyToReview(id, t, isSpoiler: isSpoiler);

  Future<void> fetchAppTopRatedMovies() async {
    _appTopRatedMovies = await _socialService.fetchAppTopRatedMovies();
    notifyListeners();
  }

  List<Movie> recommendByFavoriteGenres() {
    if (_favoriteMovies.isEmpty) return [];
    Map<String, int> genreCounts = {};
    for (var m in _favoriteMovies) {
      for (var g in m.genres) {
        genreCounts[g] = (genreCounts[g] ?? 0) + 1;
      }
    }
    var sortedGenres = genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var topGenres = sortedGenres.take(3).map((e) => e.key).toSet();

    return _allMovies
        .where((m) {
          bool hasGenre = m.genres.any((g) => topGenres.contains(g));
          bool alreadyFav = isFavorite(m);
          return hasGenre && !alreadyFav;
        })
        .take(10)
        .toList();
  }

  // --- AKILLI ONERILER (TMDB recommendations) ---
  final List<Movie> _smartRecommendations = [];
  List<Movie> get smartRecommendations => _smartRecommendations;
  bool _isLoadingRecommendations = false;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  /// Kullanicinin favori + izledigi filmlerden yola cikarak TMDB'nin
  /// "recommendations" verisiyle kisisel oneriler olusturur.
  Future<void> fetchSmartRecommendations() async {
    _isLoadingRecommendations = true;
    notifyListeners();

    if (_genreMap.isEmpty) await fetchGenres();

    // Tohum filmler: once favoriler, sonra izlenenler (en guclu sinyal).
    final seeds = <Movie>[..._favoriteMovies, ..._watchedMovies];
    if (seeds.isEmpty) {
      _smartRecommendations.clear();
      _isLoadingRecommendations = false;
      notifyListeners();
      return;
    }

    // En fazla 5 tohum film kullan (API cagrisini sinirla).
    final uniqueSeeds = <int, Movie>{};
    for (final m in seeds) {
      uniqueSeeds[m.id] = m;
    }
    final seedList = uniqueSeeds.values.take(5).toList();

    // Onerilerden cikartilacaklar: zaten bilinen filmler.
    final excludeIds = <int>{
      ..._favoriteMovies.map((m) => m.id),
      ..._watchedMovies.map((m) => m.id),
    };

    final Map<int, Movie> scored = {};
    for (final seed in seedList) {
      final recs = await _tmdbService.fetchRecommendations(seed.id, _genreMap);
      for (final rec in recs) {
        if (excludeIds.contains(rec.id)) continue;
        // Birden fazla tohumda gecen film daha guclu oneri sayilir;
        // map'te tutarak tekrarsiz birlestiriyoruz.
        scored.putIfAbsent(rec.id, () => rec);
      }
    }

    final result = scored.values.toList()
      ..sort((a, b) => b.popularity.compareTo(a.popularity));

    _smartRecommendations
      ..clear()
      ..addAll(result.take(20));

    _isLoadingRecommendations = false;
    notifyListeners();
  }

  Future<void> renameCustomList(String listId, String newName) async =>
      await _socialService.renameList(listId, newName);

  Map<String, String> getActorDetails(String n) => {"bio": "...", "photo": ""};

  Future<void> createGroup(
    String name,
    String description,
    int iconIndex,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('groups').add({
      'name': name,
      'description': description,
      'created_at': FieldValue.serverTimestamp(),
      'creator_id': user.uid,
      'group_icon_id': iconIndex,
      'members': [user.uid],
      'pending_requests': [],
    });
  }

  Stream<QuerySnapshot> getGroupsStream() {
    return FirebaseFirestore.instance
        .collection('groups')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> requestJoinGroup(String groupId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'pending_requests': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> approveGroupMember(String groupId, String memberId) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'pending_requests': FieldValue.arrayRemove([memberId]),
      'members': FieldValue.arrayUnion([memberId]),
    });
  }

  Future<void> sendGroupMessage(
    String groupId,
    String text, {
    Map<String, dynamic>? sharedMovie,
    Map<String, dynamic>? sharedList,
    Map<String, dynamic>? replyTo,
    bool isSpoiler = false,
    Map<String, dynamic>? sharedBadge,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> data = {
      'sender_id': user.uid,
      'sender_email': user.email,
      'text': text,
      'is_spoiler': isSpoiler,
      'created_at': FieldValue.serverTimestamp(),
      'likes': [],
      'seen_by': [],
    };

    if (sharedBadge != null) {
      data.addAll(sharedBadge);
    }

    if (sharedMovie != null) {
      data['movie_id'] = sharedMovie['id'];
      data['movie_title'] = sharedMovie['title'];
      data['poster_path'] = sharedMovie['poster_path'];
    }

    if (sharedList != null) {
      data['list_id'] = sharedList['id'];
      data['list_name'] = sharedList['name'];
      data['list_count'] = sharedList['count'];
      data['list_type'] = sharedList['type'];
      // List içeriğini kaydet (Önemli fix)
      if (sharedList.containsKey('items')) {
        data['list_items'] = sharedList['items'];
      }
    }

    if (replyTo != null) {
      data['reply_to'] = replyTo;
    }

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(data);

    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();
      final members = List<String>.from(groupDoc.data()?['members'] ?? []);
      final groupName = groupDoc.data()?['name'] ?? "Grup";

      for (var memberId in members) {
        if (memberId == user.uid) continue;

        await _socialService.createNotification(
          memberId,
          "Grup mesajı ($groupName): ${text.isEmpty ? 'Bir içerik paylaşıldı' : text}",
          sharedMovie != null ? sharedMovie['id'] : 0,
          'message',
        );
      }
    } catch (e) {
      debugPrint("Grup bildirim hatası: $e");
    }
  }

  Future<void> toggleGroupMessageLike(String groupId, String msgId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(msgId);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final likes = List<String>.from(snapshot.data()?['likes'] ?? []);
      if (likes.contains(uid)) {
        likes.remove(uid);
      } else {
        likes.add(uid);
      }
      await docRef.update({'likes': likes});
    }
  }

  Future<void> markGroupMessageAsSeen(
    String groupId,
    String msgId,
    String userName,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(msgId);

    await docRef.update({
      'seen_by': FieldValue.arrayUnion([
        {'uid': uid, 'name': userName},
      ]),
    });
  }

  Future<void> updateGroupIcon(String groupId, int iconIndex) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'group_icon_id': iconIndex,
    });
    notifyListeners();
  }

  Stream<QuerySnapshot> getGroupMessagesStream(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> deleteGroup(String groupId) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
    notifyListeners();
  }

  Future<void> updateGroupInfo(
    String groupId,
    String newName,
    String newDesc,
  ) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'name': newName,
      'description': newDesc,
    });
    notifyListeners();
  }
}
