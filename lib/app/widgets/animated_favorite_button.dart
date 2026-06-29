// Dosya: lib/app/widgets/animated_favorite_button.dart
//
// Basildiginda kalbin "pop" yaptigi (buyuyup geri donen) ve favoriye
// eklendiginde kisa bir parlama hissi veren favori butonu.

import 'package:flutter/material.dart';
import 'package:cinemood/app/theme.dart';

class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.size = 24,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    // 1.0 -> 1.4 -> 1.0 seklinde bir pop egrisi.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Yalnizca favoriye eklerken pop oynat; cikartirken sade kalsin.
    if (!widget.isFavorite) {
      _controller.forward(from: 0.0);
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _handleTap,
      iconSize: widget.size,
      splashRadius: widget.size,
      icon: ScaleTransition(
        scale: _scale,
        child: Icon(
          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: widget.isFavorite
              ? Colors.red
              : AppTheme.iconColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
