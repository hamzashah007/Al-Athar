import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/place_model.dart';
import '../../widgets/custom_button.dart';
import '../../providers/bookmarks_provider.dart';

class PlaceBottomSheet extends ConsumerWidget {
  final PlaceModel place;

  const PlaceBottomSheet({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBookmarked = ref.watch(isPlaceBookmarkedProvider(place.id));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Place name with image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Place image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/places/${place.image}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.place,
                        color: theme.colorScheme.primary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Place name and city
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // City with icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.city,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Short description
            Text(
              place.shortHistory,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton.elevated(
                    text: 'Read Full History',
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/place-details/${place.id}');
                    },
                    width: double.infinity,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () async {
                      try {
                        final toggleBookmark = ref.read(
                          bookmarkToggleProvider(place.id),
                        );
                        await toggleBookmark();
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isBookmarked
                                    ? 'Removed from bookmarks'
                                    : 'Added to bookmarks',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Couldn\'t update bookmark. Please try again.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
