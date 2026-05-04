import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/download.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final downloadsProvider = FutureProvider<List<Download>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  // TODO: Fetch from backend API
  // For now, return mock data
  return [];
});

final activeDownloadsProvider = FutureProvider<List<Download>>((ref) async {
  final downloads = await ref.watch(downloadsProvider.future);
  return downloads.where((d) => d.isDownloading || d.isPaused).toList();
});

final completedDownloadsProvider = FutureProvider<List<Download>>((ref) async {
  final downloads = await ref.watch(downloadsProvider.future);
  return downloads.where((d) => d.isCompleted).toList();
});

final failedDownloadsProvider = FutureProvider<List<Download>>((ref) async {
  final downloads = await ref.watch(downloadsProvider.future);
  return downloads.where((d) => d.isFailed).toList();
});

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Failed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveTab(),
          _buildCompletedTab(),
          _buildFailedTab(),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    final activeAsync = ref.watch(activeDownloadsProvider);

    return activeAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No active downloads',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search for videos and start downloading',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: downloads.length,
          itemBuilder: (context, index) {
            final download = downloads[index];
            return _buildDownloadTile(context, download);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTab() {
    final completedAsync = ref.watch(completedDownloadsProvider);

    return completedAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed downloads',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: downloads.length,
          itemBuilder: (context, index) {
            final download = downloads[index];
            return _buildCompletedDownloadTile(context, download);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildFailedTab() {
    final failedAsync = ref.watch(failedDownloadsProvider);

    return failedAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No failed downloads',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: downloads.length,
          itemBuilder: (context, index) {
            final download = downloads[index];
            return _buildFailedDownloadTile(context, download);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildDownloadTile(BuildContext context, Download download) {
    final downloadSpeed =
        download.progress > 0 ? '${(download.progress * 10).toStringAsFixed(1)} MB/s' : 'Starting...';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${download.quality} • ${download.format}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pause',
                      child: Text(download.isPaused ? 'Resume' : 'Pause'),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancel'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'pause') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(download.isPaused ? 'Resumed' : 'Paused')),
                      );
                    } else if (value == 'cancel') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download cancelled')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: download.progress / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      download.isFailed ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${download.progressText} • ${download.formattedFileSize}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      downloadSpeed,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedDownloadTile(BuildContext context, Download download) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(
          download.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${download.quality} • ${download.formattedFileSize}',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Text('Open'),
            ),
            const PopupMenuItem(
              value: 'show_in_folder',
              child: Text('Show in Folder'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'open') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening download')),
              );
            } else if (value == 'show_in_folder') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening folder')),
              );
            } else if (value == 'delete') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download deleted')),
              );
              ref.refresh(downloadsProvider);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFailedDownloadTile(BuildContext context, Download download) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.error, color: Colors.red),
        title: Text(
          download.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          download.errorMessage ?? 'Download failed',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'retry',
              child: Text('Retry'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'retry') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Retrying download')),
              );
            } else if (value == 'delete') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download deleted')),
              );
              ref.refresh(downloadsProvider);
            }
          },
        ),
      ),
    );
  }
}
