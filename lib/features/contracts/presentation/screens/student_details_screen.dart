import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/contracts_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

class StudentDetailsScreen extends ConsumerWidget {
  final String contractId;

  const StudentDetailsScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(winterContractsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطالب'),
        actions: [
          contractsAsync.maybeWhen(
            data: (contracts) {
              final contract = contracts.firstWhere((c) => c.id == contractId, orElse: () => contracts.first);
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.go('/winter_contracts/edit', extra: contract);
                },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: contractsAsync.when(
        data: (contracts) {
          final contract = contracts.firstWhere(
            (c) => c.id == contractId,
            orElse: () => throw Exception('Contract not found'),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.person, size: 32, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contract.studentName,
                              style: theme.textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            if (contract.university != null)
                              Text(
                                contract.university!,
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            if (contract.parentPhone != null && contract.parentPhone!.isNotEmpty)
                              InkWell(
                                onTap: () async {
                                  final Uri launchUri = Uri(
                                    scheme: 'tel',
                                    path: contract.parentPhone!,
                                  );
                                  if (await canLaunchUrl(launchUri)) {
                                    await launchUrl(launchUri);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.call, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        contract.parentPhone!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contract Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('العقد الحالي', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const Divider(height: 24),
                      apartmentsAsync.when(
                        data: (apts) {
                          final apt = apts.firstWhere((a) => a.id == contract.apartmentId, orElse: () => apts.first);
                          return _buildDetailRow(context, 'الوحدة', 'شقة ${apt.apartmentNumber}');
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => _buildDetailRow(context, 'الوحدة', contract.apartmentId),
                      ),
                      Builder(
                        builder: (context) {
                          final months = (contract.endDate.year - contract.startDate.year) * 12 + contract.endDate.month - contract.startDate.month;
                          final monthsDisplay = months > 0 ? ' ($months شهور)' : '';
                          return _buildDetailRow(context, 'فترة العقد', '${contract.startDate.toLocal().toString().split(' ')[0]} إلى ${contract.endDate.toLocal().toString().split(' ')[0]}$monthsDisplay');
                        }
                      ),
                      _buildDetailRow(context, 'الإيجار الشهري', '${contract.monthlyRentEgp.toCurrencyFormat()} ج.م', isHighlight: true),
                      _buildDetailRow(context, 'التأمين', '${contract.depositEgp.toCurrencyFormat()} ج.م'),
                      if (contract.contractType == 'student' && contract.roommates != null && contract.roommates!.isNotEmpty)
                        ..._buildRoommatesList(context, contract.roommates!),
                      
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.bolt, color: theme.colorScheme.secondary, size: 16),
                          const SizedBox(width: 8),
                          Text('الكهرباء: على الطالب', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: theme.colorScheme.secondary, size: 16),
                          const SizedBox(width: 8),
                          Text('المياه: على المبنى', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      if (contract.contractFrontImage != null || contract.contractBackImage != null) ...[
                        const Divider(height: 24),
                        Text('صور العقد', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (contract.contractFrontImage != null)
                              Expanded(child: _buildImageCard(context, contract.contractFrontImage!, 'أمام')),
                            if (contract.contractBackImage != null)
                              Expanded(child: _buildImageCard(context, contract.contractBackImage!, 'خلف')),
                          ],
                        ),
                      ],
                      if (contract.idFrontImage != null || contract.idBackImage != null) ...[
                        const Divider(height: 24),
                        Text('صور البطاقة', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (contract.idFrontImage != null)
                              Expanded(child: _buildImageCard(context, contract.idFrontImage!, 'أمام')),
                            if (contract.idBackImage != null)
                              Expanded(child: _buildImageCard(context, contract.idBackImage!, 'خلف')),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Actions
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/winter_contracts/payments/$contractId');
                },
                icon: const Icon(Icons.payments),
                label: const Text('سجل المدفوعات'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (!contract.isActive) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/inspections/add?apartmentId=${contract.apartmentId}');
                  },
                  icon: const Icon(Icons.fact_check),
                  label: const Text('فحص واستلام الشقة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'آخر تعديل: ${contract.updatedAt.toLocal().toString().split('.')[0]}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: isHighlight 
                ? Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoommatesList(BuildContext context, String roommatesJsonStr) {
    try {
      final List<dynamic> roommates = jsonDecode(roommatesJsonStr);
      if (roommates.isEmpty) return [];

      return roommates.map((rm) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text('بيانات زميل السكن', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildDetailRow(context, 'الاسم', rm['name'] ?? ''),
            if (rm['university'] != null && rm['university'].toString().isNotEmpty)
              _buildDetailRow(context, 'الجامعة', rm['university']),
            if (rm['nationalId'] != null && rm['nationalId'].toString().isNotEmpty)
              _buildDetailRow(context, 'الرقم القومي', rm['nationalId']),
            if (rm['idFrontImage'] != null || rm['idBackImage'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (rm['idFrontImage'] != null)
                    Expanded(child: _buildImageCard(context, rm['idFrontImage'], 'بطاقة الزميل (أمام)')),
                  if (rm['idBackImage'] != null)
                    Expanded(child: _buildImageCard(context, rm['idBackImage'], 'بطاقة الزميل (خلف)')),
                ],
              ),
            ],
          ],
        );
      }).toList();
    } catch (e) {
      return [_buildDetailRow(context, 'زملاء السكن', roommatesJsonStr)];
    }
  }

  Widget _buildImageCard(BuildContext context, String imagePath, String label) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InteractiveViewer(
                    child: Image.file(File(imagePath), fit: BoxFit.contain),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
        child: Column(
          children: [
            Image.file(
              File(imagePath),
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 100,
                child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
