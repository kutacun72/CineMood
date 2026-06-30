// Favorites library screen.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemood/app/router.dart';
import 'package:cinemood/app/theme.dart';
import 'package:cinemood/data/movie_manager.dart';
import 'package:cinemood/views/favorites_view/widgets/favorite_collection_grid.dart';

class FavoritesLibraryView extends StatefulWidget {
  const FavoritesLibraryView({super.key});

  @override
  State<FavoritesLibraryView> createState() => _FavoritesLibraryViewState();
}

class _FavoritesLibraryViewState extends State<FavoritesLibraryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    MovieManager.instance.loadFavoritesFromFirebase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateListDialog(
    String defaultType, {
    List<dynamic>? autoAddItems,
  }) {
    final nameController = TextEditingController();
    String selectedType = defaultType;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(
          "Create New List",
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(
                hintText: "List Name...",
                hintStyle: TextStyle(
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Colors.black12,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              dropdownColor: AppTheme.surfaceDark,
              style: TextStyle(color: AppTheme.textColor),
              decoration: const InputDecoration(
                labelText: "List Type",
                filled: true,
                fillColor: Colors.black12,
              ),
              items: [
                DropdownMenuItem(
                  value: 'movies',
                  child: Text(
                    "Movie List",
                    style: TextStyle(color: AppTheme.textColor),
                  ),
                ),
                DropdownMenuItem(
                  value: 'actor',
                  child: Text(
                    "Actor List",
                    style: TextStyle(color: AppTheme.textColor),
                  ),
                ),
              ],
              onChanged: (val) => selectedType = val!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await MovieManager.instance.createCustomList(
                  nameController.text.trim(),
                  selectedType,
                );
                if (autoAddItems != null && autoAddItems.isNotEmpty) {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('lists')
                        .orderBy('created_at', descending: true)
                        .limit(1)
                        .get();
                    if (snapshot.docs.isNotEmpty) {
                      final newListId = snapshot.docs.first.id;
                      for (var item in autoAddItems) {
                        if (item is Movie) {
                          await MovieManager.instance.addMovieToCustomList(
                            newListId,
                            item,
                          );
                        } else if (item is Person)
                          await MovieManager.instance.addItemToCustomList(
                            newListId,
                            item.toMap(),
                          );
                      }
                    }
                  }
                }
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaction completed!")),
                  );
                }
              }
            },
            child: const Text(
              "Oluştur ve Ekle",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showBulkAddSheet() {
    final index = _tabController.index;
    String typeFilter = index == 0 ? 'movies' : 'actor';
    List<dynamic> itemsToAdd = index == 0
        ? MovieManager.instance.favoriteMovies
        : (index == 1
              ? MovieManager.instance.favoriteActors
              : MovieManager.instance.favoriteDirectors);

    if (itemsToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You don't have a favorite in this category."),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${itemsToAdd.length} öğeyi listeye ekle",
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: MovieManager.instance.getUserListsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    final validLists = docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final type = data['type'] ?? 'movies';
                      if (typeFilter == 'movies') {
                        return type == 'movies' || type == 'movie';
                      }
                      return type == 'actor';
                    }).toList();

                    if (validLists.isEmpty) {
                      return Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showCreateListDialog(
                              typeFilter,
                              autoAddItems: itemsToAdd,
                            );
                          },
                          child: const Text(
                            "Create and Save New List",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: validLists.length,
                      itemBuilder: (context, index) {
                        final listData =
                            validLists[index].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: Icon(Icons.list, color: AppTheme.iconColor),
                          title: Text(
                            listData['name'],
                            style: TextStyle(color: AppTheme.textColor),
                          ),
                          trailing: Icon(
                            Icons.add_circle,
                            color: AppTheme.primaryBlue,
                          ),
                          onTap: () async {
                            Navigator.pop(ctx);
                            for (var item in itemsToAdd) {
                              if (item is Movie) {
                                await MovieManager.instance
                                    .addMovieToCustomList(
                                      validLists[index].id,
                                      item,
                                    );
                              } else if (item is Person)
                                await MovieManager.instance.addItemToCustomList(
                                  validLists[index].id,
                                  item.toMap(),
                                );
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "All favorites have been added to the list.!",
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MovieManager.instance,
      builder: (context, child) {
        final isDark = MovieManager.instance.isDarkMode;
        return Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  floating: true,
                  backgroundColor: AppTheme.backgroundBlack,

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
                            Colors.redAccent.withValues(
                              alpha: isDark ? 0.3 : 0.15,
                            ),
                            AppTheme.backgroundBlack,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "MY FAVORITES",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppTheme.textColor,
                            shadows: [
                              Shadow(
                                color: Colors.redAccent.withValues(alpha: 0.5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primaryBlue,
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "Movies"),
                      Tab(text: "Actors"),
                      Tab(text: "Director"),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                FavoriteMovieGrid(movies: MovieManager.instance.favoriteMovies),
                FavoritePeopleGrid(
                  people: MovieManager.instance.favoriteActors,
                ),
                FavoritePeopleGrid(
                  people: MovieManager.instance.favoriteDirectors,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showBulkAddSheet,
            backgroundColor: AppTheme.primaryBlue,
            icon: const Icon(Icons.playlist_add_check, color: Colors.white),
            label: const Text(
              "Save to List",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
