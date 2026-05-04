// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  id: (json['id'] as num).toInt(),
  channelId: json['channel_id'] as String,
  channelName: json['channel_name'] as String,
  channelThumbnail: json['channel_thumbnail'] as String,
  subscribedAt: json['subscribed_at'] as String,
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channel_id': instance.channelId,
      'channel_name': instance.channelName,
      'channel_thumbnail': instance.channelThumbnail,
      'subscribed_at': instance.subscribedAt,
    };
