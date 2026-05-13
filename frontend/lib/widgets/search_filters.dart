import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class SearchFiltersWidget extends ConsumerWidget {
  const SearchFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(searchSortProvider);
    final duration = ref.watch(searchDurationProvider);
    final uploadDate = ref.watch(searchUploadDateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Sort dropdown
          Expanded(
            flex: 2,
            child: _FilterDropdown(
              label: 'Sort',
              value: sort,
              items: const [
                ('relevance', 'Relevance'),
                ('upload_date', 'Upload Date'),
                ('view_count', 'Views'),
                ('rating', 'Rating'),
              ],
              onChanged: (value) {
                ref.read(searchSortProvider.notifier).state = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          // Duration dropdown
          Expanded(
            flex: 2,
            child: _FilterDropdown(
              label: 'Duration',
              value: duration,
              items: const [
                ('any', 'Any'),
                ('short', 'Short (<4m)'),
                ('medium', 'Medium (4-20m)'),
                ('long', 'Long (>20m)'),
              ],
              onChanged: (value) {
                ref.read(searchDurationProvider.notifier).state = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          // Upload date dropdown
          Expanded(
            flex: 2,
            child: _FilterDropdown(
              label: 'Upload Date',
              value: uploadDate,
              items: const [
                ('any', 'Any Time'),
                ('hour', 'Last Hour'),
                ('day', 'Today'),
                ('week', 'This Week'),
                ('month', 'This Month'),
                ('year', 'This Year'),
              ],
              onChanged: (value) {
                ref.read(searchUploadDateProvider.notifier).state = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<(String, String)> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          underline: Container(),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item.$1,
                    child: Text(
                      item.$2,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }
}
