import 'package:json_annotation/json_annotation.dart';

part 'download.g.dart';

@JsonSerializable()
class Download {
  final String id;
  final String videoId;
  final String title;
  final String filePath;
  final int fileSize;
  final String format; // 'video', 'audio', 'both'
  final String quality; // '360p', '720p', '1080p'
  final String status; // 'pending', 'downloading', 'completed', 'failed', 'paused'
  final double progress; // 0-100
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  Download({
    required this.id,
    required this.videoId,
    required this.title,
    required this.filePath,
    required this.fileSize,
    required this.format,
    required this.quality,
    required this.status,
    required this.progress,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  factory Download.fromJson(Map<String, dynamic> json) => _$DownloadFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadToJson(this);

  bool get isDownloading => status == 'downloading';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPaused => status == 'paused';
  
  String get progressText => '${progress.toStringAsFixed(1)}%';
  
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'downloading':
        return 'Downloading';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'paused':
        return 'Paused';
      default:
        return 'Unknown';
    }
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
