// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dislike.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DislikeData _$DislikeDataFromJson(Map<String, dynamic> json) => DislikeData(
      videoId: json['videoId'] as String,
      likes: json['likes'] as int,
      dislikes: json['dislikes'] as int,
      rating: (json['rating'] as num).toDouble(),
      viewCount: json['viewCount'] as int,
      retrievedAt: json['retrievedAt'] == null
          ? null
          : DateTime.parse(json['retrievedAt'] as String),
    );

Map<String, dynamic> _$DislikeDataToJson(DislikeData instance) =>
    <String, dynamic>{
      'videoId': instance.videoId,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'rating': instance.rating,
      'viewCount': instance.viewCount,
      'retrievedAt': instance.retrievedAt?.toIso8601String(),
    };
