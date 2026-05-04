// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Download _$DownloadFromJson(Map<String, dynamic> json) => Download(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      format: json['format'] as String,
      quality: json['quality'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$DownloadToJson(Download instance) => <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'title': instance.title,
      'filePath': instance.filePath,
      'fileSize': instance.fileSize,
      'format': instance.format,
      'quality': instance.quality,
      'status': instance.status,
      'progress': instance.progress,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };
