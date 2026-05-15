import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/technicians_provider.dart';
import '../providers/maintenance_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class TechnicianDetailsScreen extends ConsumerWidget {
  final String technicianId;

  const TechnicianDetailsScreen({super.key, required this.technicianId});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techniciansAsync = ref.watch(techniciansProvider);
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل العامل')),
      body: techniciansAsync.when(
        data: (technicians) {
          final tech = technicians.firstWhere(
            (t) => t.id == technicianId,
            orElse: () => throw Exception('العامل غير موجود'),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Technician Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(Icons.engineering, size: 40, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(tech.name, style: theme.textTheme.headlineSmall),
                      Text(tech.specialty, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 16),
                      if (tech.phone != null && tech.phone!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(tech.phone!),
                          icon: const Icon(Icons.call),
                          label: Text(tech.phone!),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      if (tech.notes != null && tech.notes!.isNotEmpty) ...[
                        const Divider(height: 32),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text('تقييم / ملاحظات:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(tech.notes!),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('سجل أعمال الصيانة', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              
              // Maintenance History
              maintenanceAsync.when(
                data: (requests) {
                  final techRequests = requests.where((r) => r.technicianId == technicianId).toList();
                  final totalSystemRequestsCount = requests.length;
                  
                  if (techRequests.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('لم يقم بأي أعمال صيانة مسجلة حتى الآن'),
                      ),
                    );
                  }

                  techRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  final completedRequests = techRequests.where((r) => r.status == 'resolved').toList();
                  final sharePercentage = totalSystemRequestsCount == 0 ? 0.0 : (techRequests.length / totalSystemRequestsCount) * 100;
                  final totalCost = completedRequests.fold<double>(0, (sum, r) => sum + r.costEgp);

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const Text('إجمالي طلباته', style: TextStyle(fontSize: 12)),
                                    Text('${techRequests.length}', style: theme.textTheme.titleLarge),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const Text('نسبته من الشغل', style: TextStyle(fontSize: 12)),
                                    Text('${sharePercentage.toStringAsFixed(1)}%', style: theme.textTheme.titleLarge?.copyWith(color: Colors.green)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const Text('إجمالي ما تقاضاه', style: TextStyle(fontSize: 12)),
                                    Text('${totalCost.toCurrencyFormat()} ج', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: techRequests.length,
                        itemBuilder: (context, index) {
                          final req = techRequests[index];
                          final isResolved = req.status == 'resolved';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(req.issueDescription),
                              subtitle: Text(req.createdAt.toLocal().toString().split(' ')[0]),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isResolved ? 'مكتمل' : 'مفتوح',
                                    style: TextStyle(color: isResolved ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  if (isResolved && req.costEgp > 0)
                                    Text('${req.costEgp.toCurrencyFormat()} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('خطأ: $e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}
