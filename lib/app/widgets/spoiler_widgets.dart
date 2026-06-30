// Dosya: lib/app/widgets/spoiler_widgets.dart
//
// Spoiler (sürpriz bozan) icerikleri isaretlemek ve gostermek icin ortak
// widget'lar. Tum yorum ve mesajlasma ekranlarinda tutarli sekilde kullanilir.
//
//  - [SpoilerToggle]  : Yazi yazarken "Spoiler iceriyor" anahtari.
//  - [SpoilerText]    : Spoiler isaretli metni once gizler, dokununca acar.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinemood/app/theme.dart';

/// Bir mesaj/yorum gonderilirken kullanilan "Spoiler iceriyor" anahtari.
/// Mevcut deger [value], degisiklik [onChanged] ile bildirilir.
class SpoilerToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SpoilerToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = AppTheme.accentPink;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: value
              ? active.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? active
                : AppTheme.textColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.visibility_off : Icons.visibility_off_outlined,
              size: 16,
              color: value ? active : AppTheme.textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              "Spoiler",
              style: TextStyle(
                color:
                    value ? active : AppTheme.textColor.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: value ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spoiler isaretli bir metni gosterir. Baslangicta metin bulaniklastirilir
/// ve "Spoiler — gostermek icin dokun" uyarisi gosterilir. Kullanici dokununca
/// metin acilir. [isSpoiler] false ise metin oldugu gibi gosterilir.
class SpoilerText extends StatefulWidget {
  final String text;
  final bool isSpoiler;
  final TextStyle? style;

  const SpoilerText({
    super.key,
    required this.text,
    required this.isSpoiler,
    this.style,
  });

  @override
  State<SpoilerText> createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<SpoilerText> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(widget.text, style: widget.style);

    if (!widget.isSpoiler) {
      return textWidget;
    }

    // Spoiler acikken metni goster; tekrar dokununca yeniden gizle.
    if (_revealed) {
      return GestureDetector(
        onTap: () => setState(() => _revealed = false),
        child: textWidget,
      );
    }

    // Gizli durum: dokununca ac.
    return GestureDetector(
      onTap: () => setState(() => _revealed = true),
      child: _buildHidden(textWidget),
    );
  }

  Widget _buildHidden(Widget textWidget) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          // Bulaniklastirilmis arka plandaki gercek metin (okunmaz).
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Opacity(opacity: 0.6, child: textWidget),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.accentPink.withValues(alpha: 0.10),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 15,
                    color: AppTheme.accentPink,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Spoiler — tap to reveal",
                      style: TextStyle(
                        color: AppTheme.accentPink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
