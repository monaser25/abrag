import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(appNotificationsProvider);
    final isMuted = ref.watch(notificationsMutedProvider);
    final colors = context.colors;
    final formatter = DateFormat('yyyy-MM-dd', 'ar');

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'الإشعارات',
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
          AppIconButton(
            icon: isMuted
                ? Icons.notifications_off_outlined
                : Icons.notifications_active_outlined,
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
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'لا توجد إشعارات أو تنبيهات حالياً',
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
                  color = colors.err;
                  break;
                case 'checkout':
                  icon = Icons.directions_walk;
                  color = colors.warn;
                  break;
                case 'checkin':
                  icon = Icons.login;
                  color = colors.ok;
                  break;
                case 'expiration':
                  icon = Icons.event_busy;
                  color = colors.winter;
                  break;
                case 'maintenance':
                  icon = Icons.build;
                  color = colors.summer;
                  break;
                case 'damage':
                  icon = Icons.warning_amber;
                  color = colors.err;
                  break;
                case 'cleaning':
                  icon = Icons.cleaning_services;
                  color = colors.ok;
                  break;
                case 'inventory':
                  icon = Icons.inventory;
                  color = colors.accent;
                  break;
                case 'system':
                  icon = Icons.campaign;
                  color = colors.winter;
                  break;
                default:
                  icon = Icons.notifications;
                  color = colors.brand;
              }

              return Dismissible(
                key: ValueKey(notif.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: colors.err,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.delete, color: colors.ink),
                ),
                onDismissed: (_) {
                  ref
                      .read(dismissedNotificationsProvider.notifier)
                      .dismiss(notif.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الإشعار')),
                  );
                },
                child: AppCard(
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(14),
                  onTap: notif.route == null
                      ? null
                      : () => context.push(notif.route!),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTile(icon: icon, tint: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: AppTextStyles.title.copyWith(
                                      color: colors.ink,
                                    ),
                                  ),
                                ),
                                Text(
                                  formatter.format(notif.date),
                                  style: AppTextStyles.caption.copyWith(
                                    color: colors.ink3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.body,
                              style: AppTextStyles.bodyS.copyWith(
                                color: colors.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      AppIconButton(
                        icon: Icons.delete_outline,
                        tooltip: 'حذف الإشعار',
                        onPressed: () {
                          ref
                              .read(dismissedNotificationsProvider.notifier)
                              .dismiss(notif.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذر تحميل الإشعارات',
          message: 'خطأ: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(appNotificationsProvider),
        ),
      ),
    );
  }
}
