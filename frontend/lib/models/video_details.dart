class Comment {
  Comment({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
    required this.publishedText,
    required this.likeCount,
  });

  final String userId;
  final String username;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;
  final String publishedText;
  final int likeCount;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        userId: json['user_id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
        publishedText: json['published_text']?.toString() ?? '',
        likeCount: (json['like_count'] is int) ? json['like_count'] as int : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': username,
        'avatar_url': avatarUrl,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'published_text': publishedText,
        'like_count': likeCount,
      };
}

class VideoDetails {
  VideoDetails({
    required this.id,
    required this.title,
    required this.channelName,
    required this.channelId,
    required this.subscriberCount,
    required this.viewCount,
    required this.uploadDate,
    required this.duration,
    required this.thumbnailUrl,
    required this.likeCount,
    required this.dislikeCount,
    required this.comments,
  });

  final String id;
  final String title;
  final String channelName;
  final String channelId;
  final int subscriberCount;
  final int viewCount;
  final String uploadDate;
  final Duration duration;
  final String thumbnailUrl;
  final int likeCount;
  final int dislikeCount;
  final List<Comment> comments;

  factory VideoDetails.fromJson(Map<String, dynamic> json) => VideoDetails(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        channelName: json['channel_name']?.toString() ?? '',
        channelId: json['channel_id']?.toString() ?? '',
        subscriberCount: (json['subscriber_count'] is int) ? json['subscriber_count'] as int : int.tryParse(json['subscriber_count']?.toString() ?? '0') ?? 0,
        viewCount: (json['view_count'] is int) ? json['view_count'] as int : int.tryParse(json['view_count']?.toString() ?? '0') ?? 0,
        uploadDate: json['upload_date']?.toString() ?? '',
        duration: Duration(milliseconds: ((json['duration_seconds'] is num) ? ((json['duration_seconds'] as num).toDouble() * 1000).round() : ((double.tryParse(json['duration_seconds']?.toString() ?? '0') ?? 0) * 1000).round())),
        thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
        likeCount: (json['like_count'] is int) ? json['like_count'] as int : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
        dislikeCount: (json['dislike_count'] is int) ? json['dislike_count'] as int : int.tryParse(json['dislike_count']?.toString() ?? '0') ?? 0,
        comments: (json['comments'] is List) ? List<Map<String, dynamic>>.from(json['comments']).map((c) => Comment.fromJson(Map<String, dynamic>.from(c))).toList() : <Comment>[],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'channel_name': channelName,
        'channel_id': channelId,
        'subscriber_count': subscriberCount,
        'view_count': viewCount,
        'upload_date': uploadDate,
        'duration_seconds': duration.inMilliseconds / 1000,
        'thumbnail_url': thumbnailUrl,
        'like_count': likeCount,
        'dislike_count': dislikeCount,
        'comments': comments.map((c) => c.toJson()).toList(),
      };
}
