import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

/// Cloud sync state for subscriptions and playlists
class CloudSyncSession {
  final bool isSyncing;
  final DateTime? lastSync;
  final int itemsCount;
  final String status; // 'idle', 'syncing', 'complete', 'error'
  final String? errorMessage;

  CloudSyncSession({
    required this.isSyncing,
    this.lastSync,
    this.itemsCount = 0,
    this.status = 'idle',
    this.errorMessage,
  });

  CloudSyncSession copyWith({
    bool? isSyncing,
    DateTime? lastSync,
    int? itemsCount,
    String? status,
    String? errorMessage,
  }) {
    return CloudSyncSession(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
      itemsCount: itemsCount ?? this.itemsCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Cloud sync settings
class CloudSyncSettings {
  final bool enableCloudSync;
  final bool autoSyncOnStartup;
  final bool autoSyncDaily;
  final bool encryptBackup; // Optional: end-to-end encryption
  final String? cloudProvider; // 'none', 'dropbox', 'gdrive', 'custom'
  final String? authToken;

  CloudSyncSettings({
    required this.enableCloudSync,
    required this.autoSyncOnStartup,
    required this.autoSyncDaily,
    required this.encryptBackup,
    this.cloudProvider,
    this.authToken,
  });

  CloudSyncSettings copyWith({
    bool? enableCloudSync,
    bool? autoSyncOnStartup,
    bool? autoSyncDaily,
    bool? encryptBackup,
    String? cloudProvider,
    String? authToken,
  }) {
    return CloudSyncSettings(
      enableCloudSync: enableCloudSync ?? this.enableCloudSync,
      autoSyncOnStartup: autoSyncOnStartup ?? this.autoSyncOnStartup,
      autoSyncDaily: autoSyncDaily ?? this.autoSyncDaily,
      encryptBackup: encryptBackup ?? this.encryptBackup,
      cloudProvider: cloudProvider ?? this.cloudProvider,
      authToken: authToken ?? this.authToken,
    );
  }
}

// Cloud sync settings provider
final cloudSyncSettingsProvider = StateProvider<CloudSyncSettings>((ref) {
  return CloudSyncSettings(
    enableCloudSync: false,
    autoSyncOnStartup: false,
    autoSyncDaily: false,
    encryptBackup: true,
    cloudProvider: 'none',
    authToken: null,
  );
});

// Cloud sync session provider
final cloudSyncSessionProvider =
    StateProvider<CloudSyncSession>((ref) => CloudSyncSession(isSyncing: false));

// Sync history provider
final syncHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final result = await api.getSyncHistory();
  return result.data ?? [];
});
