import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_service.dart';
import '../providers/settings_provider.dart';

class SolarArcWidget extends ConsumerWidget {
  final String sunrise;
  final String sunset;
  final String currentTime;

  const SolarArcWidget({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider).languageCode;
    
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomPaint(
        painter: SolarArcPainter(
          sunrise: _parseTime(sunrise),
          sunset: _parseTime(sunset),
          now: _parseTime(currentTime),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildTimeLabel(LocalizationService.translate('sunrise', lang), sunrise, CrossAxisAlignment.start),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildTimeLabel(LocalizationService.translate('sunset', lang), sunset, CrossAxisAlignment.end),
            ),
          ],
        ),
      ),
    );
  }

  double _parseTime(String timeStr) {
    try {
      final parts = timeStr.split('T')[1].split(':');
      return double.parse(parts[0]) + double.parse(parts[1]) / 60.0;
    } catch (e) {
      return 12.0;
    }
  }

  Widget _buildTimeLabel(String label, String time, CrossAxisAlignment alignment) {
    final displayTime = time.contains('T') ? time.split('T')[1].substring(0, 5) : time;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(displayTime, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class SolarArcPainter extends CustomPainter {
  final double sunrise;
  final double sunset;
  final double now;

  SolarArcPainter({
    required this.sunrise,
    required this.sunset,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 60);
    final radius = min(size.width * 0.48, size.height - 80);
    
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(center.dx - radius - 20, center.dy),
      Offset(center.dx + radius + 20, center.dy),
      paint,
    );

    final arcPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, pi, pi, false, arcPaint);

    double progress = 0;
    if (now >= sunrise && now <= sunset) {
      progress = (now - sunrise) / (sunset - sunrise);
    } else if (now > sunset) {
      progress = 1.0;
    }

    final angle = pi + (progress * pi);
    final sunPos = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    final glowPaint = Paint()
      ..color = Colors.amber.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(sunPos, 12, glowPaint);

    final sunPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunPos, 6, sunPaint);

    if (progress > 0) {
      final activePaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.amber.withOpacity(0.0), Colors.amber.withOpacity(0.5)],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(rect, pi, progress * pi, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(SolarArcPainter oldDelegate) => true;
}
