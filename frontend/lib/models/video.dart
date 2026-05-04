import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

@JsonSerializable()
class Video {
  final String id;
  final String title;

  @JsonKey(name: 'channel', defaultValue: 'Unknown')
  final String channelName;

  @JsonKey(name: 'channel_id', defaultValue: '')
  final String channelId;

  @JsonKey(defaultValue: '')
  final String thumbnail;

  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;

  @JsonKey(name: 'view_count', defaultValue: 0)
  final int views;

  @JsonKey(name: 'upload_date', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime uploadDate;

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(name: 'like_count', defaultValue: 0)
  final int likes;

  @JsonKey(defaultValue: 0)
  final int dislikes;

  Video({
    required this.id,
    required this.title,
    required this.channelName,
    required this.channelId,
    required this.thumbnail,
    required this.duration,
    required this.views,
    required this.uploadDate,
    required this.description,
    required this.likes,
    required this.dislikes,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoToJson(this);

  static Duration _durationFromJson(Object? value) {
    if (value == null) {
      return Duration.zero;
    }

    if (value is num) {
      return Duration(seconds: value.toInt());
    }

    return Duration(seconds: int.tryParse(value.toString()) ?? 0);
  }

  static int _durationToJson(Duration duration) => duration.inSeconds;

  static DateTime _dateFromJson(Object? value) {
    if (value == null) {
      return DateTime.now();
    }

    final rawValue = value.toString();
    if (rawValue.isEmpty) {
      return DateTime.now();
    }

    if (RegExp(r'^\d{8}$').hasMatch(rawValue)) {
      final year = int.parse(rawValue.substring(0, 4));
      final month = int.parse(rawValue.substring(4, 6));
      final day = int.parse(rawValue.substring(6, 8));
      return DateTime(year, month, day);
    }

    return DateTime.tryParse(rawValue) ?? DateTime.now();
  }

  static String _dateToJson(DateTime uploadDate) =>
      uploadDate.toIso8601String();

  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get uploadedAgo {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}
