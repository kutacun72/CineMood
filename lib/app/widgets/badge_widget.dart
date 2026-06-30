// Dosya: lib/app/widgets/badge_widget.dart
//
// Tek bir basari rozetini gosteren widget. Acik rozetler renkli ve parlar;
// kilitli rozetler soluk gosterilir ve ilerleme cubugu ile hedefi belirtir.
// Dokununca ad/aciklama icin bir alt sayfa acar.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemood/app/router.dart';
import 'package:cinemood/app/theme.dart';
import 'package:cinemood/data/badge_service.dart';
import 'package:cinemood/data/movie_manager.dart';

/// Sohbet balonu icinde paylasilan bir rozeti gosteren sik kart.
/// [data] icinde badge_title / badge_desc / badge_icon / badge_color bulunur.
class SharedBadgeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const SharedBadgeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['badge_title'] ?? 'Badge';
    final desc = data['badge_desc'] ?? '';
    final iconData = IconData(
      (data['badge_icon'] as num?)?.toInt() ?? Icons.emoji_events_rounded.codePoint,
      fontFamily: 'MaterialIcons',
    );
    final color = Color((data['badge_color'] as num?)?.toInt() ?? 0xFFFFC107);

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(iconData, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: color, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      "BADGE UNLOCKED",
                      style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (desc.toString().isNotEmpty)
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeTile extends StatelessWidget {
  final BadgeInfo badge;
  const BadgeTile({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.unlocked;
    final color = unlocked ? badge.color : AppTheme.textColor.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? badge.color.withValues(alpha: 0.15)
                  : AppTheme.surfaceDark,
              border: Border.all(color: color, width: 2),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: badge.color.withValues(alpha: 0.35),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              unlocked ? badge.icon : Icons.lock_outline_rounded,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              badge.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: unlocked
                    ? AppTheme.textColor
                    : AppTheme.textColor.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (!unlocked) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: badge.fraction,
                  minHeight: 4,
                  backgroundColor: AppTheme.textColor.withValues(alpha: 0.1),
                  valueColor:
                      AlwaysStoppedAnimation(AppTheme.primaryBlue),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final unlocked = badge.unlocked;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? badge.color.withValues(alpha: 0.15)
                      : AppTheme.backgroundBlack,
                  border: Border.all(
                    color: unlocked
                        ? badge.color
                        : AppTheme.textColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  unlocked ? badge.icon : Icons.lock_outline_rounded,
                  color: unlocked
                      ? badge.color
                      : AppTheme.textColor.withValues(alpha: 0.4),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.title,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              if (unlocked) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Unlocked",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.share, color: Colors.white, size: 18),
                    label: const Text(
                      "Share badge",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showShareSheet(context);
                    },
                  ),
                ),
              ] else ...[
                Text(
                  "${badge.progress} / ${badge.goal}",
                  style: TextStyle(
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: badge.fraction,
                    minHeight: 8,
                    backgroundColor: AppTheme.textColor.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation(AppTheme.primaryBlue),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Rozeti bir arkadasa veya gruba gondermek icin secim sayfasi.
  void _showShareSheet(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final badgeMap = badge.toShareMap();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Share '${badge.title}'",
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: AppTheme.primaryBlue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppTheme.primaryBlue,
                          tabs: const [
                            Tab(text: "Friends"),
                            Tab(text: "Groups"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildFriendsList(ctx, badgeMap),
                              _buildGroupsList(ctx, myUid, badgeMap),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFriendsList(
    BuildContext ctx,
    Map<String, dynamic> badgeMap,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: MovieManager.instance.getFriendsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No friends found.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final friendData = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white10,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                friendData['email'] ?? 'Unknown',
                style: TextStyle(color: AppTheme.textColor),
              ),
              trailing: const Icon(Icons.send, color: Colors.blue),
              onTap: () {
                Navigator.pop(ctx);
                context.push(
                  AppRouters.chat,
                  extra: {
                    'targetUid': docs[index].id,
                    'targetEmail': friendData['email'],
                    'sharedBadge': badgeMap,
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGroupsList(
    BuildContext ctx,
    String? myUid,
    Map<String, dynamic> badgeMap,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: MovieManager.instance.getGroupsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final myGroups = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final members = List<String>.from(data['members'] ?? []);
          return members.contains(myUid);
        }).toList();

        if (myGroups.isEmpty) {
          return const Center(
            child: Text(
              "There are no groups you are a member of.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: myGroups.length,
          itemBuilder: (context, index) {
            final groupDoc = myGroups[index];
            final groupData = groupDoc.data() as Map<String, dynamic>;
            final iconIdx = groupData['group_icon_id'] ?? 0;
            final icons = MovieManager.instance.groupIcons;
            final iconUrl = (iconIdx >= 0 && iconIdx < icons.length)
                ? icons[iconIdx]
                : icons[0];

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(iconUrl),
              ),
              title: Text(
                groupData['name'],
                style: TextStyle(color: AppTheme.textColor),
              ),
              trailing: const Icon(Icons.send, color: Colors.green),
              onTap: () {
                Navigator.pop(ctx);
                context.push(
                  AppRouters.groupChat,
                  extra: {
                    'groupId': groupDoc.id,
                    'groupName': groupData['name'],
                    'isCreator': false,
                    'groupIconUrl': iconUrl,
                    'sharedBadge': badgeMap,
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
