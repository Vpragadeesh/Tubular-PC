import 'package:json_annotation/json_annotation.dart';

part 'dislike.g.dart';

@JsonSerializable()
class DislikeData {
  final String videoId;
  final int likes;
  final int dislikes;
  final double rating;
  final int viewCount;
  final DateTime? retrievedAt;

  DislikeData({
    required this.videoId,
    required this.likes,
    required this.dislikes,
    required this.rating,
    required this.viewCount,
    this.retrievedAt,
  });

  factory DislikeData.fromJson(Map<String, dynamic> json) =>
      _$DislikeDataFromJson(json);
  Map<String, dynamic> toJson() => _$DislikeDataToJson(this);

  int get totalVotes => likes + dislikes;
  double get likePercentage => totalVotes > 0 ? (likes / totalVotes) * 100 : 0;
  double get dislikePercentage => totalVotes > 0 ? (dislikes / totalVotes) * 100 : 0;

  String get formattedLikes {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    }
    return likes.toString();
  }

  String get formattedDislikes {
    if (dislikes >= 1000000) {
      return '${(dislikes / 1000000).toStringAsFixed(1)}M';
    } else if (dislikes >= 1000) {
      return '${(dislikes / 1000).toStringAsFixed(1)}K';
    }
    return dislikes.toString();
  }

  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }
}
