import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = [
      {
        'title': 'Welcome to Al-Athar!',
        'body': 'Thank you for joining. Explore historical places now.',
        'time': 'Just now',
      },
      {
        'title': 'New Place Added',
        'body': 'A new historical site has been added near you.',
        'time': '2 hours ago',
      },
      {
        'title': 'Bookmark Reminder',
        'body': 'Don’t forget to check your bookmarked places.',
        'time': 'Yesterday',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            final container = ProviderScope.containerOf(context, listen: false);
            container.read(bottomNavIndexProvider.notifier).state = 0;
            context.go('/home');
          },
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final n = notifications[index];
          return ListTile(
            leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
            title: Text(n['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(n['body']!),
            trailing: Text(n['time']!, style: TextStyle(fontSize: 12, color: Colors.grey)),
          );
        },
      ),
    );
  }
}
