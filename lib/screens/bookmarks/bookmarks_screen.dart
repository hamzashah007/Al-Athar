import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/home_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkedPlacesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () {
            final container = ProviderScope.containerOf(context, listen: false);
            container.read(bottomNavIndexProvider.notifier).state = 0;
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: bookmarksAsync.when(
        loading: () =>
            const CustomLoadingWidget(message: 'Loading your bookmarks...'),
        error: (e, _) => CustomErrorWidget(
          message: 'Couldn\'t load your bookmarks. Please check your internet connection.',
          onRetry: () => ref.invalidate(bookmarkedPlacesProvider),
        ),
        data: (bookmarks) => bookmarks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'No bookmarks yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: bookmarks.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final place = bookmarks[i];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        place.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.place, size: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      place.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(place.city),
                    trailing: const Icon(Icons.bookmark),
                    onTap: () => context.push('/place-details/${place.id}'),
                  );
                },
              ),
      ),
    );
  }
}
