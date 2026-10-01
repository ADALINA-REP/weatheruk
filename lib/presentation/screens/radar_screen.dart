import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/api/rainviewer_service.dart';

class RadarScreen extends ConsumerStatefulWidget {
  final double initialLat;
  final double initialLon;

  const RadarScreen({
    super.key,
    this.initialLat = 51.5074,
    this.initialLon = -0.1278,
  });

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  List<RadarFrame> _frames = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _showRadar = true;
  bool _showOpacitySlider = false;
  double _opacity = 0.9;
  Timer? _playbackTimer;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchRadarData();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRadarData() async {
    try {
      final service = RainViewerService();
      final frames = await service.getRadarFrames();
      if (mounted) {
        setState(() {
          _frames = frames;
          if (frames.isNotEmpty) {
            _currentIndex = frames.length - 1;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startPlayback();
      } else {
        _playbackTimer?.cancel();
      }
    });
  }

  void _startPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentIndex >= _frames.length - 1) {
          _currentIndex = 0;
        } else {
          _currentIndex++;
        }
      });
    });
  }

  String _formatTimestamp(int ts) {
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final currentFrame = _frames.isNotEmpty ? _frames[_currentIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0170E3)))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(widget.initialLat, widget.initialLon),
                    initialZoom: 6.0,
                    maxZoom: 18,
                    minZoom: 2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ukweather.liveradar',
                    ),
                    if (currentFrame != null && _showRadar)
                      Opacity(
                        opacity: _opacity,
                        child: TileLayer(
                          urlTemplate: 'https://tilecache.rainviewer.com${currentFrame.path}/256/{z}/{x}/{y}/4/1_1.png',
                        ),
                      ),
                  ],
                ),

          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF151F38).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0170E3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'WEATHERUK RADAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          currentFrame != null ? 'Latest Frame: ${_formatTimestamp(currentFrame.time)}' : 'Loading...',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: 210,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_showOpacitySlider)
                  Container(
                    height: 180,
                    width: 45,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151F38).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF0170E3),
                          inactiveTrackColor: Colors.white10,
                          thumbColor: Colors.white,
                          trackHeight: 4,
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                        ),
                        child: Slider(
                          value: _opacity,
                          onChanged: (val) => setState(() => _opacity = val),
                        ),
                      ),
                    ),
                  ),
                
                Column(
                  children: [
                    _buildCircularButton(
                      Icons.opacity, 
                      () => setState(() => _showOpacitySlider = !_showOpacitySlider),
                      color: _showOpacitySlider ? const Color(0xFF0170E3) : Colors.white,
                    ),
                    const SizedBox(height: 12),
                    _buildCircularButton(Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
                    const SizedBox(height: 12),
                    _buildCircularButton(Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
                    const SizedBox(height: 24),
                    _buildCircularButton(Icons.location_on, () => _mapController.move(LatLng(widget.initialLat, widget.initialLon), 6.0)),
                    const SizedBox(height: 12),
                    _buildCircularButton(
                      _showRadar ? Icons.visibility : Icons.visibility_off, 
                      () => setState(() => _showRadar = !_showRadar),
                      color: _showRadar ? const Color(0xFF0170E3) : Colors.white,
                    ),
                    const SizedBox(height: 12),
                    _buildCircularButton(
                      _isPlaying ? Icons.pause : Icons.play_arrow, 
                      _togglePlayback,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed, {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color == Colors.white ? Colors.white.withOpacity(0.9) : color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color == Colors.white ? Colors.black87 : Colors.white, size: 24),
      ),
    );
  }
}
