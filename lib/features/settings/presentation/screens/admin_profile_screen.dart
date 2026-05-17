import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../users/presentation/providers/users_provider.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  final _nameController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final controllerState = ref.watch(userProfileControllerProvider);

    ref.listen<AsyncValue<void>>(userProfileControllerProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
          );
        },
        error: (e, st) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('بيانات المستخدم غير متاحة'));
          }

          if (!_initialized) {
            _nameController.text = profile.fullName ?? '';
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: profile.email,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                ),
                readOnly: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () {
                        ref
                            .read(userProfileControllerProvider.notifier)
                            .updateName(
                              id: profile.id,
                              fullName: _nameController.text,
                            );
                      },
                child: controllerState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('تحديث البيانات'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
