import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/technicians_provider.dart';

import '../../../../core/database/tables.dart';

class TechniciansScreen extends ConsumerStatefulWidget {
  const TechniciansScreen({super.key});

  @override
  ConsumerState<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends ConsumerState<TechniciansScreen> {
  void _showAddEditDialog([dynamic technician]) {
    final nameController = TextEditingController(text: technician?.name ?? '');
    final specialtyController = TextEditingController(
      text: technician?.specialty ?? 'سباكة',
    );
    final phoneController = TextEditingController(
      text: technician?.phone ?? '',
    );
    final notesController = TextEditingController(
      text: technician?.notes ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          technician == null ? 'إضافة فني/عامل' : 'تعديل بيانات العامل',
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: specialtyController.text.isNotEmpty
                      ? specialtyController.text
                      : 'سباكة',
                  decoration: const InputDecoration(labelText: 'التخصص'),
                  items: ['سباكة', 'كهرباء', 'نجارة', 'نقاشة', 'نظافة', 'أخرى']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => specialtyController.text = v ?? 'أخرى',
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (phone.isEmpty) return null;
                    return RegExp(r'^01\d{9}$').hasMatch(phone)
                        ? null
                        : 'رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ 01';
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات / تقييم',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              if (technician == null) {
                ref
                    .read(techniciansControllerProvider.notifier)
                    .addTechnician(
                      name: nameController.text.trim(),
                      specialty: specialtyController.text,
                      phone: phoneController.text.trim(),
                      notes: notesController.text.trim(),
                    );
              } else {
                ref
                    .read(techniciansControllerProvider.notifier)
                    .updateTechnician(
                      technician.id,
                      name: nameController.text.trim(),
                      specialty: specialtyController.text,
                      phone: phoneController.text.trim(),
                      notes: notesController.text.trim(),
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final techniciansAsync = ref.watch(techniciansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('العمال والفنيين')),
      body: techniciansAsync.when(
        data: (technicians) {
          final activeTechnicians = technicians
              .where((t) => t.syncStatus != SyncStatus.pendingDelete)
              .toList();

          if (activeTechnicians.isEmpty) {
            return const Center(child: Text('لا يوجد فنيين مسجلين'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeTechnicians.length,
            itemBuilder: (context, index) {
              final tech = activeTechnicians[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => context.go('/technicians/details/${tech.id}'),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getIconForSpecialty(tech.specialty)),
                    ),
                    title: Text(tech.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('التخصص: ${tech.specialty}'),
                        if (tech.phone != null && tech.phone!.isNotEmpty)
                          Text('الهاتف: ${tech.phone}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tech.phone != null && tech.phone!.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () => _makePhoneCall(tech.phone!),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(tech),
                        ),
                      ],
                    ),
                    isThreeLine: tech.phone != null && tech.phone!.isNotEmpty,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForSpecialty(String specialty) {
    switch (specialty) {
      case 'سباكة':
        return Icons.plumbing;
      case 'كهرباء':
        return Icons.electrical_services;
      case 'نجارة':
        return Icons.handyman;
      case 'نظافة':
        return Icons.cleaning_services;
      case 'نقاشة':
        return Icons.format_paint;
      default:
        return Icons.person;
    }
  }
}
