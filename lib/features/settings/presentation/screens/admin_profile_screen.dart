import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../../shared/widgets/widgets.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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

    return AppScaffold(
      appBar: const AbragAppBar(title: 'الملف الشخصي'),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'بيانات المستخدم غير متاحة',
            );
          }

          if (!_initialized) {
            _nameController.text = profile.fullName ?? '';
            _emailController.text = profile.email;
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Center(
                child: AppAvatar(
                  name: profile.fullName ?? profile.email,
                  size: 96,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nameController,
                label: 'الاسم الكامل',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                prefixIcon: Icons.email_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'تحديث البيانات',
                icon: Icons.save_outlined,
                expand: true,
                loading: controllerState.isLoading,
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
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذّر تحميل الملف',
          message: 'Error: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(currentUserProfileProvider),
        ),
      ),
    );
  }
}
