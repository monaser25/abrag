import 'dart:convert';

class InventoryItem {
  final String group;
  final String name;

  const InventoryItem({required this.group, required this.name});

  Map<String, dynamic> toJson() => {'group': group, 'name': name};

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    group: json['group']?.toString() ?? 'عام',
    name: json['name']?.toString() ?? '',
  );

  static List<InventoryItem> parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback for old \n or , separated data
      final separator = raw.contains('\n') ? '\n' : ',';
      return raw
          .split(separator)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => InventoryItem(group: 'عام', name: e))
          .toList();
    }
    return [];
  }

  static String serialize(List<InventoryItem> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }
}
