import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_entry.dart';
import '../services/api_service.dart';
import 'player_screen.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final historyProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getHistory();
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear History'),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearHistoryDialog(context);
              }
            },
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No watch history',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Videos you watch will appear here',
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

          // Group history by date
          final grouped = _groupHistoryByDate(history);

          return ListView.builder(
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0 || _getDayDifference(grouped[index].watchedAt, grouped[index - 1].watchedAt) > 0)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _formatDateHeader(entry.watchedAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  _buildHistoryTile(context, entry),
                ],
              );
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(historyProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<HistoryEntry> _groupHistoryByDate(List<HistoryEntry> history) {
    // Sort by date descending
    final sorted = List<HistoryEntry>.from(history);
    sorted.sort((a, b) {
      final dateA = DateTime.tryParse(a.watchedAt) ?? DateTime.now();
      final dateB = DateTime.tryParse(b.watchedAt) ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
    return sorted;
  }

  int _getDayDifference(String dateStr1, String dateStr2) {
    final date1 = DateTime.tryParse(dateStr1) ?? DateTime.now();
    final date2 = DateTime.tryParse(dateStr2) ?? DateTime.now();
    return date1.difference(date2).inDays;
  }

  String _formatDateHeader(String dateStr) {
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      return '${(difference / 7).floor()} weeks ago';
    } else {
      return '${(difference / 30).floor()} months ago';
    }
  }

  Widget _buildHistoryTile(BuildContext context, HistoryEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              image: NetworkImage(entry.thumbnail),
              fit: BoxFit.cover,
            ),
            color: Colors.grey[700],
          ),
        ),
        title: Text(
          entry.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          entry.channel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Text('Remove'),
            ),
          ],
          onSelected: (value) {
            if (value == 'remove') {
              // Remove from history
              ref.refresh(historyProvider);
            }
          },
        ),
        onTap: () {
          // Play video
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playing: ${entry.title}')),
          );
        },
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all watch history? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
              ref.refresh(historyProvider);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
