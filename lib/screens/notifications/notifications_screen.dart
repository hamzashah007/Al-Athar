import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String formatTime(DateTime? dt) {
  if (dt == null) return '';
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour < 12 ? 'AM' : 'PM';
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
         '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_off,
              title: 'No notifications yet',
              message: 'You will see notifications here when you are near a historical place.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                leading: n.read
                    ? Icon(Icons.notifications_none, color: Colors.grey)
                    : Icon(Icons.notifications_active, color: Colors.blue),
                title: Text(n.placeName),
                subtitle: Text(n.message ?? ''),
                trailing: Text(formatTime(n.timestamp)),
                tileColor: n.read ? null : Colors.blue.withOpacity(0.08),
                onTap: () async {
                  final user = ref.read(authStateProvider).asData?.value;
                  if (user != null && !n.read) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('user_notifications')
                        .doc(n.id)
                        .update({'read': true});
                  }
                  context.push('/place-details/${n.placeId}');
                },
              );
            },
          );
        },
        loading: () => const CustomLoadingWidget(),
        error: (e, _) {
          final msg = e.toString();
          if (msg.contains('permission-denied')) {
            return Center(child: Text('No notifications yet.'));
          }
          return CustomErrorWidget(message: e.toString());
        },
      ),
    );
  }
}
