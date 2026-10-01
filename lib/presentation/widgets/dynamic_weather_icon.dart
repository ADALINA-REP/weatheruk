import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/weather_utils.dart';

class DynamicWeatherIcon extends StatefulWidget {
  final int code;
  final int isDay;
  final double size;
  final double? precipitation;

  const DynamicWeatherIcon({
    super.key,
    required this.code,
    required this.isDay,
    this.size = 64,
    this.precipitation,
  });

  @override
  State<DynamicWeatherIcon> createState() => _DynamicWeatherIconState();
}

class _DynamicWeatherIconState extends State<DynamicWeatherIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isFog =>
      widget.code == 45 || widget.code == 48;

  bool get _isSnow =>
      [71, 73, 75, 77, 85, 86].contains(widget.code);

  bool get _isStorm =>
      [95, 96, 99].contains(widget.code);

  @override
  Widget build(BuildContext context) {
    final info = WeatherUtils.getWeatherInfo(widget.code, widget.isDay);

    int dropCount = 0;
    if (widget.precipitation != null && widget.precipitation! > 0) {
      if (widget.precipitation! < 0.5) {
        dropCount = 1;
      } else if (widget.precipitation! < 2.0) {
        dropCount = 3;
      } else {
        dropCount = 5;
      }
    } else {
      switch (widget.code) {
        case 51: case 56: case 61: case 80: dropCount = 1; break;
        case 53: case 63: case 81:           dropCount = 3; break;
        case 55: case 65: case 82: case 95: case 96: case 99: dropCount = 5; break;
      }
    }

    if (_isFog) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _FogIconPainter(
              progress: _controller.value,
              isDay: widget.isDay == 1,
            ),
          ),
        ),
      );
    }

    if (_isSnow) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _SnowIconPainter(progress: _controller.value),
          ),
        ),
      );
    }

    if (_isStorm) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _StormIconPainter(progress: _controller.value),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          info.iconEmoji,
          style: TextStyle(fontSize: widget.size),
        ),
        if (dropCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              dropCount,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  Icons.water_drop,
                  size: widget.size * 0.2,
                  color: Colors.blueAccent.withOpacity(0.8),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FogIconPainter extends CustomPainter {
  final double progress;
  final bool isDay;

  _FogIconPainter({required this.progress, required this.isDay});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    glowPaint.shader = RadialGradient(
      colors: isDay
          ? [Colors.amber.withOpacity(0.7), Colors.amber.withOpacity(0.0)]
          : [Colors.blueGrey.shade200.withOpacity(0.5), Colors.transparent],
    ).createShader(Rect.fromCircle(
      center: Offset(cx * 1.4, cy * 0.6),
      radius: size.width * 0.35,
    ));
    canvas.drawCircle(
      Offset(cx * 1.4, cy * 0.6),
      size.width * 0.25,
      glowPaint,
    );

    final fogPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bands = [
      {'y': 0.35, 'width': 0.85, 'speed': 1.0, 'opacity': 0.75, 'stroke': 3.0},
      {'y': 0.52, 'width': 0.65, 'speed': -0.7, 'opacity': 0.55, 'stroke': 2.5},
      {'y': 0.68, 'width': 0.80, 'speed': 0.5, 'opacity': 0.65, 'stroke': 2.0},
      {'y': 0.84, 'width': 0.50, 'speed': -0.9, 'opacity': 0.40, 'stroke': 1.5},
    ];

    for (final band in bands) {
      final yFrac = band['y'] as double;
      final wFrac = band['width'] as double;
      final speed = band['speed'] as double;
      final opacity = band['opacity'] as double;
      final stroke = band['stroke'] as double;

      final offset = math.sin(progress * math.pi * 2 * speed) * size.width * 0.06;
      final y = size.height * yFrac;
      final halfW = size.width * wFrac / 2;

      fogPaint.strokeWidth = stroke;
      fogPaint.shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.2, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(cx - halfW + offset, y - 2, halfW * 2, 4));

      canvas.drawLine(
        Offset(cx - halfW + offset, y),
        Offset(cx + halfW + offset, y),
        fogPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_FogIconPainter old) => old.progress != progress;
}

class _SnowIconPainter extends CustomPainter {
  final double progress;
  _SnowIconPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;
    final angle = progress * math.pi * 2;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(cx, cy), r * 0.9, glowPaint);

    for (int i = 0; i < 6; i++) {
      final a = angle + (i * math.pi / 3);
      final x1 = cx + math.cos(a) * r;
      final y1 = cy + math.sin(a) * r;
      canvas.drawLine(Offset(cx, cy), Offset(x1, y1), paint);

      for (final frac in [0.5, 0.75]) {
        final bx = cx + math.cos(a) * r * frac;
        final by = cy + math.sin(a) * r * frac;
        for (final side in [-1, 1]) {
          final ba = a + side * math.pi / 4;
          canvas.drawLine(
            Offset(bx, by),
            Offset(bx + math.cos(ba) * r * 0.2, by + math.sin(ba) * r * 0.2),
            paint,
          );
        }
      }
    }

    canvas.drawCircle(
      Offset(cx, cy),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_SnowIconPainter old) => old.progress != progress;
}

class _StormIconPainter extends CustomPainter {
  final double progress;
  _StormIconPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final pulse = (math.sin(progress * math.pi * 4) + 1) / 2;

    final cloudPaint = Paint()
      ..color = Colors.blueGrey.shade700.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy * 0.55), width: size.width * 0.85, height: size.height * 0.38),
      cloudPaint,
    );

    final boltPath = Path();
    final bx = cx;
    boltPath.moveTo(bx + size.width * 0.07, cy * 0.3);
    boltPath.lineTo(bx - size.width * 0.08, cy * 0.9);
    boltPath.lineTo(bx + size.width * 0.05, cy * 0.85);
    boltPath.lineTo(bx - size.width * 0.07, cy * 1.55);
    boltPath.lineTo(bx + size.width * 0.12, cy * 0.95);
    boltPath.lineTo(bx + size.width * 0.00, cy * 1.0);
    boltPath.close();

    canvas.drawPath(
      boltPath,
      Paint()
        ..color = Colors.yellowAccent.withOpacity(0.3 + pulse * 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + pulse * 6),
    );
    canvas.drawPath(
      boltPath,
      Paint()..color = Colors.yellow.shade300,
    );
    canvas.drawPath(
      boltPath,
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_StormIconPainter old) => old.progress != progress;
}
