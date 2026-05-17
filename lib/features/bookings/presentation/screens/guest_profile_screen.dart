import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/bookings_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/utils/currency_formatter.dart';

class GuestProfileScreen extends ConsumerWidget {
  final String guestName;

  const GuestProfileScreen({super.key, required this.guestName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(summerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final theme = Theme.of(context);
    final formatter = DateFormat('EEEE yyyy-MM-dd', 'ar');

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف النزيل'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/summer_bookings/list');
            }
          },
        ),
      ),
      body: bookingsAsync.when(
        data: (allBookings) {
          final guestBookings =
              allBookings.where((b) => b.guestName == guestName).toList()
                ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

          if (guestBookings.isEmpty) {
            return const Center(child: Text('لا يوجد سجل لهذا النزيل'));
          }

          final latestBooking = guestBookings.first;
          final latestNationalId = _latestNonEmpty(
            guestBookings.map((booking) => booking.nationalId),
          );
          final birthDate = _birthDateFromEgyptianNationalId(latestNationalId);
          final age = birthDate == null ? null : _ageInYears(birthDate);
          final governorate = _governorateFromEgyptianNationalId(
            latestNationalId,
          );
          final now = DateTime.now();
          final isCurrentlyStaying = guestBookings.any((booking) {
            final checkout = booking.earlyCheckoutDate ?? booking.checkOutDate;
            return booking.status != 'checked_out' &&
                booking.status != 'cancelled' &&
                !now.isBefore(booking.checkInDate) &&
                now.isBefore(checkout);
          });
          final totalNights = guestBookings.fold<int>(0, (sum, booking) {
            final days = _calendarDays(
              booking.checkInDate,
              booking.earlyCheckoutDate ?? booking.checkOutDate,
            );
            return sum + days;
          });
          final totalPaid = guestBookings.fold<double>(
            0,
            (sum, booking) => sum + booking.amountPaidEgp,
          );
          final lastVisit = latestBooking.checkInDate;
          final frontImage = _latestExistingImage(
            guestBookings.map((b) => b.idFrontImage),
          );
          final backImage = _latestExistingImage(
            guestBookings.map((b) => b.idBackImage),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          guestName.isNotEmpty ? guestName[0] : '?',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guestName,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latestBooking.guestPhone ?? 'لا يوجد رقم هاتف',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  avatar: Icon(
                                    Icons.history,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  label: Text('${guestBookings.length} نشاط'),
                                ),
                                Chip(
                                  avatar: Icon(
                                    isCurrentlyStaying
                                        ? Icons.hotel
                                        : Icons.logout,
                                    size: 16,
                                    color: isCurrentlyStaying
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  label: Text(
                                    isCurrentlyStaying
                                        ? 'ساكن حاليًا'
                                        : 'غير ساكن حاليًا',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildPersonalInfoSection(
                context,
                nationalId: latestNationalId,
                birthDate: birthDate,
                age: age,
                governorate: governorate,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatCard(
                    context,
                    'الزيارات',
                    '${guestBookings.length}',
                    Icons.home_work,
                  ),
                  _buildStatCard(
                    context,
                    'الأيام',
                    '$totalNights',
                    Icons.dark_mode,
                  ),
                  _buildStatCard(
                    context,
                    'المدفوع',
                    '${totalPaid.toDouble().toCurrencyFormat()} ج.م',
                    Icons.payments,
                  ),
                  _buildStatCard(
                    context,
                    'آخر زيارة',
                    formatter.format(lastVisit),
                    Icons.schedule,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildIdImagesSection(context, frontImage, backImage),
              const SizedBox(height: 24),
              Text('سجل الزيارات', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              ...guestBookings.map((booking) {
                final apartmentNumber = apartmentsAsync.maybeWhen(
                  data: (apartments) {
                    final matches = apartments
                        .where((a) => a.id == booking.apartmentId)
                        .toList();
                    return matches.isEmpty
                        ? booking.apartmentId
                        : matches.first.apartmentNumber;
                  },
                  orElse: () => booking.apartmentId,
                );
                final days = _calendarDays(
                  booking.checkInDate,
                  booking.earlyCheckoutDate ?? booking.checkOutDate,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () =>
                        context.push('/summer_bookings/details/${booking.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'شقة $apartmentNumber',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              _StatusPill(label: _statusLabel(booking.status)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _InfoLine(
                            icon: Icons.login,
                            label: 'الدخول',
                            value: formatter.format(booking.checkInDate),
                          ),
                          const SizedBox(height: 6),
                          _InfoLine(
                            icon: Icons.logout,
                            label: 'الخروج',
                            value: formatter.format(
                              booking.earlyCheckoutDate ?? booking.checkOutDate,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _InfoLine(
                            icon: Icons.nights_stay,
                            label: 'عدد الأيام',
                            value: '$days يوم',
                          ),
                          const SizedBox(height: 6),
                          _InfoLine(
                            icon: Icons.price_change,
                            label: 'السعر اليومي',
                            value:
                                '${((booking.totalPriceEgp - booking.overstayFeeEgp) / days).toDouble().toCurrencyFormat()} ج.م',
                          ),
                          const Divider(),
                          _InfoLine(
                            icon: Icons.payments,
                            label: 'المدفوع',
                            value:
                                '${booking.amountPaidEgp.toDouble().toCurrencyFormat()} ج.م',
                            valueColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildIdImagesSection(
    BuildContext context,
    String? frontPath,
    String? backPath,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('صور البطاقة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _IdImageTile(
                    title: 'أمام البطاقة',
                    imagePath: frontPath,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _IdImageTile(
                    title: 'خلف البطاقة',
                    imagePath: backPath,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(
    BuildContext context, {
    required String? nationalId,
    required DateTime? birthDate,
    required int? age,
    required String? governorate,
  }) {
    final formatter = DateFormat('yyyy-MM-dd', 'ar');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بيانات شخصية',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _InfoLine(
              icon: Icons.badge,
              label: 'الرقم القومي',
              value: (nationalId ?? '').isEmpty ? 'غير مسجل' : nationalId!,
            ),
            const SizedBox(height: 6),
            _InfoLine(
              icon: Icons.cake,
              label: 'تاريخ الميلاد',
              value: birthDate == null
                  ? 'غير متاح'
                  : formatter.format(birthDate),
            ),
            const SizedBox(height: 6),
            _InfoLine(
              icon: Icons.calendar_today,
              label: 'السن',
              value: age == null ? 'غير متاح' : '$age سنة',
            ),
            const SizedBox(height: 6),
            _InfoLine(
              icon: Icons.location_city,
              label: 'المحافظة',
              value: governorate ?? 'غير متاحة',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 48) / 2,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calendarDays(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays.clamp(1, 10000);
  }

  String? _latestExistingImage(Iterable<String?> paths) {
    for (final path in paths) {
      if (path != null && path.isNotEmpty && File(path).existsSync()) {
        return path;
      }
    }
    return null;
  }

  String? _latestNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  DateTime? _birthDateFromEgyptianNationalId(String? nationalId) {
    if (nationalId == null || nationalId.length < 7) return null;
    final centuryDigit = int.tryParse(nationalId.substring(0, 1));
    final year = int.tryParse(nationalId.substring(1, 3));
    final month = int.tryParse(nationalId.substring(3, 5));
    final day = int.tryParse(nationalId.substring(5, 7));
    if (centuryDigit == null || year == null || month == null || day == null) {
      return null;
    }
    final century = centuryDigit == 2
        ? 1900
        : centuryDigit == 3
        ? 2000
        : null;
    if (century == null) return null;
    try {
      return DateTime(century + year, month, day);
    } catch (_) {
      return null;
    }
  }

  int _ageInYears(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String? _governorateFromEgyptianNationalId(String? nationalId) {
    if (nationalId == null || nationalId.length < 9) return null;
    final code = nationalId.substring(7, 9);
    const governorates = {
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
    return governorates[code];
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'checked_out':
        return 'تم الخروج';
      case 'cancelled':
        return 'ملغي';
      case 'pending':
        return 'قيد الانتظار';
      default:
        return status;
    }
  }
}

class _IdImageTile extends StatelessWidget {
  final String title;
  final String? imagePath;

  const _IdImageTile({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    final file = hasImage ? File(imagePath!) : null;
    final fileExists = file?.existsSync() ?? false;
    return InkWell(
      onTap: fileExists
          ? () => showDialog(
              context: context,
              builder: (_) => Dialog(
                child: InteractiveViewer(
                  child: Image.file(
                    file!,
                    errorBuilder: (context, error, stackTrace) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('الصورة غير متاحة'),
                    ),
                  ),
                ),
              ),
            )
          : null,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: fileExists
            ? Image.file(
                file!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('الصورة غير متاحة', textAlign: TextAlign.center),
                ),
              )
            : Center(
                child: Text(
                  '$title\nالصورة غير متاحة',
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
