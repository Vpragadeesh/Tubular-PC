// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryEntry _$HistoryEntryFromJson(Map<String, dynamic> json) => HistoryEntry(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      channel: json['channel'] as String,
      thumbnail: json['thumbnail'] as String,
      watchedAt: DateTime.parse(json['watchedAt'] as String),
      progress: (json['progress'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HistoryEntryToJson(HistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'title': instance.title,
      'channel': instance.channel,
      'thumbnail': instance.thumbnail,
      'watchedAt': instance.watchedAt.toIso8601String(),
      'progress': instance.progress,
    };
