import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:cinemood/app/theme.dart';
import 'package:cinemood/services/social_service.dart';

typedef ModerationItemBuilder =
    Widget Function(BuildContext context, QueryDocumentSnapshot document);

class ModerationDashboardView extends StatelessWidget {
  const ModerationDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundBlack,
        appBar: AppBar(
          title: const Text('MODERATOR PANEL'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.comment), text: 'Reviews'),
              Tab(icon: Icon(Icons.group), text: 'Groups'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ReviewsSection(), _GroupsSection(), _UsersSection()],
        ),
      ),
    );
  }
}

class _ModerationCollection extends StatelessWidget {
  const _ModerationCollection({
    required this.stream,
    required this.itemBuilder,
  });

  final Stream<QuerySnapshot> stream;
  final ModerationItemBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) =>
              itemBuilder(context, documents[index]),
        );
      },
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return _ModerationCollection(
      stream: SocialService.instance.getAllReviewsStream(),
      itemBuilder: (context, document) {
        final review = document.data() as Map<String, dynamic>;
        return Card(
          color: AppTheme.surfaceDark,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              "${review['user_name']} - ${review['movie_title']}",
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(review['comment'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => _requestReviewDeletion(context, document.id),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestReviewDeletion(
    BuildContext context,
    String reviewId,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Review?'),
        content: const Text(
          'As a moderator, you are removing this content permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await SocialService.instance.deleteReview(reviewId);
    }
  }
}

class _GroupsSection extends StatelessWidget {
  const _GroupsSection();

  @override
  Widget build(BuildContext context) {
    return _ModerationCollection(
      stream: SocialService.instance.getAllGroupsStream(),
      itemBuilder: (context, document) {
        final group = document.data() as Map<String, dynamic>;
        return ListTile(
          leading: const Icon(Icons.group, color: Colors.blue),
          title: Text(
            group['name'],
            style: TextStyle(color: AppTheme.textColor),
          ),
          subtitle: Text('${(group['members'] as List).length} Members'),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () =>
                SocialService.instance.adminDeleteGroup(document.id),
          ),
        );
      },
    );
  }
}

class _UsersSection extends StatelessWidget {
  const _UsersSection();

  @override
  Widget build(BuildContext context) {
    return _ModerationCollection(
      stream: SocialService.instance.getAllUsersStream(),
      itemBuilder: (context, document) {
        final user = document.data() as Map<String, dynamic>;
        final isBlocked = user['is_blocked'] as bool? ?? false;
        final email = user['email'] as String? ?? 'No Email';
        final role = user['role'] as String? ?? 'user';

        return Card(
          color: AppTheme.surfaceDark,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isBlocked ? Colors.red : AppTheme.primaryBlue,
              child: Icon(
                isBlocked ? Icons.block : Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(email, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              'Rol: $role',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: role == 'admin'
                ? const Icon(Icons.verified_user, color: Colors.amber)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBlocked ? Colors.green : Colors.red,
                    ),
                    onPressed: () => SocialService.instance.adminToggleBlock(
                      document.id,
                      !isBlocked,
                    ),
                    child: Text(isBlocked ? 'ENGELÄ° KALDIR' : 'BLOKLA'),
                  ),
          ),
        );
      },
    );
  }
}
