// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryEntry _$HistoryEntryFromJson(Map<String, dynamic> json) => HistoryEntry(
  id: (json['id'] as num).toInt(),
  videoId: json['video_id'] as String,
  title: json['title'] as String,
  channel: json['channel'] as String,
  thumbnail: json['thumbnail'] as String,
  watchedAt: json['watched_at'] as String,
  progress: (json['progress'] as num?)?.toDouble(),
);

Map<String, dynamic> _$HistoryEntryToJson(HistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'video_id': instance.videoId,
      'title': instance.title,
      'channel': instance.channel,
      'thumbnail': instance.thumbnail,
      'watched_at': instance.watchedAt,
      'progress': instance.progress,
    };
