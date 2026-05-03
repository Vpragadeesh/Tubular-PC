// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      id: json['id'] as String,
      title: json['title'] as String,
      channelName: json['channelName'] as String,
      channelId: json['channelId'] as String,
      thumbnail: json['thumbnail'] as String,
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      views: json['views'] as int? ?? 0,
      uploadDate: DateTime.parse(json['uploadDate'] as String? ?? DateTime.now().toIso8601String()),
      description: json['description'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
    );

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'channelName': instance.channelName,
      'channelId': instance.channelId,
      'thumbnail': instance.thumbnail,
      'duration': instance.duration.inSeconds,
      'views': instance.views,
      'uploadDate': instance.uploadDate.toIso8601String(),
      'description': instance.description,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
    };
