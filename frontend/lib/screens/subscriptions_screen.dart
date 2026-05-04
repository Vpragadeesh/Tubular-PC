import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import '../widgets/video_card.dart';
import 'player_screen.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final subscriptionsProvider = FutureProvider<List<Subscription>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getSubscriptions();
});

final subscriptionVideosProvider = FutureProvider.family<List<Video>, String>((ref, channelId) async {
  final apiService = ref.watch(apiServiceProvider);
  // This would fetch latest videos from the channel
  // For now, return empty list
  return [];
});

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
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
                    'No subscriptions yet',
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
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              return _buildSubscriptionTile(context, sub);
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
                onPressed: () => ref.refresh(subscriptionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionTile(BuildContext context, Subscription sub) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(sub.channelThumbnail),
          backgroundColor: Colors.grey[700],
          onBackgroundImageError: (_, __) {},
          child: sub.channelThumbnail.isEmpty
              ? Icon(Icons.person, color: Colors.grey[400])
              : null,
        ),
        title: Text(sub.channelName),
        subtitle: Text('ID: ${sub.channelId}'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'unsubscribe',
              child: Text('Unsubscribe'),
            ),
          ],
          onSelected: (value) {
            if (value == 'unsubscribe') {
              _showUnsubscribeDialog(context, sub);
            }
          },
        ),
        onTap: () {
          // Navigate to channel page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Channel page coming soon: ${sub.channelName}')),
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unsubscribed')),
              );
              ref.refresh(subscriptionsProvider);
            },
            child: const Text('Unsubscribe', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
