import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_settings_provider.dart';

const kAppPermissions = {
  'view_customers': 'رؤية العملاء والملفات',
  'view_apartments': 'رؤية الشقق والمحتويات',
  'checkout_winter': 'تسليم واستلام الشقق',
  'view_reports': 'التقارير المالية والملخصات',
  'manage_bookings': 'إضافة وإدارة الحجوزات (صيفي وشتوي)',
  'manage_maintenance': 'العمال والصيانة والفحص',
  'view_brokers': 'إدارة السماسرة والعمولات',
  'manage_expenses': 'إضافة المصروفات',
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
  return RolesConfig.fromJson(settings);
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
