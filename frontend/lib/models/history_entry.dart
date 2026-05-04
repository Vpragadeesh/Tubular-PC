import 'package:json_annotation/json_annotation.dart';

part 'history_entry.g.dart';

@JsonSerializable()
class HistoryEntry {
  final int id;
  @JsonKey(name: 'video_id')
  final String videoId;
  final String title;
  final String channel;
  final String thumbnail;
  @JsonKey(name: 'watched_at')
  final String watchedAt;
  final double? progress;

  HistoryEntry({
    required this.id,
    required this.videoId,
    required this.title,
    required this.channel,
    required this.thumbnail,
    required this.watchedAt,
    this.progress,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$HistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryEntryToJson(this);
}
