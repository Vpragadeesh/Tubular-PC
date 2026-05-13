import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/subscription.dart';
import '../models/video.dart';
import '../providers.dart';
import '../controllers/player_controller.dart';
import '../widgets/video_card.dart';
import 'player_screen.dart';
import 'video_details_screen.dart';

final subscriptionsFeedTabProvider = StateProvider<String>((ref) => 'feed');
final subscriptionSearchProvider = StateProvider<String>((ref) => '');
final subscriptionsSortProvider = StateProvider<String>((ref) => 'name_asc');

final subscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final search = ref.watch(subscriptionSearchProvider);
  final sort = ref.watch(subscriptionsSortProvider);
  
  List<Subscription> subs = await apiService.getSubscriptions();
  
  // Filter by search
  if (search.isNotEmpty) {
    subs = subs
        .where((s) => s.channelName.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
  
  // Apply sorting
  switch (sort) {
    case 'name_asc':
      subs.sort((a, b) => a.channelName.compareTo(b.channelName));
      break;
    case 'name_desc':
      subs.sort((a, b) => b.channelName.compareTo(a.channelName));
      break;
    case 'date_asc':
      subs.sort((a, b) => a.subscribedAt.compareTo(b.subscribedAt));
      break;
    case 'date_desc':
    default:
      subs.sort((a, b) => b.subscribedAt.compareTo(a.subscribedAt));
  }
  
  return subs;
});

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
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
    final feedAsync = ref.watch(subscriptionFeedProvider);
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final tab = ref.watch(subscriptionsFeedTabProvider);
    final sort = ref.watch(subscriptionsSortProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subscriptions'),
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: Colors.white,
            onTap: (index) {
              ref.read(subscriptionsFeedTabProvider.notifier).state = index == 0 ? 'feed' : 'channels';
            },
            tabs: const [
              Tab(text: 'Feed'),
              Tab(text: 'Channels'),
            ],
          ),
          actions: [
            if (tab == 'channels')
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort',
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'name_asc',
                    child: Text('Name (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: 'name_desc',
                    child: Text('Name (Z-A)'),
                  ),
                  const PopupMenuItem(
                    value: 'date_desc',
                    child: Text('Recently Subscribed'),
                  ),
                  const PopupMenuItem(
                    value: 'date_asc',
                    child: Text('Oldest First'),
                  ),
                ],
                onSelected: (value) {
                  ref.read(subscriptionsSortProvider.notifier).state = value;
                },
              ),
          ],
        ),
        body: tab == 'feed'
            ? _buildFeedTab(context, ref, feedAsync)
            : _buildChannelsTab(context, ref, subscriptionsAsync),
      ),
    );
  }

  Widget _buildFeedTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Video>> feedAsync,
  ) {
    return feedAsync.when(
      data: (videos) {
        if (videos.isEmpty) {
          return _buildEmptyFeedState();
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: MasonryGridView.count(
              crossAxisCount: 4,
              itemCount: videos.length,
              padding: const EdgeInsets.all(12),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (context, index) {
                final video = videos[index];
                return VideoCard(
                  video: video,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoDetailsScreen(video: video),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildChannelsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Subscription>> subscriptionsAsync,
  ) {
    return subscriptionsAsync.when(
      data: (subscriptions) {
        if (subscriptions.isEmpty) {
          return _buildEmptyChannelsState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final sub = subscriptions[index];
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildSubscriptionTile(context, sub),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEmptyFeedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feed,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No videos in feed',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscribe to channels to see their latest videos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChannelsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No subscriptions',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for channels and subscribe to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
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
            onPressed: () => ref.refresh(subscriptionsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTile(BuildContext context, Subscription sub) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(sub.channelThumbnail),
          backgroundColor: Colors.red[700],
          onBackgroundImageError: (_, __) {},
          child: sub.channelThumbnail.isEmpty
              ? Icon(Icons.person, color: Colors.grey[400])
              : null,
        ),
        title: Text(
          sub.channelName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'ID: ${sub.channelId}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_channel',
              child: Row(
                children: [
                  Icon(Icons.open_in_new, size: 18),
                  SizedBox(width: 8),
                  Text('View Channel'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'unsubscribe',
              child: Row(
                children: [
                  Icon(Icons.check_box, size: 18),
                  SizedBox(width: 8),
                  Text('Unsubscribe'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'view_channel') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Channel page coming soon: ${sub.channelName}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (value == 'unsubscribe') {
              _showUnsubscribeDialog(context, sub);
            }
          },
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing channel: ${sub.channelName}')),
          );
        },
      ),
    );
  }

  void _showUnsubscribeDialog(BuildContext context, Subscription sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsubscribe'),
        content: Text('Unsubscribe from ${sub.channelName}?'),
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
                await apiService.removeSubscription(sub.channelId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unsubscribed successfully')),
                  );
                }
                ref.refresh(subscriptionsProvider);
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
            child: Text(
              'Unsubscribe',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}
