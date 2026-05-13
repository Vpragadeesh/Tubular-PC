class Notification {
  final int id;
  final String videoId;
  final String channelId;
  final String title;
  final String channelName;
  final String thumbnail;
  final bool isRead;
  final String createdAt;

  Notification({
    required this.id,
    required this.videoId,
    required this.channelId,
    required this.title,
    required this.channelName,
    required this.thumbnail,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        videoId: json['video_id']?.toString() ?? '',
        channelId: json['channel_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        channelName: json['channel_name']?.toString() ?? '',
        thumbnail: json['thumbnail']?.toString() ?? '',
        isRead: (json['is_read'] is bool) ? json['is_read'] as bool : (json['is_read'] == 1 || json['is_read'] == true),
        createdAt: json['created_at']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'video_id': videoId,
        'channel_id': channelId,
        'title': title,
        'channel_name': channelName,
        'thumbnail': thumbnail,
        'is_read': isRead,
        'created_at': createdAt,
      };
}
