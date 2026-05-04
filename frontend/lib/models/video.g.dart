// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
  id: json['id'] as String,
  title: json['title'] as String,
  channelName: json['channel'] as String? ?? 'Unknown',
  channelId: json['channel_id'] as String? ?? '',
  thumbnail: json['thumbnail'] as String? ?? '',
  duration: Video._durationFromJson(json['duration']),
  views: (json['view_count'] as num?)?.toInt() ?? 0,
  uploadDate: Video._dateFromJson(json['upload_date']),
  description: json['description'] as String? ?? '',
  likes: (json['like_count'] as num?)?.toInt() ?? 0,
  dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'channel': instance.channelName,
  'channel_id': instance.channelId,
  'thumbnail': instance.thumbnail,
  'duration': Video._durationToJson(instance.duration),
  'view_count': instance.views,
  'upload_date': Video._dateToJson(instance.uploadDate),
  'description': instance.description,
  'like_count': instance.likes,
  'dislikes': instance.dislikes,
};
