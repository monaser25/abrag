import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/contracts_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

class StudentDetailsScreen extends ConsumerWidget {
  final String contractId;

  const StudentDetailsScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(allWinterContractsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'تفاصيل الطالب',
        actions: [
          contractsAsync.maybeWhen(
            data: (contracts) {
              final contract = contracts.firstWhere(
                (c) => c.id == contractId,
                orElse: () => contracts.first,
              );
              return AppIconButton(
                icon: Icons.edit_outlined,
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
          final academicInfo = _parseAcademicInfo(contract.university);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header (prototype winter-soft header card)
              AppCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: AppRadius.rMd,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    color: context.colors.winterSoft,
                    child: Row(
                    children: [
                      AppAvatar(
                        name: contract.studentName,
                        size: 56,
                        tint: context.colors.winter,
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
                            if (academicInfo.$1.isNotEmpty ||
                                academicInfo.$2.isNotEmpty)
                              Text(
                                [
                                  if (academicInfo.$1.isNotEmpty)
                                    academicInfo.$1,
                                  if (academicInfo.$2.isNotEmpty)
                                    academicInfo.$2,
                                ].join(' - '),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            if (contract.parentPhone != null &&
                                contract.parentPhone!.isNotEmpty)
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
                                      Icon(
                                        Icons.call,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        contract.parentPhone!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              decoration:
                                                  TextDecoration.underline,
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
                          Icon(
                            Icons.description,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'العقد الحالي',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      apartmentsAsync.when(
                        data: (apts) {
                          final apt = apts.firstWhere(
                            (a) => a.id == contract.apartmentId,
                            orElse: () => apts.first,
                          );
                          return _buildDetailRow(
                            context,
                            'الوحدة',
                            'شقة ${apt.apartmentNumber}',
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => _buildDetailRow(
                          context,
                          'الوحدة',
                          contract.apartmentId,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final months =
                              (contract.endDate.year -
                                      contract.startDate.year) *
                                  12 +
                              contract.endDate.month -
                              contract.startDate.month;
                          final monthsDisplay = months > 0
                              ? ' ($months شهور)'
                              : '';
                          return _buildDetailRow(
                            context,
                            'فترة العقد',
                            '${contract.startDate.toLocal().toString().split(' ')[0]} إلى ${contract.endDate.toLocal().toString().split(' ')[0]}$monthsDisplay',
                          );
                        },
                      ),
                      _buildDetailRow(
                        context,
                        'الإيجار الشهري',
                        '${contract.monthlyRentEgp.toCurrencyFormat()} ج.م',
                        isHighlight: true,
                      ),
                      _buildDetailRow(
                        context,
                        'التأمين',
                        '${contract.depositEgp.toCurrencyFormat()} ج.م',
                      ),
                      if (academicInfo.$1.isNotEmpty)
                        _buildDetailRow(context, 'الجامعة', academicInfo.$1),
                      if (academicInfo.$2.isNotEmpty)
                        _buildDetailRow(context, 'الكلية', academicInfo.$2),
                      if (contract.nationalId != null &&
                          contract.nationalId!.isNotEmpty)
                        _buildDetailRow(
                          context,
                          'الرقم القومي',
                          contract.nationalId!,
                        ),
                      if (contract.nationalId != null &&
                          contract.nationalId!.isNotEmpty)
                        ..._buildNationalIdRows(context, contract.nationalId!),
                      if (contract.contractType == 'student' &&
                          contract.roommates != null &&
                          contract.roommates!.isNotEmpty)
                        ..._buildRoommatesList(context, contract.roommates!),

                      const Divider(height: 24),
                      // Utility split (prototype pattern: tenant/owner chips)
                      _UtilityRow(
                        icon: Icons.bolt,
                        label: 'الكهرباء',
                        onTenant: contract.isElectricityOnStudent,
                      ),
                      const SizedBox(height: 8),
                      _UtilityRow(
                        icon: Icons.local_fire_department,
                        label: 'الغاز',
                        onTenant: contract.isGasOnStudent,
                      ),
                      const SizedBox(height: 8),
                      _UtilityRow(
                        icon: Icons.water_drop,
                        label: 'المياه',
                        onTenant: contract.isWaterOnStudent,
                      ),
                      if (contract.contractFrontImage != null ||
                          contract.contractBackImage != null) ...[
                        const Divider(height: 24),
                        Text('صور العقد', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (contract.contractFrontImage != null)
                              Expanded(
                                child: _buildImageCard(
                                  context,
                                  contract.contractFrontImage!,
                                  'أمام',
                                ),
                              ),
                            if (contract.contractBackImage != null)
                              Expanded(
                                child: _buildImageCard(
                                  context,
                                  contract.contractBackImage!,
                                  'خلف',
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (contract.idFrontImage != null ||
                          contract.idBackImage != null) ...[
                        const Divider(height: 24),
                        Text('صور البطاقة', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (contract.idFrontImage != null)
                              Expanded(
                                child: _buildImageCard(
                                  context,
                                  contract.idFrontImage!,
                                  'أمام',
                                ),
                              ),
                            if (contract.idBackImage != null)
                              Expanded(
                                child: _buildImageCard(
                                  context,
                                  contract.idBackImage!,
                                  'خلف',
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              AppButton(
                label: 'سجل المدفوعات',
                icon: Icons.payments_outlined,
                variant: AppButtonVariant.royal,
                expand: true,
                onPressed: () {
                  context.go('/winter_contracts/payments/$contractId');
                },
              ),
              if (contract.isActive) ...[
                const SizedBox(height: 8),
                AppButton(
                  label: 'تسليم الشقة وإنهاء العقد',
                  icon: Icons.fact_check_outlined,
                  expand: true,
                  onPressed: () {
                    context.go('/winter_contracts/checkout/${contract.id}');
                  },
                ),
              ],
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'آخر تعديل: ${DateFormat('yyyy-MM-dd hh:mm a', 'ar').format(contract.updatedAt.toLocal())}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (err, stack) => ErrorState(
          title: 'تعذّر تحميل البيانات',
          message: '$err',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(allWinterContractsProvider),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(color: colors.ink2),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.tabular(
                (isHighlight ? AppTextStyles.title : AppTextStyles.body)
                    .copyWith(
                  color: isHighlight ? colors.winter : colors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoommatesList(
    BuildContext context,
    String roommatesJsonStr,
  ) {
    try {
      final List<dynamic> roommates = jsonDecode(roommatesJsonStr);
      if (roommates.isEmpty) return [];

      return roommates.map((rm) {
        final academicInfo = _parseAcademicInfo(rm['university']?.toString());
        final faculty = rm['faculty']?.toString() ?? academicInfo.$2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text(
              'بيانات زميل السكن',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(context, 'الاسم', rm['name'] ?? ''),
            if (academicInfo.$1.isNotEmpty)
              _buildDetailRow(context, 'الجامعة', academicInfo.$1),
            if (faculty.isNotEmpty) _buildDetailRow(context, 'الكلية', faculty),
            if (rm['nationalId'] != null &&
                rm['nationalId'].toString().isNotEmpty)
              _buildDetailRow(context, 'الرقم القومي', rm['nationalId']),
            if (rm['nationalId'] != null &&
                rm['nationalId'].toString().isNotEmpty)
              ..._buildNationalIdRows(context, rm['nationalId'].toString()),
            if (rm['idFrontImage'] != null || rm['idBackImage'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (rm['idFrontImage'] != null)
                    Expanded(
                      child: _buildImageCard(
                        context,
                        rm['idFrontImage'],
                        'بطاقة الزميل (أمام)',
                      ),
                    ),
                  if (rm['idBackImage'] != null)
                    Expanded(
                      child: _buildImageCard(
                        context,
                        rm['idBackImage'],
                        'بطاقة الزميل (خلف)',
                      ),
                    ),
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

  (String, String) _parseAcademicInfo(String? value) {
    if (value == null || value.trim().isEmpty) return ('', '');
    final text = value.trim();
    if (text.contains(' - ')) {
      final parts = text.split(' - ');
      return (parts.first.trim(), parts.skip(1).join(' - ').trim());
    }
    if (text.contains('|')) {
      final parts = text.split('|');
      return (parts.first.trim(), parts.skip(1).join('|').trim());
    }
    return (text, '');
  }

  List<Widget> _buildNationalIdRows(BuildContext context, String nationalId) {
    final info = _nationalIdInfo(nationalId);
    if (info == null) return [];
    return [
      _buildDetailRow(context, 'تاريخ الميلاد', info.birthDateLabel),
      _buildDetailRow(context, 'العمر', '${info.age} سنة'),
      _buildDetailRow(context, 'النوع', info.gender),
      _buildDetailRow(context, 'محافظة الميلاد', info.governorate),
    ];
  }

  _NationalIdInfo? _nationalIdInfo(String value) {
    final nationalId = value.trim();
    if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) return null;
    final centuryDigit = nationalId.substring(0, 1);
    final century = centuryDigit == '2'
        ? 1900
        : centuryDigit == '3'
        ? 2000
        : null;
    if (century == null) return null;
    final year = century + int.parse(nationalId.substring(1, 3));
    final month = int.parse(nationalId.substring(3, 5));
    final day = int.parse(nationalId.substring(5, 7));
    final governorate =
        _governorates[nationalId.substring(7, 9)] ?? 'غير معروف';
    final genderDigit = int.parse(nationalId.substring(12, 13));
    final gender = genderDigit.isOdd ? 'ذكر' : 'أنثى';
    try {
      return _NationalIdInfo(
        birthDate: DateTime(year, month, day),
        governorate: governorate,
        gender: gender,
      );
    } catch (_) {
      return null;
    }
  }

  static const Map<String, String> _governorates = {
    '01': 'القاهرة',
    '02': 'الإسكندرية',
    '03': 'بورسعيد',
    '04': 'السويس',
    '11': 'دمياط',
    '12': 'الدقهلية',
    '13': 'الشرقية',
    '14': 'القليوبية',
    '15': 'كفر الشيخ',
    '16': 'الغربية',
    '17': 'المنوفية',
    '18': 'البحيرة',
    '19': 'الإسماعيلية',
    '21': 'الجيزة',
    '22': 'بني سويف',
    '23': 'الفيوم',
    '24': 'المنيا',
    '25': 'أسيوط',
    '26': 'سوهاج',
    '27': 'قنا',
    '28': 'أسوان',
    '29': 'الأقصر',
    '31': 'البحر الأحمر',
    '32': 'الوادي الجديد',
    '33': 'مطروح',
    '34': 'شمال سيناء',
    '35': 'جنوب سيناء',
    '88': 'خارج الجمهورية',
  };

  Widget _buildImageCard(BuildContext context, String imagePath, String label) {
    final normalizedPath = imagePath.trim();
    final isRemote =
        normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://');
    final localFile = isRemote ? null : File(normalizedPath);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (!isRemote && !(await localFile!.exists())) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'الصورة غير موجودة على هذا الجهاز. اعمل مزامنة من الجهاز الأصلي أو افتح الصورة بعد رفعها للسيرفر.',
                  ),
                ),
              );
            }
            return;
          }
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InteractiveViewer(child: _buildImagePreview(normalizedPath)),
                  IconButton(
                    icon: Icon(Icons.close, color: context.colors.err),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
        child: Column(
          children: [
            _buildImageThumbnail(normalizedPath),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) =>
            const _MissingImageBox(message: 'تعذر تحميل الصورة من السيرفر'),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const _MissingImageBox(message: 'الصورة غير موجودة على هذا الجهاز'),
    );
  }

  Widget _buildImageThumbnail(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) =>
            const _MissingImageBox(height: 100, message: 'تعذر تحميل الصورة'),
      );
    }
    return Image.file(
      File(path),
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const _MissingImageBox(height: 100, message: 'الصورة على جهاز آخر'),
    );
  }
}

class _MissingImageBox extends StatelessWidget {
  final double? height;
  final String message;

  const _MissingImageBox({this.height, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, color: context.colors.ink3),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Utility split row (prototype `utilSplit`): icon + label + tenant/owner chip.
class _UtilityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool onTenant;

  const _UtilityRow({
    required this.icon,
    required this.label,
    required this.onTenant,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colors.ink2),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.body.copyWith(color: colors.ink)),
          ],
        ),
        StatusChip(
          kind: onTenant ? StatusChipKind.winter : StatusChipKind.neutral,
          label: onTenant ? 'على الطالب' : 'على المالك',
        ),
      ],
    );
  }
}

class _NationalIdInfo {
  final DateTime birthDate;
  final String governorate;
  final String gender;

  const _NationalIdInfo({
    required this.birthDate,
    required this.governorate,
    required this.gender,
  });

  String get birthDateLabel => birthDate.toLocal().toString().split(' ')[0];

  int get age {
    final today = DateTime.now();
    var years = today.year - birthDate.year;
    final birthdayThisYear = DateTime(
      today.year,
      birthDate.month,
      birthDate.day,
    );
    if (today.isBefore(birthdayThisYear)) years--;
    return years;
  }
}
