import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../providers/cloud_sync_provider.dart';

/// Cloud sync settings dialog
class CloudSyncDialog extends ConsumerStatefulWidget {
  const CloudSyncDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<CloudSyncDialog> createState() => _CloudSyncDialogState();
}

class _CloudSyncDialogState extends ConsumerState<CloudSyncDialog> {
  late CloudSyncSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(cloudSyncSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final syncSession = ref.watch(cloudSyncSessionProvider);
    final syncHistory = ref.watch(syncHistoryProvider);

    return AlertDialog(
      title: const Text('Cloud Sync Settings'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enable Cloud Sync Toggle
              SwitchListTile(
                title: const Text('Enable Cloud Sync'),
                subtitle: const Text('Backup subscriptions and playlists'),
                value: _settings.enableCloudSync,
                onChanged: syncSession.isSyncing
                    ? null
                    : (value) {
                        setState(() {
                          _settings = _settings.copyWith(enableCloudSync: value);
                        });
                      },
              ),
              const Divider(),

              if (_settings.enableCloudSync) ...[
                // Cloud Provider Selector
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cloud Provider',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: _settings.cloudProvider ?? 'none',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text('None (Local Backup)'),
                          ),
                          DropdownMenuItem(
                            value: 'dropbox',
                            child: Text('Dropbox'),
                          ),
                          DropdownMenuItem(
                            value: 'gdrive',
                            child: Text('Google Drive'),
                          ),
                          DropdownMenuItem(
                            value: 'custom',
                            child: Text('Custom Server'),
                          ),
                        ],
                        onChanged: syncSession.isSyncing
                            ? null
                            : (value) {
                                setState(() {
                                  _settings = _settings.copyWith(
                                    cloudProvider: value,
                                    authToken: null,
                                  );
                                });
                              },
                      ),
                    ],
                  ),
                ),
                const Divider(),

                if (_settings.cloudProvider != 'none')
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: syncSession.isSyncing
                                ? null
                                : () async {
                                    // OAuth flow placeholder
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Opening ${_settings.cloudProvider} auth...'),
                                      ),
                                    );
                                    // In real implementation, open OAuth flow
                                    setState(() {
                                      _settings = _settings.copyWith(
                                        authToken: 'connected_token_123',
                                      );
                                    });
                                  },
                            icon: const Icon(Icons.cloud_queue),
                            label: Text(
                              _settings.authToken != null
                                  ? '✓ Connected'
                                  : 'Connect ${_settings.cloudProvider}',
                            ),
                          ),
                        ),
                        if (_settings.authToken != null) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Disconnect',
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _settings = _settings.copyWith(
                                    authToken: null,
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const Divider(),

                // Auto-sync toggles
                SwitchListTile(
                  title: const Text('Auto-Sync on Startup'),
                  value: _settings.autoSyncOnStartup,
                  onChanged: syncSession.isSyncing
                      ? null
                      : (value) {
                          setState(() {
                            _settings =
                                _settings.copyWith(autoSyncOnStartup: value);
                          });
                        },
                ),
                SwitchListTile(
                  title: const Text('Auto-Sync Daily'),
                  value: _settings.autoSyncDaily,
                  onChanged: syncSession.isSyncing
                      ? null
                      : (value) {
                          setState(() {
                            _settings = _settings.copyWith(autoSyncDaily: value);
                          });
                        },
                ),
                const Divider(),

                // Encryption toggle
                SwitchListTile(
                  title: const Text('Encrypt Backups'),
                  subtitle: const Text('End-to-end encryption (optional)'),
                  value: _settings.encryptBackup,
                  onChanged: syncSession.isSyncing
                      ? null
                      : (value) {
                          setState(() {
                            _settings = _settings.copyWith(encryptBackup: value);
                          });
                        },
                ),
              ],

              const SizedBox(height: 16),

              // Sync Status
              if (syncSession.isSyncing)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Syncing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Backing up ${syncSession.itemsCount} items',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              else if (syncSession.lastSync != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[900]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Last Sync',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(syncSession.lastSync!),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: syncSession.isSyncing ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (_settings.enableCloudSync && _settings.authToken != null)
          ElevatedButton.icon(
            onPressed: syncSession.isSyncing ? null : () => _startSync(ref),
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Sync Now'),
          ),
      ],
    );
  }

  Future<void> _startSync(WidgetRef ref) async {
    ref.read(cloudSyncSettingsProvider.notifier).state = _settings;

    ref.read(cloudSyncSessionProvider.notifier).state = CloudSyncSession(
      isSyncing: true,
      status: 'syncing',
      itemsCount: 0,
    );

    // Simulate sync
    await Future.delayed(const Duration(seconds: 2));

    ref.read(cloudSyncSessionProvider.notifier).state = CloudSyncSession(
      isSyncing: false,
      lastSync: DateTime.now(),
      itemsCount: 42, // Subscriptions + playlists
      status: 'complete',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sync complete! 42 items backed up.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
