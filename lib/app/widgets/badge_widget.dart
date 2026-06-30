// Dosya: lib/app/widgets/badge_widget.dart
//
// Tek bir basari rozetini gosteren widget. Acik rozetler renkli ve parlar;
// kilitli rozetler soluk gosterilir ve ilerleme cubugu ile hedefi belirtir.
// Dokununca ad/aciklama icin bir alt sayfa acar.

import 'package:flutter/material.dart';
import 'package:cinemood/app/theme.dart';
import 'package:cinemood/data/badge_service.dart';

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
              if (unlocked)
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
                )
              else ...[
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
}
