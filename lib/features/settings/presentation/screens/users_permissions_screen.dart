import 'package:flutter/material.dart' hide Column;
import 'package:flutter/material.dart' as mat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/utils/error_dialog.dart';
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
              title: const Text('إضافة نموذج صلاحيات (Role)'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم النموذج (مثال: مستقبل عملاء)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الصلاحيات المتاحة:',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty && selectedPerms.isNotEmpty) {
                      ref
                          .read(rolesConfigControllerProvider)
                          .saveTemplate(name, selectedPerms.toList());
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
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
              title: const Text('إضافة مستخدم جديد'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'الاسم'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'اختر نموذج الصلاحيات',
                      ),
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
                ElevatedButton(
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
                  child: const Text('إنشاء الحساب'),
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
                      TextField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'الاسم'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'كلمة مرور جديدة',
                          helperText: 'اتركها فارغة لو مش عايز تغيرها',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: newTemplate,
                        decoration: const InputDecoration(
                          labelText: 'نموذج الصلاحيات',
                        ),
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
              ElevatedButton(
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
                child: const Text('حفظ'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمين والصلاحيات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المستخدمين'),
            Tab(text: 'نماذج الصلاحيات (Roles)'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
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
                      padding: const EdgeInsets.all(16),
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

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSuperAdmin
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : Colors.blue.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.person,
                                color: isSuperAdmin
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                            ),
                            title: Text(
                              user.fullName?.isNotEmpty == true
                                  ? user.fullName!
                                  : user.email,
                            ),
                            subtitle: Text(roleLabel),
                            trailing: isSuperAdmin
                                ? null
                                : Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        tooltip: 'تعديل المستخدم',
                                        icon: const Icon(Icons.settings),
                                        onPressed: () => _editUser(
                                          user,
                                          customRole,
                                          rolesConfig.roleTemplates.keys
                                              .toList(),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteUser(user),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),

                // Templates Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (rolesConfig.roleTemplates.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('لا توجد نماذج صلاحيات حتى الآن.'),
                        ),
                      ),
                    ...rolesConfig.roleTemplates.entries.map((entry) {
                      return Card(
                        child: ExpansionTile(
                          title: Text(
                            '💼 ${entry.key}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${entry.value.length} صلاحيات'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: entry.value.map((perm) {
                                  final label = kAppPermissions[perm] ?? perm;
                                  return Chip(
                                    label: Text(
                                      label,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            OverflowBar(
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: Text(
                                          'هل تريد حذف النموذج "${entry.key}"؟ سيتم تجريد المستخدمين المرتبطين به من الصلاحيات.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('إلغاء'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('حذف'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      ref
                                          .read(rolesConfigControllerProvider)
                                          .deleteTemplate(entry.key);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'حذف النموذج',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _createTemplate,
                      icon: const Icon(Icons.add),
                      label: const Text('إنشاء نموذج صلاحيات جديد'),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _createUser(rolesConfig.roleTemplates.keys.toList()),
              icon: const Icon(Icons.person_add),
              label: const Text('مستخدم جديد'),
            )
          : null,
    );
  }
}
