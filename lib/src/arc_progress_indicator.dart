import 'dart:math';

import 'package:flutter/material.dart';

/// Draws an [ActionIcon] and [_ArcProgressPainter] that represent an active action.
/// As the provided [Animation] progresses the ActionArc grows into a full
/// circle and the ActionIcon moves along it.
class ArcProgressIndicator extends StatelessWidget {

  ArcProgressIndicator({
    required this.controller,
    required this.radius,
    this.startAngle = 0.0,
    this.width,
    this.color,
    this.icon,
    this.iconColor,
    this.iconSize,
  }) : _progress = Tween(begin: 0.0, end: 1.0).animate(controller);
  
  // required
  final Animation<double> controller;
  final double radius;

  // optional
  final double startAngle;
  final double? width;

  /// The color to use when filling the arc.
  ///
  /// Defaults to the accent color of the current theme.
  final Color? color;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;

  // private
  final Animation<double> _progress;

  @override
  Widget build(BuildContext context) {
    TextPainter? _iconPainter;
    final ThemeData theme = Theme.of(context);
    final Color? _iconColor = iconColor ?? theme.accentIconTheme.color;
    final double? _iconSize = iconSize ?? IconTheme.of(context).size;

    if (icon != null) {
      _iconPainter = TextPainter(
        textDirection: Directionality.of(context),
        text: TextSpan(
          text: String.fromCharCode(icon!.codePoint),
          style: TextStyle(
            inherit: false,
            color: _iconColor,
            fontSize: _iconSize,
            fontFamily: icon!.fontFamily,
            package: icon!.fontPackage,
          ),
        ),
      )..layout();
    }

    return CustomPaint(
      painter: _ArcProgressPainter(
        controller: _progress,
        color: color ?? theme.colorScheme.secondary,
        radius: radius,
        width: width ?? _iconSize! * 2,
        startAngle: startAngle,
        icon: _iconPainter,
      ),
    );
  }
}

class _ArcProgressPainter extends CustomPainter {
  // required
  final Animation<double> controller;
  final Color color;
  final double radius;
  final double width;

  // optional
  final double startAngle;
  final TextPainter? icon;

  _ArcProgressPainter({
    required this.controller,
    required this.color,
    required this.radius,
    required this.width,
    this.startAngle = 0.0,
    this.icon,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double sweepAngle = controller.value * 2 * pi;

    canvas.drawArc(
      Offset.zero & size,
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    if (icon != null) {
      final double angle = startAngle + sweepAngle;
      final Offset offset = Offset(
        (size.width / 2 - icon!.size.width / 2) + radius * cos(angle),
        (size.height / 2 - icon!.size.height / 2) + radius * sin(angle),
      );

      icon!.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(_ArcProgressPainter other) {
    return controller.value != other.controller.value ||
        color != other.color ||
        radius != other.radius ||
        width != other.width ||
        startAngle != other.startAngle ||
        icon != other.icon;
  }
}
