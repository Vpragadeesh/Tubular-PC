// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sponsorblock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SponsorBlockSegment _$SponsorBlockSegmentFromJson(Map<String, dynamic> json) =>
    SponsorBlockSegment(
      category: json['category'] as String,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      votes: json['votes'] as int,
      isVoted: json['isVoted'] as bool? ?? false,
    );

Map<String, dynamic> _$SponsorBlockSegmentToJson(SponsorBlockSegment instance) =>
    <String, dynamic>{
      'category': instance.category,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'votes': instance.votes,
      'isVoted': instance.isVoted,
    };
