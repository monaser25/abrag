import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_settings_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../users/presentation/providers/users_provider.dart';

const kAppPermissions = {
  'view_dashboard': 'رؤية لوحة التحكم',
  'view_search': 'استخدام البحث العام',
  'view_notifications': 'رؤية التنبيهات',
  'view_customers': 'رؤية العملاء والملفات',
  'manage_customers': 'تعديل وإدارة بيانات العملاء',
  'view_apartments': 'رؤية الشقق والمحتويات',
  'manage_apartments': 'إضافة وتعديل الشقق والمباني والجرد',
  'manage_cleaning_status': 'تعديل حالة النظافة للشقق',
  'manage_bookings': 'إضافة وإدارة الحجوزات الصيفي',
  'view_bookings': 'رؤية الحجوزات الصيفي (قراءة فقط)',
  'manage_contracts': 'إضافة وإدارة عقود الشتوي',
  'view_contract_documents': 'رؤية صور العقود والبطاقات',
  'checkout_winter': 'تسليم واستلام الشقق',
  'view_reports': 'رؤية التقارير المالية والملخصات',
  'export_reports': 'تصدير التقارير وملفات PDF',
  'view_system_log': 'رؤية سجل أنشطة النظام',
  'view_expenses': 'رؤية المصروفات والمدفوعات',
  'manage_expenses': 'إضافة وتعديل المصروفات',
  'manage_building_rent': 'إدارة أقساط إيجار المبنى',
  'manage_financial_transfers': 'إدارة الخزنة والتحويلات',
  'view_brokers': 'رؤية السماسرة والعمولات',
  'manage_brokers': 'إضافة وتعديل السماسرة والتحكم في الرؤية',
  'view_maintenance': 'رؤية الصيانة والفحص',
  'manage_maintenance': 'إدارة العمال والصيانة والفحص',
  'manage_cleaning_supplies': 'إدارة مخزون وأدوات النظافة',
  'manage_users': 'إدارة المستخدمين والصلاحيات',
  'manage_settings': 'تعديل إعدادات التطبيق',
  'manage_data': 'تصدير واستيراد ومسح البيانات',
};

const kDefaultRoleTemplates = {
  'موظف استقبال': [
    'view_dashboard',
    'view_search',
    'view_notifications',
    'view_customers',
    'manage_customers',
    'view_apartments',
    'manage_bookings',
    'manage_contracts',
    'view_contract_documents',
  ],
  'محاسب': [
    'view_dashboard',
    'view_notifications',
    'view_reports',
    'export_reports',
    'view_expenses',
    'manage_expenses',
    'manage_building_rent',
    'manage_financial_transfers',
  ],
  'مسؤول صيانة': [
    'view_dashboard',
    'view_notifications',
    'view_apartments',
    'manage_cleaning_status',
    'checkout_winter',
    'view_maintenance',
    'manage_maintenance',
    'manage_cleaning_supplies',
  ],
  'مراقب قراءة فقط': [
    'view_dashboard',
    'view_search',
    'view_customers',
    'view_apartments',
    'view_reports',
    'view_brokers',
    'view_maintenance',
    'view_bookings',
  ],
};

class RolesConfig {
  final Map<String, List<String>> roleTemplates;
  final Map<String, String> userRoles;

  RolesConfig({required this.roleTemplates, required this.userRoles});

  factory RolesConfig.fromJson(Map<String, dynamic> json) {
    final rt = <String, List<String>>{};
    if (json['roles'] != null) {
      final map = json['roles'] as Map;
      map.forEach((k, v) {
        if (v is List) rt[k.toString()] = v.map((e) => e.toString()).toList();
      });
    }
    final ur = <String, String>{};
    if (json['user_roles'] != null) {
      final map = json['user_roles'] as Map;
      map.forEach((k, v) => ur[k.toString()] = v.toString());
    }
    return RolesConfig(roleTemplates: rt, userRoles: ur);
  }

  Map<String, dynamic> toJson() {
    return {'roles': roleTemplates, 'user_roles': userRoles};
  }
}

final rolesConfigProvider = Provider<RolesConfig>((ref) {
  final settings = ref.watch(appSettingsProvider).value ?? {};
  final config = RolesConfig.fromJson(settings);
  return RolesConfig(
    roleTemplates: {...kDefaultRoleTemplates, ...config.roleTemplates},
    userRoles: config.userRoles,
  );
});

class RolesConfigController {
  final Ref _ref;
  RolesConfigController(this._ref);

  Future<void> saveTemplate(
    String templateName,
    List<String> permissions,
  ) async {
    final current = _ref.read(rolesConfigProvider);
    final newTemplates = Map<String, List<String>>.from(current.roleTemplates);
    newTemplates[templateName] = permissions;

    final newConfig = RolesConfig(
      roleTemplates: newTemplates,
      userRoles: current.userRoles,
    );
    final settings = _ref.read(appSettingsProvider).value ?? {};
    settings.addAll(newConfig.toJson());
    await _ref.read(appSettingsControllerProvider).updateSettings(settings);
  }

  Future<void> deleteTemplate(String templateName) async {
    final current = _ref.read(rolesConfigProvider);
    final newTemplates = Map<String, List<String>>.from(current.roleTemplates);
    newTemplates.remove(templateName);

    // Also remove this template from users who had it
    final newUserRoles = Map<String, String>.from(current.userRoles);
    newUserRoles.removeWhere((key, value) => value == templateName);

    final newConfig = RolesConfig(
      roleTemplates: newTemplates,
      userRoles: newUserRoles,
    );
    final settings = _ref.read(appSettingsProvider).value ?? {};
    settings.addAll(newConfig.toJson());
    await _ref.read(appSettingsControllerProvider).updateSettings(settings);
  }

  Future<void> updateTemplate({
    required String oldTemplateName,
    required String newTemplateName,
    required List<String> permissions,
  }) async {
    final current = _ref.read(rolesConfigProvider);
    final newTemplates = Map<String, List<String>>.from(current.roleTemplates);
    final newUserRoles = Map<String, String>.from(current.userRoles);

    if (oldTemplateName != newTemplateName) {
      newTemplates.remove(oldTemplateName);
      newUserRoles.updateAll(
        (userId, templateName) =>
            templateName == oldTemplateName ? newTemplateName : templateName,
      );
    }

    newTemplates[newTemplateName] = permissions;

    final newConfig = RolesConfig(
      roleTemplates: newTemplates,
      userRoles: newUserRoles,
    );
    final settings = _ref.read(appSettingsProvider).value ?? {};
    settings.addAll(newConfig.toJson());
    await _ref.read(appSettingsControllerProvider).updateSettings(settings);
  }

  Future<void> assignUserRole(String userId, String? templateName) async {
    final current = _ref.read(rolesConfigProvider);
    final newUserRoles = Map<String, String>.from(current.userRoles);
    if (templateName == null) {
      newUserRoles.remove(userId);
    } else {
      newUserRoles[userId] = templateName;
    }

    final newConfig = RolesConfig(
      roleTemplates: current.roleTemplates,
      userRoles: newUserRoles,
    );
    final settings = _ref.read(appSettingsProvider).value ?? {};
    settings.addAll(newConfig.toJson());
    await _ref.read(appSettingsControllerProvider).updateSettings(settings);
  }
}

final rolesConfigControllerProvider = Provider(
  (ref) => RolesConfigController(ref),
);

/// The set of permission IDs that the current user has, based on their
/// assigned permission-template. Mirrors the inline `hasPerm` logic in
/// dashboard_screen.dart:
///   - base-role 'admin'  → all permissions
///   - template assigned  → that template's permission set
///   - no template / not signed in → empty set
final currentUserPermissionsProvider = Provider<Set<String>>((ref) {
  final role = ref.watch(currentUserRoleProvider).value;
  if (role == 'admin') return kAppPermissions.keys.toSet();

  final userId = ref.watch(authStateProvider).value?.session?.user.id;
  if (userId == null) return const {};

  final rolesConfig = ref.watch(rolesConfigProvider);
  final templateName = rolesConfig.userRoles[userId];
  if (templateName == null) return const {};

  final perms = rolesConfig.roleTemplates[templateName] ?? [];
  return perms.toSet();
});

/// `true` when the current user may create/edit/delete summer bookings.
final canManageBookingsProvider = Provider<bool>((ref) {
  return ref.watch(currentUserPermissionsProvider).contains('manage_bookings');
});

/// `true` when the current user may at least VIEW summer bookings
/// (either manage_bookings OR view_bookings is in their permission set).
final canViewBookingsProvider = Provider<bool>((ref) {
  final perms = ref.watch(currentUserPermissionsProvider);
  return perms.contains('manage_bookings') || perms.contains('view_bookings');
});
