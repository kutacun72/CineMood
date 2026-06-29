// Dosya: lib/views/app_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemood/app/theme.dart';
import 'package:cinemood/app/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinemood/services/social_service.dart';
import 'package:cinemood/data/movie_manager.dart';
import 'dart:async';

class AppView extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppView({super.key, required this.navigationShell});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListeningForNotifications();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  bool _isFirstNotificationSnapshot = true;

  void _startListeningForNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipient_id', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          // ?lk snapshot, uygulama a??ld???nda zaten var olan (eski) bildirimleri
          // ta??r. Bunlar? ekrana d???rm?yoruz; sadece bundan SONRA eklenenleri
          // canl? bildirim olarak g?steriyoruz.
          if (_isFirstNotificationSnapshot) {
            _isFirstNotificationSnapshot = false;
            return;
          }

          for (var change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;

            final data = change.doc.data() as Map<String, dynamic>;
            final docId = change.doc.id;

            // Zaten okunmu? bir bildirimi tekrar g?sterme.
            if (data['is_read'] == true) continue;

            final manager = MovieManager.instance;
            if (!manager.areNotificationsEnabled) continue;

            final text = data['text'] ?? data['message'] ?? 'New Notification';
            final type = data['type'] ?? 'general';

            // Halihaz?rda o ki?iyle sohbetteysek, mesaj bildirimini g?sterme.
            if (type == 'message') {
              final senderId = data['sender_id'];
              if (senderId != null &&
                  senderId == manager.currentChatPartnerId) {
                SocialService.instance.markNotificationAsRead(docId);
                continue;
              }
            }

            if (mounted) {
              _showInAppNotification(text, type, docId, data);
            }
          }
        });
  }

  void _showInAppNotification(
    String text,
    String type,
    String docId,
    Map<String, dynamic> data,
  ) {
    final isDark = MovieManager.instance.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF1E202B) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        elevation: 10,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.5), // D?ZELTME
            width: 1.5,
          ),
        ),
        content: Row(
          children: [
            Icon(_getIconForType(type), color: AppTheme.primaryBlue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'SHOW',
          textColor: AppTheme.primaryBlue,
          onPressed: () {
            SocialService.instance.markNotificationAsRead(docId);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _handleNavigation(type, data);
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'friend_request':
        return Icons.person_add;
      case 'message':
        return Icons.mail;
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      default:
        return Icons.notifications;
    }
  }

  void _handleNavigation(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'friend_request':
        context.push(AppRouters.friends);
        break;
      case 'message':
        final senderId = data['sender_id'];
        if (senderId != null) {
          context.push(
            AppRouters.chat,
            extra: {
              'targetUid': senderId,
              'targetEmail': data['sender_email'] ?? '',
            },
          );
        } else {
          context.push(AppRouters.friends);
        }
        break;
      default:
        context.push(AppRouters.notifications);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MovieManager.instance,
      builder: (context, child) {
        return Scaffold(
          body: widget.navigationShell,
          bottomNavigationBar: NavigationBar(
            backgroundColor: AppTheme.backgroundBlack,
            indicatorColor: AppTheme.primaryBlue.withOpacity(0.2), // D?ZELTME
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) {
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              );
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppTheme.primaryBlue),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category, color: AppTheme.primaryBlue),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite, color: AppTheme.primaryBlue),
                label: 'Favorites',
              ),
              NavigationDestination(
                icon: const Icon(Icons.recommend_outlined),
                selectedIcon: Icon(
                  Icons.recommend,
                  color: AppTheme.primaryBlue,
                ),
                label: 'For You',
              ),
            ],
          ),
        );
      },
    );
  }
}
