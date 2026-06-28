import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
/// A customizable circular loader widget with sensible defaults.
///
/// Example usage:
/// ```dart
/// AppCircleLoader() // Default primary color loader
/// AppCircleLoader(size: 32, strokeWidth: 3) // Custom size
/// AppCircleLoader(color: Colors.red) // Custom color
/// ```
class AppCircleLoader extends StatelessWidget {
  const AppCircleLoader({
    super.key,
    this.size,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
    this.value,
    this.strokeAlign,
    this.strokeCap,
    this.semanticsLabel,
    this.semanticsValue,
    this.constraints,
    this.padding,
  });

  /// The diameter of the circular loader.
  /// Defaults to 24.r if not specified.
  final double? size;

  /// The width of the circular stroke.
  /// Defaults to 2.5.r if not specified.
  final double? strokeWidth;

  /// The color of the circular progress indicator.
  /// Defaults to theme primary color if not specified.
  final Color? color;

  /// The background color of the circular track.
  /// Defaults to null (no background track).
  final Color? backgroundColor;

  /// The value of the progress indicator (0.0 to 1.0).
  /// If null, displays an indeterminate spinning animation.
  final double? value;

  /// The alignment of the stroke relative to the center.
  /// Defaults to BorderSide.strokeAlignCenter.
  final double? strokeAlign;

  /// The stroke cap style.
  /// Defaults to StrokeCap.round for smooth edges.
  final StrokeCap? strokeCap;

  /// The semantic label for accessibility.
  final String? semanticsLabel;

  /// The semantic value for accessibility.
  final String? semanticsValue;

  /// Additional constraints for the loader container.
  final BoxConstraints? constraints;

  /// Padding around the loader.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final loaderSize = size ?? 24.r;
    final loaderStrokeWidth = strokeWidth ?? 2.5.r;
    final loaderColor = color ?? Theme.of(context).colorScheme.primary;
    final loaderStrokeCap = strokeCap ?? StrokeCap.round;

    Widget loader = SizedBox(
      width: loaderSize,
      height: loaderSize,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: loaderStrokeWidth,
        color: loaderColor,
        backgroundColor: backgroundColor,
        strokeAlign: strokeAlign ?? BorderSide.strokeAlignCenter,
        strokeCap: loaderStrokeCap,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      ),
    );

    if (padding != null) {
      loader = Padding(padding: padding!, child: loader);
    }

    if (constraints != null) {
      loader = ConstrainedBox(constraints: constraints!, child: loader);
    }

    return loader;
  }
}

/// Convenience constructors for common loader variations
extension AppCircleLoaderVariants on AppCircleLoader {
  /// Creates a small loader (16.r)
  static AppCircleLoader small({Color? color}) =>
      AppCircleLoader(size: 16.r, strokeWidth: 2.r, color: color);

  /// Creates a medium loader (24.r) - default size
  static AppCircleLoader medium({Color? color}) =>
      AppCircleLoader(size: 24.r, strokeWidth: 2.5.r, color: color);

  /// Creates a large loader (32.r)
  static AppCircleLoader large({Color? color}) =>
      AppCircleLoader(size: 32.r, strokeWidth: 3.r, color: color);

  /// Creates an extra large loader (48.r)
  static AppCircleLoader extraLarge({Color? color}) =>
      AppCircleLoader(size: 48.r, strokeWidth: 4.r, color: color);

  /// Creates a white loader (for dark backgrounds)
  static AppCircleLoader white({double? size}) =>
      AppCircleLoader(size: size, color: Colors.white);
}

/// A shimmer loading effect widget for skeleton loading states.
///
/// Example usage:
/// ```dart
/// AppShimmerLoader(width: 100, height: 20) // Rectangle shimmer
/// AppShimmerLoader.circle(size: 48) // Circle shimmer
/// AppShimmerLoader.chip() // Service chip shimmer
/// ```
class AppShimmerLoader extends StatefulWidget {
  const AppShimmerLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.child,
  });

  /// Width of the shimmer container.
  final double? width;

  /// Height of the shimmer container.
  final double? height;

  /// Border radius for the shimmer container.
  final BorderRadius? borderRadius;

  /// Base color of the shimmer (the darker color).
  final Color? baseColor;

  /// Highlight color of the shimmer (the lighter swept color).
  final Color? highlightColor;

  /// Optional child widget to wrap with shimmer effect.
  final Widget? child;

  /// Creates a circular shimmer loader.
  static Widget circle({
    double? size,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final circleSize = size ?? 48.r;
    return AppShimmerLoader(
      width: circleSize,
      height: circleSize,
      borderRadius: BorderRadius.circular(circleSize / 2),
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Creates a service chip shimmer loader.
  static Widget chip({Color? baseColor, Color? highlightColor}) {
    return AppShimmerLoader(
      width: 100,
      height: 36,
      borderRadius: BorderRadius.circular(12.r), // MD radius
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Creates a text line shimmer loader.
  static Widget textLine({
    double? width,
    double? height,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return AppShimmerLoader(
      width: width ?? 120,
      height: height ?? 16,
      borderRadius: BorderRadius.circular(8.r), // SM radius
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Creates a grid of service chip shimmers.
  static Widget serviceGrid({
    int count = 8,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Wrap(
      spacing: 10.r,
      runSpacing: 10.r,
      children: List.generate(
        count,
        (index) => AppShimmerLoader(
          width: (80 + (index % 3) * 30).w,
          height: 40,
          borderRadius: BorderRadius.circular(12.r), // MD radius
          baseColor: baseColor,
          highlightColor: highlightColor,
        ),
      ),
    );
  }

  @override
  State<AppShimmerLoader> createState() => _AppShimmerLoaderState();
}

class _AppShimmerLoaderState extends State<AppShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? const Color(0xFFE5E7EB);
    final highlight = widget.highlightColor ?? const Color(0xFFF3F4F6);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(8.r), // SM radius
            gradient: LinearGradient(
              begin: Alignment(t - 1.2, 0),
              end: Alignment(t + 1.2, 0),
              colors: [base, base, highlight, base, base],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
