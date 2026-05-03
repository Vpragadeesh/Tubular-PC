// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      channelName: json['channelName'] as String,
      thumbnail: json['thumbnail'] as String,
    );

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'channelName': instance.channelName,
      'thumbnail': instance.thumbnail,
    };
