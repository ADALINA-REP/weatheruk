import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/weather_utils.dart';
import 'weather_painters.dart';

class WeatherBackground extends StatefulWidget {
  final int weatherCode;
  final int isDay;
  final double precipitation;
  final int rainProb;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.precipitation,
    required this.rainProb,
    required this.child,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  WeatherState get _state =>
      WeatherUtils.mapWeatherCode(widget.weatherCode, widget.isDay);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, _) {
        final progress = _mainController.value;
        final glowPulse = _glowController.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            _buildSkyGradient(),
            ..._buildWeatherLayers(progress, glowPulse),
            _buildReadabilityScrim(),
            widget.child,
          ],
        );
      },
    );
  }

  Widget _buildSkyGradient() {
    final gradient = WeatherUtils.getBackgroundGradient(
      widget.weatherCode,
      widget.isDay,
      precipitation: widget.precipitation,
      rainProb: widget.rainProb,
    );
    return Container(decoration: BoxDecoration(gradient: gradient));
  }

  List<Widget> _buildWeatherLayers(double progress, double glowPulse) {
    switch (_state) {
      case WeatherState.sunny:
        return [
          Positioned.fill(
            child: CustomPaint(
              painter: CelestialGlowPainter(
                progress: glowPulse,
                isDay: widget.isDay == 1,
                intensity: 1.0,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: LightParticlePainter(
                progress: progress,
                isNight: false,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: VolumetricCloudPainter(
                progress: progress,
                cloudColor: Colors.white,
                layer: 0,
              ),
            ),
          ),
        ];

      case WeatherState.night:
        return [
          Positioned.fill(
            child: CustomPaint(
              painter: CelestialGlowPainter(
                progress: glowPulse,
                isDay: false,
                intensity: 1.0,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: LightParticlePainter(
                progress: progress * 0.5,
                isNight: true,
              ),
            ),
          ),
        ];

      case WeatherState.cloudy:
        return [
          for (int i = 0; i < 3; i++)
            Positioned.fill(
              child: CustomPaint(
                painter: VolumetricCloudPainter(
                  progress: progress,
                  cloudColor: widget.isDay == 1
                      ? Colors.white
                      : Colors.blueGrey.shade200,
                  layer: i,
                ),
              ),
            ),
          Positioned.fill(
            child: CustomPaint(
              painter: CelestialGlowPainter(
                progress: glowPulse,
                isDay: widget.isDay == 1,
                intensity: 0.3,
              ),
            ),
          ),
        ];

      case WeatherState.drizzle:
        return [
          Positioned.fill(
            child: CustomPaint(
              painter: RealisticRainPainter(
                progress: progress,
                intensity: 0.4,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: VolumetricCloudPainter(
                progress: progress * 0.3,
                cloudColor: Colors.blueGrey.shade300,
                layer: 1,
              ),
            ),
          ),
        ];

      case WeatherState.rain:
        return [
          Positioned.fill(
            child: CustomPaint(
              painter: RealisticRainPainter(
                progress: progress,
                intensity: 0.85,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: RealisticRainPainter(
                progress: progress * 0.6 + 0.3,
                intensity: 0.5,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: VolumetricCloudPainter(
                progress: progress * 0.4,
                cloudColor: Colors.blueGrey.shade700,
                layer: 2,
              ),
            ),
          ),
        ];

      case WeatherState.storm:
        return [
          Positioned.fill(
            child: CustomPaint(
              painter: RealisticRainPainter(
                progress: progress,
                intensity: 1.0,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: RealisticRainPainter(
                progress: progress * 0.7 + 0.5,
                intensity: 0.7,
              ),
            ),
          ),
          for (int i = 0; i < 3; i++)
            Positioned.fill(
              child: CustomPaint(
                painter: VolumetricCloudPainter(
                  progress: progress * (0.3 + i * 0.1),
                  cloudColor: Colors.blueGrey.shade900,
                  layer: i,
                ),
              ),
            ),
          _buildLightningFlash(progress),
        ];

      case WeatherState.snow:
        return [
          for (int i = 0; i < 3; i++)
            Positioned.fill(
              child: CustomPaint(
                painter: PremiumSnowPainter(
                  progress: progress,
                  intensity: 0.7,
                  layer: i,
                ),
              ),
            ),
          Positioned.fill(
            child: CustomPaint(
              painter: VolumetricCloudPainter(
                progress: progress * 0.2,
                cloudColor: Colors.white70,
                layer: 0,
              ),
            ),
          ),
        ];

      case WeatherState.fog:
        return [
          for (int i = 0; i < 4; i++)
            Positioned.fill(
              child: CustomPaint(
                painter: FogPainter(
                  progress: progress * (0.3 + i * 0.1),
                  opacity: 1.5 - (i * 0.2),
                ),
              ),
            ),
        ];
    }
  }

  Widget _buildLightningFlash(double progress) {
    final flash = math.max(0.0, math.sin(progress * math.pi * 7) * 0.15);
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(flash.clamp(0.0, 0.12)),
      ),
    );
  }

  Widget _buildReadabilityScrim() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 0.75, 1.0],
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.12),
              Colors.black.withOpacity(0.35),
              Colors.black.withOpacity(0.65),
            ],
          ),
        ),
      ),
    );
  }
}
