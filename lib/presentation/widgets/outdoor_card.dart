import 'package:flutter/material.dart';
import 'glass_card.dart';

class OutdoorCard extends StatelessWidget {
  final String activity;
  final String suggestion;
  final String suggestionIcon;
  final String status;
  final String statusMessage;
  final List<TimelineItem> timeline;
  final String activityIcon;

  const OutdoorCard({
    super.key,
    required this.activity,
    required this.suggestion,
    required this.suggestionIcon,
    required this.status,
    required this.statusMessage,
    required this.timeline,
    required this.activityIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                activity,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                alignment: Alignment.center,
                child: Text(activityIcon, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: timeline.length,
                    itemBuilder: (context, index) {
                      final item = timeline[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.time,
                              style: const TextStyle(color: Colors.white38, fontSize: 9),
                            ),
                            const SizedBox(height: 6),
                            Text(item.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 6),
                            Text(
                              item.status,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$status: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: '$statusMessage • $suggestion $suggestionIcon',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineItem {
  final String time;
  final String emoji;
  final String status;

  TimelineItem({
    required this.time,
    required this.emoji,
    required this.status,
  });
}
