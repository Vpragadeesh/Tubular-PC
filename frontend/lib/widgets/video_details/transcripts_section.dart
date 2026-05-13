import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/video_details.dart';
import '../../providers.dart';

class TranscriptsSection extends ConsumerStatefulWidget {
  final List<Subtitle> subtitles;
  final String videoId;

  const TranscriptsSection({
    required this.subtitles,
    required this.videoId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<TranscriptsSection> createState() => _TranscriptsSectionState();
}

class _TranscriptsSectionState extends ConsumerState<TranscriptsSection> {
  late TextEditingController _searchController;
  bool _isSearching = false;

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
    final searchQuery = _searchController.text;
    final searchResults = ref.watch(subtitleSearchProvider((widget.videoId, searchQuery)));

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search within subtitles...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
              });
            },
          ),
        ),
        // Results or subtitles
        Expanded(
          child: _isSearching
              ? searchResults.when(
                  data: (results) {
                    if (results.isEmpty && _searchController.text.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No matches found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return SearchResultTile(
                          result: result,
                          query: _searchController.text,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                )
              : widget.subtitles.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.closed_caption_disabled,
                              size: 48,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subtitles available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.subtitles.length,
                      itemBuilder: (context, index) {
                        final subtitle = widget.subtitles[index];
                        return SubtitleTile(subtitle: subtitle);
                      },
                    ),
        ),
      ],
    );
  }
}

class SubtitleTile extends ConsumerWidget {
  final Subtitle subtitle;

  const SubtitleTile({
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        Icons.closed_caption,
        color: Colors.red[700],
      ),
      title: Text(subtitle.languageName),
      subtitle: Text(
        '${subtitle.language.toUpperCase()} • ${subtitle.ext}',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: const Icon(Icons.open_in_new),
      onTap: () {
        // Copy subtitle URL to clipboard
        Clipboard.setData(ClipboardData(text: subtitle.url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Subtitle URL copied to clipboard'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green[700],
          ),
        );
      },
      onLongPress: () {
        // Show details dialog
        showDialog(
          context: context,
          builder: (context) => SubtitleDetailsDialog(subtitle: subtitle),
        );
      },
    );
  }
}

class SubtitleDetailsDialog extends StatelessWidget {
  final Subtitle subtitle;

  const SubtitleDetailsDialog({
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(subtitle.languageName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Language', subtitle.language),
            const SizedBox(height: 12),
            _buildDetailRow('Format', subtitle.ext.toUpperCase()),
            const SizedBox(height: 16),
            const Text(
              'URL:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                subtitle.url,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: subtitle.url));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('URL copied to clipboard'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green[700],
              ),
            );
          },
          icon: const Icon(Icons.content_copy),
          label: const Text('Copy URL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(value),
        ),
      ],
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final dynamic result;
  final String query;

  const SearchResultTile({
    required this.result,
    required this.query,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = result.text as String;
    final startTime = result.startTime as double;
    final formattedTime =
        '${(startTime ~/ 60).toString().padLeft(2, '0')}:${(startTime % 60).toStringAsFixed(0).padLeft(2, '0')}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Would navigate to this timestamp in the video player
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[700]?.withAlpha(150),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: _buildHighlightedText(text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Line ${result.lineNumber}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _buildHighlightedText(String text) {
    final spans = <TextSpan>[];
    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    int lastIndex = 0;

    final regex = RegExp(RegExp.escape(queryLower), caseSensitive: false);
    final matches = regex.allMatches(textLower);

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: Colors.grey[300]),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          color: Colors.red[300],
          backgroundColor: Colors.red[700]?.withAlpha(100),
          fontWeight: FontWeight.bold,
        ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: Colors.grey[300]),
      ));
    }

    return TextSpan(children: spans);
  }
}
