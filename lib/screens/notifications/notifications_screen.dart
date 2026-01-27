import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';

final notificationsProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  await Future.delayed(const Duration(seconds: 1));
  // TODO: Replace with real notifications
  return [];
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsEnabled = ref.watch(
      settingsProvider.select((s) => s.notificationsEnabled),
    );
    final notificationsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.notifications_active),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Notifications', style: TextStyle(fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // TODO: Implement notification delete/clear logic
                  },
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: (val) =>
                      ref.read(settingsProvider.notifier).toggleNotifications(),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const CustomLoadingWidget(
                message: 'Loading notifications...',
              ),
              error: (e, _) => CustomErrorWidget(
                message: 'Couldn\'t load notifications. Please check your connection.',
                onRetry: () => ref.refresh(notificationsProvider),
              ),
              data: (notifications) => notifications.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.notifications_none,
                      title: 'No Notifications Yet',
                      message: 'You\'ll receive notifications when you\'re near historical places.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        return ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            n['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(n['body'] ?? ''),
                          trailing: Text(
                            n['time'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
