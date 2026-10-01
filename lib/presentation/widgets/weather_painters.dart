import 'dart:math' as math;
import 'package:flutter/material.dart';

class Drop {
  double x;
  double y;
  double radius;
  double velocity;
  double length;
  double opacity;

  Drop({
    required this.x,
    required this.y,
    required this.radius,
    required this.velocity,
    required this.length,
    this.opacity = 1.0,
  });
}

class RealisticRainPainter extends CustomPainter {
  final double progress;
  final double intensity;
  final List<Drop> _drops = [];
  final math.Random _random = math.Random(123);

  RealisticRainPainter({
    required this.progress,
    required this.intensity,
  }) {
    _initDrops();
  }

  void _initDrops() {
    int count = (200 * intensity).toInt();
    for (int i = 0; i < count; i++) {
      double velocity = 0.5 + _random.nextDouble() * 1.5;
      _drops.add(Drop(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: 0.5 + _random.nextDouble() * 1.5,
        velocity: velocity,
        length: 10 + _random.nextDouble() * 20 * velocity,
        opacity: 0.1 + _random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round;

    for (var drop in _drops) {
      final xPos = drop.x * size.width;
      final yPos = (drop.y * size.height + (progress * size.height * drop.velocity)) % (size.height + drop.length);
      
      paint.strokeWidth = drop.radius;
      
      final rect = Rect.fromLTWH(xPos - drop.radius/2, yPos - drop.length, drop.radius, drop.length);
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(drop.opacity),
        ],
      ).createShader(rect);

      canvas.drawLine(
        Offset(xPos, yPos - drop.length),
        Offset(xPos, yPos),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RealisticRainPainter oldDelegate) => true;
}

class VolumetricCloudPainter extends CustomPainter {
  final double progress;
  final Color cloudColor;
  final int layer;

  VolumetricCloudPainter({
    required this.progress,
    required this.cloudColor,
    required this.layer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(layer * 777);
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    for (int i = 0; i < 4; i++) {
      double speed = 0.02 + (layer * 0.015);
      double x = (random.nextDouble() * size.width + (progress * size.width * speed)) % (size.width + 600) - 300;
      double y = random.nextDouble() * size.height * 0.6 + (layer * 50);
      
      double width = 400 + random.nextDouble() * 300;
      double height = 150 + random.nextDouble() * 150;
      
      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: width,
        height: height,
      );

      paint.shader = RadialGradient(
        colors: [
          cloudColor.withOpacity(0.15 + (layer * 0.05)),
          cloudColor.withOpacity(0.0),
        ],
      ).createShader(rect);

      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(VolumetricCloudPainter oldDelegate) => true;
}

class LightParticlePainter extends CustomPainter {
  final double progress;
  final bool isNight;

  LightParticlePainter({required this.progress, required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    int count = isNight ? 150 : 30;
    for (int i = 0; i < count; i++) {
      final x = (random.nextDouble() * size.width + math.sin(progress * 2 + i) * 20) % size.width;
      final y = (random.nextDouble() * size.height + math.cos(progress * 1.5 + i) * 20) % size.height;
      
      final blink = (math.sin(progress * (random.nextDouble() * 4 + 2) + i) + 1) / 2;
      final radius = random.nextDouble() * (isNight ? 1.5 : 3.0);
      
      if (isNight) {
        paint.color = Colors.white.withOpacity(0.05 + (blink * 0.3));
        canvas.drawCircle(Offset(x, y), radius, paint);
      } else {
        paint.color = Colors.white.withOpacity(0.02 + (blink * 0.1));
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(LightParticlePainter oldDelegate) => true;
}

class CelestialGlowPainter extends CustomPainter {
  final double progress;
  final bool isDay;
  final double intensity;

  CelestialGlowPainter({
    required this.progress,
    required this.isDay,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.75, size.height * 0.2);
    final paint = Paint();
    
    if (isDay) {
      for (int i = 0; i < 3; i++) {
        double radius = 150.0 + (i * 100.0) + math.sin(progress * 2) * 20;
        paint.shader = RadialGradient(
          colors: [
            Colors.cyanAccent.withOpacity((0.15 / (i + 1)) * intensity),
            Colors.cyanAccent.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
        canvas.drawCircle(center, radius, paint);
      }
    } else {
      final moonCenter = Offset(size.width * 0.2, size.height * 0.15);
      paint.shader = RadialGradient(
        colors: [
          Colors.blueGrey.shade100.withOpacity(0.2 * intensity),
          Colors.blueGrey.shade100.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 200));
      canvas.drawCircle(moonCenter, 200, paint);
    }
  }

  @override
  bool shouldRepaint(CelestialGlowPainter oldDelegate) => true;
}

class PremiumSnowPainter extends CustomPainter {
  final double progress;
  final double intensity;
  final int layer;

  PremiumSnowPainter({
    required this.progress,
    required this.intensity,
    required this.layer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(layer * 1234);
    final paint = Paint()..style = PaintingStyle.fill;

    int count = (50 * intensity * (layer + 1)).toInt();
    double speedMult = 0.2 + (layer * 0.2);
    double sizeMult = 1.0 + (layer * 1.5);

    for (int i = 0; i < count; i++) {
      final drift = math.sin(progress * 2 + i) * 40;
      final x = (random.nextDouble() * size.width + drift) % size.width;
      final y = (random.nextDouble() * size.height + (progress * size.height * speedMult)) % size.height;
      
      final radius = (1.5 + random.nextDouble() * 2.5) * sizeMult;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(PremiumSnowPainter oldDelegate) => true;
}

class FogPainter extends CustomPainter {
  final double progress;
  final double opacity;

  FogPainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    
    for (int i = 0; i < 3; i++) {
      double xOffset = math.sin(progress * 0.5 + i) * 100;
      final rect = Rect.fromLTWH(
        -200 + xOffset, 
        size.height * (0.4 + i * 0.2), 
        size.width + 400, 
        size.height * 0.4
      );
      
      paint.color = Colors.white.withOpacity(0.05 * opacity);
      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(FogPainter oldDelegate) => true;
}
