import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';
import 'models/notification.dart' as notification_model;
import 'models/subtitle_search.dart' as subtitle_search_model;
import 'models/video.dart';

// Player view modes
enum PlayerViewMode {
  normal,      // Standard view with video and info side-by-side
  theater,     // Enlarged video with info below
  fullscreen,  // Video fills entire screen
}

// Multi-window layout modes
enum MultiPlayerLayout {
  single,              // Single player (default)
  splitHorizontal,     // 2 players side-by-side
  splitVertical,       // 2 players stacked
  grid2x2,             // 4 players in 2x2 grid
}

// Preset theme definitions
enum PresetTheme {
  dark('Dark', Colors.red),
  light('Light', Colors.red),
  amoled('AMOLED', Colors.red),
  ocean('Ocean', Color(0xFF0077BE)),
  forest('Forest', Color(0xFF2D5016)),
  sunset('Sunset', Color(0xFFFF6B35)),
  monochrome('Monochrome', Colors.grey),
  neon('Neon', Color(0xFF00FF41));

  final String label;
  final Color accentColor;
  const PresetTheme(this.label, this.accentColor);
}

class CustomTheme {
  final PresetTheme preset;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;
  final bool isAmoled;

  CustomTheme({
    required this.preset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
    required this.isAmoled,
  });

  CustomTheme copyWith({
    PresetTheme? preset,
    Color? primaryColor,
    Color? secondaryColor,
    bool? isDark,
    bool? isAmoled,
  }) {
    return CustomTheme(
      preset: preset ?? this.preset,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      isDark: isDark ?? this.isDark,
      isAmoled: isAmoled ?? this.isAmoled,
    );
  }
}

// API Service provider - single source of truth
final apiServiceProvider = Provider((ref) => ApiService());

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// Custom theme provider
final customThemeProvider = StateProvider<CustomTheme>((ref) {
  return CustomTheme(
    preset: PresetTheme.dark,
    primaryColor: Colors.red,
    secondaryColor: const Color(0xFFB71C1C),
    isDark: true,
    isAmoled: true,
  );
});

// Quality preference provider
final preferredQualityProvider = StateProvider<String>((ref) => '720p');

// Format preference provider (video, audio, both)
final preferredFormatProvider = StateProvider<String>((ref) => 'video');

// Audio-only mode provider
final audioOnlyModeProvider = StateProvider<bool>((ref) => false);

// Auto-play provider
final autoPlayProvider = StateProvider<bool>((ref) => true);

// Download folder provider
final downloadFolderProvider = StateProvider<String>((ref) => '~/Downloads/Tubular');

// Subtitle font size provider
final subtitleFontSizeProvider = StateProvider<double>((ref) => 14.0);

// Additional settings
final enableSponsorBlockProvider = StateProvider<bool>((ref) => true);
final enableDislikeCountsProvider = StateProvider<bool>((ref) => true);
final enableSubtitlesProvider = StateProvider<bool>((ref) => true);
final enableNotificationsProvider = StateProvider<bool>((ref) => false);

// Privacy settings providers
final saveWatchHistoryProvider = StateProvider<bool>((ref) => true);
final saveSearchHistoryProvider = StateProvider<bool>((ref) => true);
final trackUsageProvider = StateProvider<bool>((ref) => false);
final sendCrashReportsProvider = StateProvider<bool>((ref) => true);

// Download settings providers
final autoDownloadQualityProvider = StateProvider<String>((ref) => 'best');
final resumeIncompleteDownloadsProvider = StateProvider<bool>((ref) => true);
final deleteSourceAfterDownloadProvider = StateProvider<bool>((ref) => false);

// Playback speed provider (1.0 = normal)
final playbackSpeedProvider = StateProvider<double>((ref) => 1.0);

// Picture-in-Picture mode providers
final pipEnabledProvider = StateProvider<bool>((ref) => false);
final pipWindowPositionProvider = StateProvider<Offset>((ref) => const Offset(100, 100));
final pipWindowSizeProvider = StateProvider<Size>((ref) => const Size(400, 225)); // 16:9 aspect ratio

// Player view mode provider (normal, theater, fullscreen)
final playerViewModeProvider = StateProvider<PlayerViewMode>((ref) => PlayerViewMode.normal);

// Video details provider (fetches details for a given video id)
final videoDetailsProvider = FutureProvider.family((ref, String videoId) async {
	final api = ref.watch(apiServiceProvider);
	final details = await api.getVideoDetails(videoId);
	return details;
});

// Bookmarks providers
final bookmarksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.getBookmarks();
	return (result.data as List<Map<String, dynamic>>?) ?? [];
});

final isBookmarkedProvider = FutureProvider.family((ref, String videoId) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.isBookmarked(videoId);
	return result.data ?? false;
});

// Subscription feed provider
final subscriptionFeedProvider = FutureProvider<List<Video>>((ref) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.getSubscriptionFeed();
	return (result.data as List<Video>?) ?? [];
});

// Trending videos provider
final trendingVideosProvider = FutureProvider<List<Video>>((ref) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.getTrendingVideos();
	return (result.data as List<Video>?) ?? [];
});

// Recommended videos provider (family-based, takes videoId parameter)
final recommendedVideosProvider = FutureProvider.family<List<Video>, String>((ref, videoId) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.getRecommendedVideos(videoId: videoId);
	return (result.data as List<Video>?) ?? [];
});

// Search filter providers
final searchSortProvider = StateProvider<String>((ref) => 'relevance');
final searchDurationProvider = StateProvider<String>((ref) => 'any');
final searchUploadDateProvider = StateProvider<String>((ref) => 'any');

// Playlist provider (family-based, takes playlistId parameter)
final playlistProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, playlistId) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.getPlaylist(playlistId: playlistId);
	return result.data ?? {};
});

// Transcripts/Subtitles provider (family-based, takes videoId parameter)
final transcriptsProvider = FutureProvider.family((ref, String videoId) async {
	final details = await ref.watch(videoDetailsProvider(videoId).future);
	return details.subtitles;
});

// Notifications provider
final notificationsProvider = FutureProvider((ref) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.getNotifications(unreadOnly: false);
	return result.data ?? [];
});

// Unread notifications provider
final unreadNotificationsProvider = FutureProvider((ref) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.getNotifications(unreadOnly: true);
	return result.data ?? [];
});

// Unread notification count provider
final unreadNotificationCountProvider = FutureProvider((ref) async {
	final api = ref.watch(apiServiceProvider);
	final result = await api.getUnreadNotificationCount();
	return result.data ?? 0;
});

// Subtitle search provider (family-based, takes videoId and query)
final subtitleSearchProvider = FutureProvider.family<List<subtitle_search_model.SubtitleSearchResult>, (String, String)>((ref, params) async {
	final (videoId, query) = params;
	if (query.isEmpty) {
		return [];
	}
	final api = ref.watch(apiServiceProvider);
	final result = await api.searchSubtitles(videoId, query);
	return result.data ?? [];
});

// ========== MULTI-WINDOW PLAYBACK PROVIDERS ==========

// Multi-player layout mode
final multiPlayerLayoutProvider = StateProvider<MultiPlayerLayout>((ref) => MultiPlayerLayout.single);

// Active player windows (list of video IDs being played)
final activePlayersProvider = StateProvider<List<String>>((ref) => []);

// Focused player ID (which window is currently active)
final focusedPlayerProvider = StateProvider<String?>((ref) => null);

// Player instance state - per-window playback info
class PlayerInstanceState {
	final String videoId;
	final String quality;
	final double speed;
	final double position;
	final bool subtitlesEnabled;
	final String subtitleLanguage;

	PlayerInstanceState({
		required this.videoId,
		this.quality = '720p',
		this.speed = 1.0,
		this.position = 0.0,
		this.subtitlesEnabled = true,
		this.subtitleLanguage = 'en',
	});

	PlayerInstanceState copyWith({
		String? videoId,
		String? quality,
		double? speed,
		double? position,
		bool? subtitlesEnabled,
		String? subtitleLanguage,
	}) {
		return PlayerInstanceState(
			videoId: videoId ?? this.videoId,
			quality: quality ?? this.quality,
			speed: speed ?? this.speed,
			position: position ?? this.position,
			subtitlesEnabled: subtitlesEnabled ?? this.subtitlesEnabled,
			subtitleLanguage: subtitleLanguage ?? this.subtitleLanguage,
		);
	}
}

// Per-player state map (videoId -> PlayerInstanceState)
final playerInstancesProvider = StateProvider<Map<String, PlayerInstanceState>>((ref) => {});

// ========== BATCH DOWNLOAD PROVIDERS ==========

// Batch download task model
class BatchDownloadTask {
	final String videoId;
	final String title;
	final String quality;
	final String format;
	final bool downloading;
	final double progress; // 0.0 to 1.0
	final String? error;
	final bool completed;

	BatchDownloadTask({
		required this.videoId,
		required this.title,
		this.quality = '720p',
		this.format = 'video',
		this.downloading = false,
		this.progress = 0.0,
		this.error,
		this.completed = false,
	});

	BatchDownloadTask copyWith({
		String? videoId,
		String? title,
		String? quality,
		String? format,
		bool? downloading,
		double? progress,
		String? error,
		bool? completed,
	}) {
		return BatchDownloadTask(
			videoId: videoId ?? this.videoId,
			title: title ?? this.title,
			quality: quality ?? this.quality,
			format: format ?? this.format,
			downloading: downloading ?? this.downloading,
			progress: progress ?? this.progress,
			error: error ?? this.error,
			completed: completed ?? this.completed,
		);
	}
}

// Batch download queue (list of tasks)
final batchDownloadQueueProvider = StateProvider<List<BatchDownloadTask>>((ref) => []);

// Selected videos for batch operation (video IDs)
final selectedVideosProvider = StateProvider<List<String>>((ref) => []);

// Batch download in progress flag
final batchDownloadingProvider = StateProvider<bool>((ref) => false);
