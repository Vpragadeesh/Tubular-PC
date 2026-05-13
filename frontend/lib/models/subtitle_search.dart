class SubtitleSearchResult {
  final String text;
  final double startTime;
  final double endTime;
  final int lineNumber;

  SubtitleSearchResult({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.lineNumber,
  });

  factory SubtitleSearchResult.fromJson(Map<String, dynamic> json) =>
      SubtitleSearchResult(
        text: json['text']?.toString() ?? '',
        startTime: (json['start_time'] is num)
            ? (json['start_time'] as num).toDouble()
            : double.tryParse(json['start_time']?.toString() ?? '0') ?? 0.0,
        endTime: (json['end_time'] is num)
            ? (json['end_time'] as num).toDouble()
            : double.tryParse(json['end_time']?.toString() ?? '0') ?? 0.0,
        lineNumber: (json['line_number'] is int)
            ? json['line_number'] as int
            : int.tryParse(json['line_number']?.toString() ?? '0') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'start_time': startTime,
        'end_time': endTime,
        'line_number': lineNumber,
      };

  String get formattedTime {
    final minutes = (startTime ~/ 60).toInt();
    final seconds = (startTime % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
