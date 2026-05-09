import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';

// API Service provider - single source of truth
final apiServiceProvider = Provider((ref) => ApiService());

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

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

// Playback speed provider (1.0 = normal)
final playbackSpeedProvider = StateProvider<double>((ref) => 1.0);

// Video details provider (fetches details for a given video id)
final videoDetailsProvider = FutureProvider.family((ref, String videoId) async {
	final api = ref.watch(apiServiceProvider);
	final details = await api.getVideoDetails(videoId);
	return details;
});
