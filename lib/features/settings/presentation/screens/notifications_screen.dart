import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.notifications)),
              title: Text('تنبيه دفع إيجار - شقة ${101 + index}'),
              subtitle: const Text('موعد الدفع غداً'),
              trailing: const Text('منذ ساعتين'),
            ),
          );
        },
      ),
    );
  }
}
