import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:cinemood/app/theme.dart';

class SavedListEntryTile extends StatelessWidget {
  const SavedListEntryTile({
    super.key,
    required this.entry,
    required this.isPerson,
    required this.isDarkMode,
    required this.onOpen,
    required this.onRemove,
  });

  final Map<String, dynamic> entry;
  final bool isPerson;
  final bool isDarkMode;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  String get _title => entry['title'] ?? entry['name'] ?? 'Unknown';

  String? get _imageUrl => entry['poster_path'] ?? entry['profile_path'];

  String? get _releaseDate => entry['release_date'];

  @override
  Widget build(BuildContext context) {
    final surface = isDarkMode ? AppTheme.surfaceDark : Colors.white;
    final foreground = isDarkMode ? Colors.white : Colors.black;
    final secondary = isDarkMode ? Colors.grey : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: isDarkMode ? Border.all(color: Colors.white10) : null,
        boxShadow: isDarkMode
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: _EntryArtwork(
          imageUrl: _imageUrl,
          isPerson: isPerson,
          isDarkMode: isDarkMode,
        ),
        title: Text(
          _title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: foreground, fontWeight: FontWeight.bold),
        ),
        subtitle: _releaseDate == null
            ? null
            : Text(
                _releaseDate!,
                style: TextStyle(color: secondary, fontSize: 12),
              ),
        trailing: IconButton(
          tooltip: 'Remove from list',
          onPressed: onRemove,
          icon: const Icon(
            Icons.remove_circle_outline,
            color: Colors.redAccent,
          ),
        ),
        onTap: onOpen,
      ),
    );
  }
}

class _EntryArtwork extends StatelessWidget {
  const _EntryArtwork({
    required this.imageUrl,
    required this.isPerson,
    required this.isDarkMode,
  });

  final String? imageUrl;
  final bool isPerson;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl == null
          ? _fallback()
          : CachedNetworkImage(
              imageUrl: imageUrl!,
              width: 50,
              height: 75,
              fit: BoxFit.cover,
              placeholder: (_, _) => ColoredBox(
                color: isDarkMode ? AppTheme.surfaceDark : Colors.grey.shade300,
              ),
              errorWidget: (_, _, _) => const ColoredBox(
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
            ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: Colors.grey,
      child: SizedBox(
        width: 50,
        height: 75,
        child: Icon(isPerson ? Icons.person : Icons.movie, color: Colors.white),
      ),
    );
  }
}
