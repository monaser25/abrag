import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';
import '../../../../core/config/env.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
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

                    if (email.isEmpty ||
                        password.isEmpty ||
                        selectedTemplate == null) {
                      return;
                    }

                    Navigator.pop(ctx);

                    this.setState(() => _isLoading = true);
                    try {
                      // Use a secondary client to avoid logging out the admin
                      final secondaryClient = SupabaseClient(
                        Env.supabaseUrl,
                        Env.supabaseAnonKey,
                      );
                      final response = await secondaryClient.auth.signUp(
                        email: email,
                        password: password,
                      );
                      final user = response.user;
                      if (user != null) {
                        // Insert into DB as staff
                        final db = ref.read(databaseProvider);
                        await db
                            .into(db.userProfiles)
                            .insert(
                              UserProfilesCompanion.insert(
                                id: user.id,
                                email: email,
                                fullName: Value(name),
                                role: const Value('staff'),
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                syncStatus: const Value(
                                  SyncStatus.pendingInsert,
                                ),
                              ),
                              mode: InsertMode.insertOrReplace,
                            );
                        // Assign custom role
                        await ref
                            .read(rolesConfigControllerProvider)
                            .assignUserRole(user.id, selectedTemplate);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إنشاء المستخدم بنجاح!'),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
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
                                : IconButton(
                                    icon: const Icon(Icons.settings),
                                    onPressed: () async {
                                      // Change assigned template
                                      String? newTemplate = customRole;
                                      final templates = rolesConfig
                                          .roleTemplates
                                          .keys
                                          .toList();
                                      await showDialog(
                                        context: context,
                                        builder: (ctx) => StatefulBuilder(
                                          builder: (ctx, setState) => AlertDialog(
                                            title: Text(
                                              'تعديل صلاحية ${user.fullName}',
                                            ),
                                            content:
                                                DropdownButtonFormField<String>(
                                                  initialValue: newTemplate,
                                                  items: [
                                                    const DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: null,
                                                      child: Text(
                                                        'بدون صلاحيات مخصصة (مراقب)',
                                                      ),
                                                    ),
                                                    ...templates.map(
                                                      (t) => DropdownMenuItem(
                                                        value: t,
                                                        child: Text(t),
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (v) => setState(
                                                    () => newTemplate = v,
                                                  ),
                                                ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('إلغاء'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  ref
                                                      .read(
                                                        rolesConfigControllerProvider,
                                                      )
                                                      .assignUserRole(
                                                        user.id,
                                                        newTemplate,
                                                      );
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text('حفظ'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
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
