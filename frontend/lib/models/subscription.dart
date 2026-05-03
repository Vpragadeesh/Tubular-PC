import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
  final String id;
  final String channelId;
  final String channelName;
  final String thumbnail;

  Subscription({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.thumbnail,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}
