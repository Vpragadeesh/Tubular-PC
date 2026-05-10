import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_entry.dart';
import '../providers.dart';
import 'player_screen.dart';

final historySearchProvider = StateProvider<String>((ref) => '');
final historyFilterProvider = StateProvider<String>((ref) => 'all'); // all, today, week, month

final historyProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final search = ref.watch(historySearchProvider);
  final filter = ref.watch(historyFilterProvider);
  
  List<HistoryEntry> history = await apiService.getHistory();
  
  // Filter by search
  if (search.isNotEmpty) {
    history = history
        .where((h) => h.title.toLowerCase().contains(search.toLowerCase()) ||
            h.channel.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
  
  // Filter by date
  final now = DateTime.now();
  switch (filter) {
    case 'today':
      history = history.where((h) {
        final date = DateTime.tryParse(h.watchedAt) ?? now;
        return now.difference(date).inDays == 0;
      }).toList();
      break;
    case 'week':
      history = history.where((h) {
        final date = DateTime.tryParse(h.watchedAt) ?? now;
        return now.difference(date).inDays <= 7;
      }).toList();
      break;
    case 'month':
      history = history.where((h) {
        final date = DateTime.tryParse(h.watchedAt) ?? now;
        return now.difference(date).inDays <= 30;
      }).toList();
      break;
    case 'all':
    default:
      break;
  }
  
  return history;
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final filter = ref.watch(historyFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export History as CSV',
            onPressed: _exportHistoryAsCsv,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: const [
                    Icon(Icons.delete_sweep, size: 18),
                    SizedBox(width: 8),
                    Text('Clear All History'),
                  ],
                ),
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
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                ref.read(historySearchProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search history...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(historySearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', filter),
                const SizedBox(width: 8),
                _buildFilterChip('Today', 'today', filter),
                const SizedBox(width: 8),
                _buildFilterChip('This Week', 'week', filter),
                const SizedBox(width: 8),
                _buildFilterChip('This Month', 'month', filter),
              ],
            ),
          ),
          // History list
          Expanded(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: _buildHistoryTile(context, entry),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter) {
    final isSelected = value == currentFilter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(historyFilterProvider.notifier).state = value;
      },
      backgroundColor: Colors.grey[800],
      selectedColor: Colors.red[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
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
            onPressed: () => ref.refresh(historyProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportHistoryAsCsv() async {
    final historyAsync = ref.watch(historyProvider);
    
    historyAsync.when(
      data: (history) async {
        if (history.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No history to export')),
          );
          return;
        }

        final apiService = ref.read(apiServiceProvider);
        try {
          // Prepare CSV data
          List<List<dynamic>> rows = [
            ['Video ID', 'Title', 'Channel', 'Thumbnail URL', 'Watched At', 'Progress']
          ];
          
          for (final entry in history) {
            rows.add([
              entry.videoId,
              entry.title,
              entry.channel,
              entry.thumbnail,
              entry.watchedAt,
              entry.progress?.toString() ?? '0.0',
            ]);
          }

          String csv = const ListToCsvConverter().convert(rows);

          // Prompt for save location
          final home = Platform.environment['HOME'];
          final base = home == null || home.isEmpty ? '.' : '$home/Downloads';
          final now = DateTime.now();
          final y = now.year.toString().padLeft(4, '0');
          final m = now.month.toString().padLeft(2, '0');
          final d = now.day.toString().padLeft(2, '0');
          final suggestedPath = '$base/tubular-history-$y$m$d.csv';

          final controller = TextEditingController(text: suggestedPath);
          final value = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Export History as CSV'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter file path',
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                    child: const Text('Export'),
                  ),
                ],
              );
            },
          );
          controller.dispose();

          if (value == null || value.trim().isEmpty) return;

          var finalPath = value.trim();
          if (!finalPath.endsWith('.csv')) {
            finalPath = '$finalPath.csv';
          }

          final outputFile = File(finalPath);
          await outputFile.parent.create(recursive: true);
          await outputFile.writeAsString(csv);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('History exported: $finalPath')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to export history: $e'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
      loading: () => {},
      error: (error, stack) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $error'),
            backgroundColor: Colors.red[700],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTile(BuildContext context, HistoryEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          entry.channel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove'),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'remove') {
              final apiService = ref.read(apiServiceProvider);
              try {
                await apiService.removeFromHistory(entry.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removed from history'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
                ref.refresh(historyProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red[700],
                    ),
                  );
                }
              }
            }
          },
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing: ${entry.title}'),
              duration: const Duration(seconds: 1),
            ),
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
        content: const Text(
          'Are you sure you want to clear all watch history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final apiService = ref.read(apiServiceProvider);
              try {
                await apiService.clearHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History cleared')),
                  );
                }
                ref.refresh(historyProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red[700],
                    ),
                  );
                }
              }
            },
            child: Text('Clear', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }
}
