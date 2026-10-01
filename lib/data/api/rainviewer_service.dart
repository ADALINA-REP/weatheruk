import 'dart:convert';
import 'package:http/http.dart' as http;

class RadarFrame {
  final int time;
  final String path;

  RadarFrame({required this.time, required this.path});
}

class RainViewerService {
  static const String _baseUrl = 'https://api.rainviewer.com/public/weather-maps.json';

  Future<List<RadarFrame>> getRadarFrames() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final radar = data['radar'];
        final List<RadarFrame> frames = [];
        
        if (radar != null) {
          if (radar['past'] != null) {
            for (var item in radar['past']) {
              frames.add(RadarFrame(
                time: item['time'],
                path: item['path'],
              ));
            }
          }
          if (radar['nowcast'] != null) {
            for (var item in radar['nowcast']) {
              frames.add(RadarFrame(
                time: item['time'],
                path: item['path'],
              ));
            }
          }
        }
        return frames;
      }
    } catch (e) {
      print('Error fetching RainViewer frames: $e');
    }
    return [];
  }
}
