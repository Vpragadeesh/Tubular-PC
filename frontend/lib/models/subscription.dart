import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
  final int id;
  @JsonKey(name: 'channel_id')
  final String channelId;
  @JsonKey(name: 'channel_name')
  final String channelName;
  @JsonKey(name: 'channel_thumbnail')
  final String channelThumbnail;
  @JsonKey(name: 'subscribed_at')
  final String subscribedAt;

  Subscription({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.channelThumbnail,
    required this.subscribedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}
