import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(appNotificationsProvider);
    final isMuted = ref.watch(notificationsMutedProvider);
    final theme = Theme.of(context);
    final formatter = DateFormat('yyyy-MM-dd', 'ar');

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          notificationsAsync.maybeWhen(
            data: (notifications) => PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  ref
                      .read(dismissedNotificationsProvider.notifier)
                      .clearAllVisible(notifications.map((item) => item.id));
                } else if (value == 'restore_all') {
                  ref
                      .read(dismissedNotificationsProvider.notifier)
                      .restoreAll();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'clear_all',
                  child: Text('مسح كل الإشعارات الحالية'),
                ),
                PopupMenuItem(
                  value: 'restore_all',
                  child: Text('إظهار الإشعارات مرة أخرى'),
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: Icon(
              isMuted ? Icons.notifications_off : Icons.notifications_active,
            ),
            tooltip: isMuted ? 'تفعيل الإشعارات' : 'إيقاف الإشعارات مؤقتاً',
            onPressed: () {
              ref
                  .read(notificationsMutedProvider.notifier)
                  .toggleMute(!isMuted);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isMuted
                        ? 'تم إيقاف تنبيهات الإشعارات مؤقتاً'
                        : 'تم تفعيل تنبيهات الإشعارات',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إشعارات أو تنبيهات حالياً',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              IconData icon;
              Color color;

              switch (notif.type) {
                case 'rent':
                  icon = Icons.money_off;
                  color = Colors.red;
                  break;
                case 'checkout':
                  icon = Icons.directions_walk;
                  color = Colors.orange;
                  break;
                case 'checkin':
                  icon = Icons.login;
                  color = Colors.green;
                  break;
                case 'expiration':
                  icon = Icons.event_busy;
                  color = Colors.blue;
                  break;
                case 'maintenance':
                  icon = Icons.build;
                  color = Colors.deepOrange;
                  break;
                case 'damage':
                  icon = Icons.warning_amber;
                  color = Colors.redAccent;
                  break;
                case 'cleaning':
                  icon = Icons.cleaning_services;
                  color = Colors.teal;
                  break;
                case 'inventory':
                  icon = Icons.inventory;
                  color = Colors.purple;
                  break;
                default:
                  icon = Icons.notifications;
                  color = theme.colorScheme.primary;
              }

              return Dismissible(
                key: ValueKey(notif.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: theme.colorScheme.error,
                  child: Icon(Icons.delete, color: theme.colorScheme.onError),
                ),
                onDismissed: (_) {
                  ref
                      .read(dismissedNotificationsProvider.notifier)
                      .dismiss(notif.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الإشعار')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.2),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(
                      notif.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif.body),
                          const SizedBox(height: 4),
                          Text(
                            'تاريخ: ${formatter.format(notif.date)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'حذف الإشعار',
                      onPressed: () {
                        ref
                            .read(dismissedNotificationsProvider.notifier)
                            .dismiss(notif.id);
                      },
                    ),
                    onTap: notif.route == null
                        ? null
                        : () => context.push(notif.route!),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}
