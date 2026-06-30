// Dosya: lib/app/widgets/shimmer_loading.dart
//
// Harici paket gerektirmeyen, temayla uyumlu shimmer (iskelet) yukleme efekti.
// Bir gradient'i yatayda surekli kaydirarak "parlama" hissi verir.

import 'package:flutter/material.dart';
import 'package:cinemood/app/theme.dart';

/// Icine konulan iskelet sekillerin uzerinde kayan bir parlama animasyonu
/// olusturur. Tum alt [Shimmer.box] cocuklari otomatik olarak animasyona dahil
/// olur.
class Shimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const Shimmer({super.key, required this.child, this.enabled = true});

  /// Tek bir iskelet blok (poster, satir, daire vb.). Sadece [Shimmer] icinde
  /// kullanildiginda parlama efektini alir.
  static Widget box({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return _ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
      shape: shape,
    );
  }

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final isDark = AppTheme.backgroundBlack.computeLuminance() < 0.5;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width;
            final slide = (_controller.value * 2 - 1) * dx;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(slide),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Gradient'i yatayda kaydirmak icin kullanilan donusum.
class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const _ShimmerBox({
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Renk shimmer tarafindan ShaderMask ile ezilir; burada opak bir
        // taban yeterli.
        color: Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(8)),
      ),
    );
  }
}
