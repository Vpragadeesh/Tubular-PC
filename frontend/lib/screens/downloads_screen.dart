import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/download.dart';
import '../providers.dart';

// Sort options
final downloadsSortProvider = StateProvider<String>((ref) => 'date_desc');

final downloadsProvider = FutureProvider<List<Download>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final sort = ref.watch(downloadsSortProvider);
  
  // Fetch downloads from backend API
  List<Download> downloads = await apiService.getDownloads();
  
  // Apply sorting
  switch (sort) {
    case 'name_asc':
      downloads.sort((a, b) => a.title.compareTo(b.title));
      break;
    case 'name_desc':
      downloads.sort((a, b) => b.title.compareTo(a.title));
      break;
    case 'size_asc':
      downloads.sort((a, b) => a.fileSize.compareTo(b.fileSize));
      break;
    case 'size_desc':
      downloads.sort((a, b) => b.fileSize.compareTo(a.fileSize));
      break;
    case 'date_asc':
      downloads.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case 'date_desc':
    default:
      downloads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  return downloads;
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

// Stats providers
final totalDownloadsSizeProvider = FutureProvider<int>((ref) async {
  final downloads = await ref.watch(downloadsProvider.future);
  return downloads.fold<int>(0, (sum, d) => sum + d.fileSize);
});

final totalActiveDownloadsSizeProvider = FutureProvider<int>((ref) async {
  final downloads = await ref.watch(activeDownloadsProvider.future);
  return downloads.fold<int>(0, (sum, d) => sum + d.fileSize);
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
    final totalSize = ref.watch(totalDownloadsSizeProvider);
    final sort = ref.watch(downloadsSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: 'name_asc',
                child: Text('Name (A-Z)'),
              ),
              const PopupMenuItem(
                value: 'name_desc',
                child: Text('Name (Z-A)'),
              ),
              const PopupMenuItem(
                value: 'size_desc',
                child: Text('Largest First'),
              ),
              const PopupMenuItem(
                value: 'size_asc',
                child: Text('Smallest First'),
              ),
            ],
            onSelected: (value) {
              ref.read(downloadsSortProvider.notifier).state = value;
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.cloud_download), text: 'Active'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
            Tab(icon: Icon(Icons.error), text: 'Failed'),
          ],
        ),
      ),
      body: Column(
        children: [
        // Stats bar
        Container(
          color: Colors.grey[850],
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.storage,
                label: 'Total Size',
                value: totalSize.when(
                  data: (size) => _formatBytes(size),
                  loading: () => '...',
                  error: (_, __) => 'N/A',
                ),
              ),
              _buildStatItem(
                icon: Icons.speed,
                label: 'Active',
                value: '0 B',
              ),
              _buildStatItem(
                icon: Icons.list,
                label: 'Total',
                value: 'N/A',
              ),
            ],
          ),
        ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(),
                _buildCompletedTab(),
                _buildFailedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.red[700], size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTab() {
    final activeAsync = ref.watch(activeDownloadsProvider);

    return activeAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return _buildEmptyState(
            icon: Icons.cloud_download,
            title: 'No active downloads',
            subtitle: 'Search for videos to start downloading',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: downloads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final download = downloads[index];
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildDownloadTile(context, download),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildCompletedTab() {
    final completedAsync = ref.watch(completedDownloadsProvider);

    return completedAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: 'No completed downloads',
            subtitle: 'Your downloads will appear here',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: downloads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final download = downloads[index];
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildCompletedDownloadTile(context, download),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildFailedTab() {
    final failedAsync = ref.watch(failedDownloadsProvider);

    return failedAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: 'No failed downloads',
            subtitle: 'All your downloads completed successfully',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: downloads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final download = downloads[index];
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildFailedDownloadTile(context, download),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 300,
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(downloadsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTile(BuildContext context, Download download) {
    final downloadSpeed =
        download.progress > 0 ? '${(download.progress * 10).toStringAsFixed(1)} MB/s' : 'Starting...';
    final eta = download.progress > 0 ? '~${((100 - download.progress) / download.progress * 2).toStringAsFixed(0)}s' : '--';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(width: 4, color: Colors.red[700]!),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and actions
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
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(download.quality),
                              labelStyle: const TextStyle(fontSize: 11),
                              visualDensity: VisualDensity.compact,
                            ),
                            Chip(
                              label: Text(download.format),
                              labelStyle: const TextStyle(fontSize: 11),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pause',
                        child: Row(
                          children: [
                            Icon(
                              download.isPaused ? Icons.play_arrow : Icons.pause,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(download.isPaused ? 'Resume' : 'Pause'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.close, size: 18),
                            SizedBox(width: 8),
                            Text('Cancel'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'pause') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(download.isPaused ? 'Resumed' : 'Paused'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } else if (value == 'cancel') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Download cancelled'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress visualization
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: download.progress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[700],
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
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'ETA: $eta',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        downloadSpeed,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        download.statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedDownloadTile(BuildContext context, Download download) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(width: 4, color: Colors.green),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.check_circle, color: Colors.green, size: 28),
          title: Text(
            download.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${download.quality} • ${download.formattedFileSize}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.folder_open, size: 18),
                    SizedBox(width: 8),
                    Text('Open'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'show_in_folder',
                child: Row(
                  children: [
                    Icon(Icons.folder, size: 18),
                    SizedBox(width: 8),
                    Text('Show in Folder'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'open') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening download'), duration: Duration(seconds: 1)),
                );
              } else if (value == 'show_in_folder') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening folder'), duration: Duration(seconds: 1)),
                );
              } else if (value == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download deleted'), duration: Duration(seconds: 1)),
                );
                ref.refresh(downloadsProvider);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFailedDownloadTile(BuildContext context, Download download) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(width: 4, color: Colors.red),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.error, color: Colors.red, size: 28),
          title: Text(
            download.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            download.errorMessage ?? 'Download failed',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.red[300]),
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'retry',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Retry'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'retry') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Retrying download'), duration: Duration(seconds: 1)),
                );
              } else if (value == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download deleted'), duration: Duration(seconds: 1)),
                );
                ref.refresh(downloadsProvider);
              }
            },
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
