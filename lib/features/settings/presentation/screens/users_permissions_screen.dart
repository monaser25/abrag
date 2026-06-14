import 'package:flutter/material.dart' hide Column;
import 'package:flutter/material.dart' as mat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/error_dialog.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';
import '../providers/permissions_provider.dart';

final allUsersProvider = StreamProvider<List<UserProfile>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.userProfiles).watch();
});

class UsersPermissionsScreen extends ConsumerStatefulWidget {
  const UsersPermissionsScreen({super.key});

  @override
  ConsumerState<UsersPermissionsScreen> createState() =>
      _UsersPermissionsScreenState();
}

class _UsersPermissionsScreenState extends ConsumerState<UsersPermissionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createTemplate() async {
    final nameController = TextEditingController();
    final selectedPerms = <String>{};

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: context.colors.surface,
              title: const Text('إضافة نموذج صلاحيات (Role)'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    AppTextField(
                      controller: nameController,
                      label: 'اسم النموذج (مثال: مستقبل عملاء)',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'الصلاحيات المتاحة:',
                      style: AppTextStyles.label
                          .copyWith(color: context.colors.ink2),
                    ),
                    ...kAppPermissions.entries.map((e) {
                      return CheckboxListTile(
                        title: Text(e.value),
                        value: selectedPerms.contains(e.key),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedPerms.add(e.key);
                            } else {
                              selectedPerms.remove(e.key);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                AppButton(
                  label: 'حفظ',
                  small: true,
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty && selectedPerms.isNotEmpty) {
                      ref
                          .read(rolesConfigControllerProvider)
                          .saveTemplate(name, selectedPerms.toList());
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editTemplate(
    String templateName,
    List<String> permissions,
  ) async {
    final nameController = TextEditingController(text: templateName);
    final selectedPerms = permissions.toSet();

    try {
      await showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: context.colors.surface,
                title: const Text('تعديل نموذج الصلاحيات'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      AppTextField(
                        controller: nameController,
                        label: 'اسم النموذج',
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'الصلاحيات المتاحة:',
                        style: AppTextStyles.label
                            .copyWith(color: context.colors.ink2),
                      ),
                      ...kAppPermissions.entries.map((entry) {
                        return CheckboxListTile(
                          title: Text(entry.value),
                          value: selectedPerms.contains(entry.key),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedPerms.add(entry.key);
                              } else {
                                selectedPerms.remove(entry.key);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء'),
                  ),
                  AppButton(
                    label: 'حفظ التعديل',
                    small: true,
                    onPressed: () async {
                      final newName = nameController.text.trim();
                      if (newName.isEmpty || selectedPerms.isEmpty) {
                        showErrorDialog(
                          context,
                          'اسم النموذج والصلاحيات مطلوبين.',
                        );
                        return;
                      }
                      await ref
                          .read(rolesConfigControllerProvider)
                          .updateTemplate(
                            oldTemplateName: templateName,
                            newTemplateName: newName,
                            permissions: selectedPerms.toList(),
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _createUser(List<String> availableTemplates) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    String? selectedTemplate;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: context.colors.surface,
              title: const Text('إضافة مستخدم جديد'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    AppTextField(
                      controller: nameController,
                      label: 'الاسم',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: emailController,
                      label: 'البريد الإلكتروني',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: passwordController,
                      label: 'كلمة المرور',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    AppDropdownField<String>(
                      label: 'اختر نموذج الصلاحيات',
                      prefixIcon: Icons.shield_outlined,
                      initialValue: selectedTemplate,
                      items: availableTemplates
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedTemplate = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                AppButton(
                  label: 'إنشاء الحساب',
                  small: true,
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text;
                    final name = nameController.text.trim();

                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (email.isEmpty || !emailRegex.hasMatch(email)) {
                      showErrorDialog(context, 'البريد الإلكتروني غير صحيح.');
                      return;
                    }
                    if (password.length < 6) {
                      showErrorDialog(
                        context,
                        'كلمة المرور يجب ألا تقل عن 6 حروف.',
                      );
                      return;
                    }
                    if (selectedTemplate == null) {
                      showErrorDialog(context, 'الرجاء اختيار نموذج صلاحيات.');
                      return;
                    }

                    Navigator.pop(ctx);

                    this.setState(() => _isLoading = true);
                    try {
                      final userId = await _createAuthUser(
                        email: email,
                        password: password,
                        fullName: name,
                      );

                      final db = ref.read(databaseProvider);
                      await db
                          .into(db.userProfiles)
                          .insertOnConflictUpdate(
                            UserProfilesCompanion.insert(
                              id: userId,
                              email: email,
                              fullName: Value(name),
                              role: const Value('staff'),
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              syncStatus: const Value(SyncStatus.synced),
                            ),
                          );
                      await ref
                          .read(rolesConfigControllerProvider)
                          .assignUserRole(userId, selectedTemplate);
                      ref.invalidate(allUsersProvider);

                      if (mounted) {
                        showErrorDialog(
                          this.context,
                          'تم إنشاء حساب الدخول وحفظ الصلاحيات بنجاح.',
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        showErrorDialog(this.context, 'خطأ:\n$e');
                      }
                    } finally {
                      if (mounted) this.setState(() => _isLoading = false);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String> _createAuthUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'create-app-user',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': 'staff',
      },
    );

    final data = response.data;
    if (data is Map && data['id'] != null) return data['id'].toString();
    final message = data is Map && data['error'] != null
        ? data['error'].toString()
        : 'تعذر إنشاء المستخدم. تأكد من نشر دالة create-app-user في Supabase.';
    throw Exception(message);
  }

  Future<void> _updateAuthUser({
    required String userId,
    required String email,
    required String fullName,
    required String role,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'role': role,
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await Supabase.instance.client.functions
        .invoke('update-app-user', body: body)
        .catchError((Object error) {
          final message = error.toString();
          if (message.contains('404') || message.contains('NOT_FOUND')) {
            throw Exception(
              'تعديل البريد الإلكتروني أو كلمة المرور يحتاج نشر دالة update-app-user في Supabase أولاً.',
            );
          }
          throw error;
        });

    final data = response.data;
    if (data is Map && data['error'] != null) {
      throw Exception(data['error']);
    }
    if (data is! Map || data['ok'] != true) {
      throw Exception(
        'تعذر تعديل المستخدم. تأكد من نشر دالة update-app-user في Supabase.',
      );
    }
  }

  Future<void> _deleteUser(UserProfile user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surface,
        title: const Text('حذف المستخدم'),
        content: Text(
          'هل تريد حذف ${user.fullName?.isNotEmpty == true ? user.fullName : user.email}؟ سيتم حذف حساب الدخول والصلاحيات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'delete-app-user',
        body: {'userId': user.id},
      );
      final data = response.data;
      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      final db = ref.read(databaseProvider);
      await (db.delete(
        db.userProfiles,
      )..where((t) => t.id.equals(user.id))).go();
      await ref
          .read(rolesConfigControllerProvider)
          .assignUserRole(user.id, null);

      if (mounted) {
        showErrorDialog(context, 'تم حذف المستخدم بنجاح.');
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, 'تعذر حذف المستخدم:\n$e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editUser(
    UserProfile user,
    String? currentTemplate,
    List<String> availableTemplates,
  ) async {
    final nameController = TextEditingController(text: user.fullName ?? '');
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    String? newTemplate = currentTemplate;

    try {
      await showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, dialogSetState) => AlertDialog(
            backgroundColor: ctx.colors.surface,
            title: const Text('تعديل المستخدم والصلاحية'),
            content: SizedBox(
              width: double.maxFinite,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.65,
                ),
                child: SingleChildScrollView(
                  child: mat.Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        controller: nameController,
                        label: 'الاسم',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: emailController,
                        label: 'البريد الإلكتروني',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: passwordController,
                        label: 'كلمة مرور جديدة',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        helperText: 'اتركها فارغة لو مش عايز تغيرها',
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<String>(
                        label: 'نموذج الصلاحيات',
                        prefixIcon: Icons.shield_outlined,
                        initialValue: newTemplate,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'بدون صلاحيات مخصصة (مراقب)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ...availableTemplates.map(
                            (template) => DropdownMenuItem<String>(
                              value: template,
                              child: Text(
                                template,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            dialogSetState(() => newTemplate = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              AppButton(
                label: 'حفظ',
                small: true,
                onPressed: () async {
                  final fullName = nameController.text.trim();
                  final email = emailController.text.trim().toLowerCase();
                  final password = passwordController.text;
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );

                  if (fullName.isEmpty) {
                    showErrorDialog(context, 'الاسم مطلوب.');
                    return;
                  }
                  if (email.isEmpty || !emailRegex.hasMatch(email)) {
                    showErrorDialog(context, 'البريد الإلكتروني غير صحيح.');
                    return;
                  }
                  if (password.isNotEmpty && password.length < 6) {
                    showErrorDialog(
                      context,
                      'كلمة المرور يجب ألا تقل عن 6 حروف.',
                    );
                    return;
                  }

                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);

                  try {
                    final currentEmail = user.email.trim().toLowerCase();
                    final currentFullName = user.fullName?.trim() ?? '';
                    final emailChanged = email != currentEmail;
                    final nameChanged = fullName != currentFullName;
                    final passwordChanged = password.isNotEmpty;

                    if (emailChanged || passwordChanged) {
                      await _updateAuthUser(
                        userId: user.id,
                        email: email,
                        fullName: fullName,
                        role: user.role,
                        password: password.isEmpty ? null : password,
                      );
                    }

                    final db = ref.read(databaseProvider);
                    if (emailChanged || nameChanged) {
                      await (db.update(
                        db.userProfiles,
                      )..where((t) => t.id.equals(user.id))).write(
                        UserProfilesCompanion(
                          email: Value(email),
                          fullName: Value(fullName),
                          updatedAt: Value(DateTime.now()),
                          syncStatus: Value(
                            emailChanged
                                ? SyncStatus.synced
                                : SyncStatus.pendingUpdate,
                          ),
                        ),
                      );
                    }

                    await ref
                        .read(rolesConfigControllerProvider)
                        .assignUserRole(user.id, newTemplate);
                    ref.invalidate(allUsersProvider);

                    if (mounted) {
                      showErrorDialog(
                        context,
                        'تم تعديل بيانات المستخدم بنجاح.',
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      showErrorDialog(context, 'تعذر تعديل المستخدم:\n$e');
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ],
          ),
        ),
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      passwordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final rolesConfig = ref.watch(rolesConfigProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: const AbragAppBar(title: 'المستخدمين والصلاحيات'),
      floatingActionButton: _tabController.index == 0
          ? AppFab(
              onPressed: () =>
                  _createUser(rolesConfig.roleTemplates.keys.toList()),
              icon: Icons.person_add,
              label: 'مستخدم جديد',
            )
          : null,
      body: _isLoading
          ? const LoadingSkeleton()
          : mat.Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(AppRadius.segTrack),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.segItem),
                      boxShadow: AppShadows.sm,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: colors.ink,
                    unselectedLabelColor: colors.ink2,
                    labelStyle: AppTextStyles.label,
                    tabs: const [
                      Tab(text: 'المستخدمين'),
                      Tab(text: 'نماذج الصلاحيات (Roles)'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Users Tab
                      usersAsync.when(
                        data: (users) {
                          final activeUsers = users
                              .where(
                                (u) =>
                                    u.role == 'admin' ||
                                    u.role == 'staff' ||
                                    u.role == 'viewer',
                              )
                              .toList();
                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                            itemCount: activeUsers.length,
                            itemBuilder: (context, index) {
                              final user = activeUsers[index];
                              final isSuperAdmin = user.role == 'admin';
                              final customRole = rolesConfig.userRoles[user.id];

                              String roleLabel = 'مراقب';
                              if (isSuperAdmin) {
                                roleLabel = '👑 مدير النظام (Super Admin)';
                              } else if (customRole != null) {
                                roleLabel = '💼 $customRole';
                              }

                              final displayName =
                                  user.fullName?.isNotEmpty == true
                                  ? user.fullName!
                                  : user.email;

                              return AppCard(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    AppAvatar(
                                      name: displayName,
                                      tint: isSuperAdmin
                                          ? colors.accent
                                          : colors.brand,
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: mat.Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: AppTextStyles.title
                                                .copyWith(color: colors.ink),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            roleLabel,
                                            style: AppTextStyles.caption
                                                .copyWith(color: colors.ink2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isSuperAdmin) ...[
                                      AppIconButton(
                                        tooltip: 'تعديل المستخدم',
                                        icon: Icons.settings_outlined,
                                        onPressed: () => _editUser(
                                          user,
                                          customRole,
                                          rolesConfig.roleTemplates.keys
                                              .toList(),
                                        ),
                                      ),
                                      AppIconButton(
                                        icon: Icons.delete_outline,
                                        onPressed: () => _deleteUser(user),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const LoadingSkeleton(),
                        error: (e, st) => ErrorState(
                          title: 'تعذّر تحميل المستخدمين',
                          message: 'Error: $e',
                          retryLabel: 'إعادة المحاولة',
                          onRetry: () => ref.invalidate(allUsersProvider),
                        ),
                      ),

                      // Templates Tab
                      ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        children: [
                          if (rolesConfig.roleTemplates.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: EmptyState(
                                icon: Icons.shield_outlined,
                                title: 'لا توجد نماذج صلاحيات حتى الآن.',
                              ),
                            ),
                          ...rolesConfig.roleTemplates.entries.map((entry) {
                            return AppCard(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.zero,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  shape: const Border(),
                                  collapsedShape: const Border(),
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  iconColor: colors.ink2,
                                  collapsedIconColor: colors.ink3,
                                  title: Text(
                                    '💼 ${entry.key}',
                                    style: AppTextStyles.title
                                        .copyWith(color: colors.ink),
                                  ),
                                  subtitle: Text(
                                    '${entry.value.length} صلاحيات',
                                    style: AppTextStyles.caption
                                        .copyWith(color: colors.ink3),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        4,
                                        16,
                                        8,
                                      ),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: entry.value.map((perm) {
                                          final label =
                                              kAppPermissions[perm] ?? perm;
                                          return StatusChip(
                                            label: label,
                                            kind: StatusChipKind.neutral,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    OverflowBar(
                                      children: [
                                        AppButton(
                                          label: 'تعديل النموذج',
                                          icon: Icons.edit_outlined,
                                          variant: AppButtonVariant.ghost,
                                          small: true,
                                          onPressed: () => _editTemplate(
                                            entry.key,
                                            entry.value,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                backgroundColor:
                                                    ctx.colors.surface,
                                                title:
                                                    const Text('تأكيد الحذف'),
                                                content: Text(
                                                  'هل تريد حذف النموذج "${entry.key}"؟ سيتم تجريد المستخدمين المرتبطين به من الصلاحيات.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: const Text('إلغاء'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    child: const Text('حذف'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              ref
                                                  .read(
                                                    rolesConfigControllerProvider,
                                                  )
                                                  .deleteTemplate(entry.key);
                                            }
                                          },
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: colors.err,
                                          ),
                                          label: Text(
                                            'حذف النموذج',
                                            style: TextStyle(color: colors.err),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'إنشاء نموذج صلاحيات جديد',
                            icon: Icons.add,
                            variant: AppButtonVariant.royal,
                            expand: true,
                            onPressed: _createTemplate,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
