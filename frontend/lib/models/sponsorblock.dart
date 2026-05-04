import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sponsorblock.g.dart';

@JsonSerializable()
class SponsorBlockSegment {
  final String category; // 'sponsor', 'intro', 'outro', 'interlude', 'break'
  final double startTime; // seconds
  final double endTime; // seconds
  final int votes;
  final bool isVoted;

  SponsorBlockSegment({
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.votes,
    this.isVoted = false,
  });

  factory SponsorBlockSegment.fromJson(Map<String, dynamic> json) =>
      _$SponsorBlockSegmentFromJson(json);
  Map<String, dynamic> toJson() => _$SponsorBlockSegmentToJson(this);

  String get categoryLabel {
    switch (category) {
      case 'sponsor':
        return 'Sponsor';
      case 'intro':
        return 'Intro';
      case 'outro':
        return 'Outro';
      case 'interlude':
        return 'Interlude';
      case 'break':
        return 'Break';
      default:
        return category;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'sponsor':
        return Color(0xFF00D400);
      case 'intro':
        return Color(0xFF00FFFF);
      case 'outro':
        return Color(0xFF0071DB);
      case 'interlude':
        return Color(0xFFFF9000);
      case 'break':
        return Color(0xFF4B4498);
      default:
        return Color(0xFF999999);
    }
  }

  String get durationText {
    final duration = (endTime - startTime).toInt();
    return '${duration}s';
  }

  Duration get startDuration => Duration(milliseconds: (startTime * 1000).toInt());
  Duration get endDuration => Duration(milliseconds: (endTime * 1000).toInt());
}
