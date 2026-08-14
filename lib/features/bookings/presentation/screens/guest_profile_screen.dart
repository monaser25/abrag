import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/bookings_provider.dart';
import '../../../apartments/presentation/providers/apartments_controller.dart';
import '../../../../core/theme/abrag_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/booking_rate_utils.dart';
import '../../../../shared/widgets/widgets.dart';

class GuestProfileScreen extends ConsumerWidget {
  final String guestName;

  const GuestProfileScreen({super.key, required this.guestName});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(allSummerBookingsProvider);
    final apartmentsAsync = ref.watch(apartmentsProvider);
    final colors = context.colors;
    final formatter = DateFormat('EEEE yyyy-MM-dd', 'ar');

    return AppScaffold(
      appBar: AbragAppBar(
        title: 'ملف النزيل',
        showBack: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/summer_bookings/list');
          }
        },
      ),
      body: bookingsAsync.when(
        data: (allBookings) {
          final guestBookings =
              allBookings.where((b) => b.guestName == guestName).toList()
                ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

          if (guestBookings.isEmpty) {
            return const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'لا يوجد سجل لهذا النزيل',
            );
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
            final days = summerBookingStayDays(booking);
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AppCard(
                child: Row(
                  children: [
                    AppAvatar(name: guestName, size: 64),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guestName,
                            style: AppTextStyles.h2.copyWith(color: colors.ink),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (latestBooking.guestPhone
                                              ?.trim()
                                              .isNotEmpty ??
                                          false)
                                      ? latestBooking.guestPhone!
                                      : 'لا يوجد رقم هاتف',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: colors.ink2,
                                  ),
                                ),
                              ),
                              if (latestBooking.guestPhone?.trim().isNotEmpty ??
                                  false)
                                AppIconButton(
                                  icon: Icons.call,
                                  onPressed: () => _makePhoneCall(
                                    latestBooking.guestPhone!.trim(),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              StatusChip(
                                label: '${guestBookings.length} نشاط',
                                kind: StatusChipKind.brand,
                                icon: Icons.history,
                              ),
                              StatusChip(
                                label: isCurrentlyStaying
                                    ? 'ساكن حاليًا'
                                    : 'غير ساكن حاليًا',
                                kind: isCurrentlyStaying
                                    ? StatusChipKind.ok
                                    : StatusChipKind.neutral,
                                icon: isCurrentlyStaying
                                    ? Icons.hotel
                                    : Icons.logout,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
              const SectionTitle(title: 'سجل الزيارات'),
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
                final days = summerBookingStayDays(booking);
                return AppCard(
                  onTap: () =>
                      context.push('/summer_bookings/details/${booking.id}'),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'شقة $apartmentNumber',
                              style: AppTextStyles.title.copyWith(
                                color: colors.ink,
                              ),
                            ),
                          ),
                          StatusChip(
                            label: _statusLabel(booking.status),
                            kind: _statusKind(booking.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                            '${summerBookingDailyRate(booking).toDouble().toCurrencyFormat()} ج.م',
                      ),
                      Divider(color: colors.border),
                      _InfoLine(
                        icon: Icons.payments,
                        label: 'المدفوع',
                        value:
                            '${booking.amountPaidEgp.toDouble().toCurrencyFormat()} ج.م',
                        valueColor: colors.ok,
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (e, st) => ErrorState(
          title: 'تعذّر تحميل ملف النزيل',
          message: 'Error: $e',
          retryLabel: 'إعادة المحاولة',
          onRetry: () => ref.invalidate(allSummerBookingsProvider),
        ),
      ),
    );
  }

  Widget _buildIdImagesSection(
    BuildContext context,
    String? frontPath,
    String? backPath,
  ) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'صور البطاقة',
            style: AppTextStyles.title.copyWith(color: colors.ink),
          ),
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
                child: _IdImageTile(title: 'خلف البطاقة', imagePath: backPath),
              ),
            ],
          ),
        ],
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
    final colors = context.colors;
    final formatter = DateFormat('yyyy-MM-dd', 'ar');
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بيانات شخصية',
            style: AppTextStyles.title.copyWith(color: colors.ink),
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
            value: birthDate == null ? 'غير متاح' : formatter.format(birthDate),
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
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final colors = context.colors;
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 48) / 2,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            IconTile(icon: icon, tint: colors.brand, size: 38),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(color: colors.ink3),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.title.copyWith(color: colors.ink),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String? _latestExistingImage(Iterable<String?> paths) {
    for (final path in paths) {
      if (path == null || path.isEmpty) continue;
      // A synced ID image is a remote URL; a not-yet-synced one is a local file.
      if (path.startsWith('http') || File(path).existsSync()) {
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

  StatusChipKind _statusKind(String status) {
    switch (status) {
      case 'confirmed':
        return StatusChipKind.ok;
      case 'checked_out':
        return StatusChipKind.neutral;
      case 'cancelled':
        return StatusChipKind.err;
      case 'pending':
        return StatusChipKind.warn;
      default:
        return StatusChipKind.brand;
    }
  }
}

class _IdImageTile extends StatelessWidget {
  final String title;
  final String? imagePath;

  const _IdImageTile({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final path = imagePath?.trim() ?? '';
    // A synced image is a remote URL (shown via CachedNetworkImage); a
    // not-yet-synced one is a local file that must exist on this device.
    final isRemote = path.startsWith('http');
    final file = (path.isNotEmpty && !isRemote) ? File(path) : null;
    final canShow = isRemote || (file?.existsSync() ?? false);

    Widget buildImage(BoxFit fit) {
      if (isRemote) {
        return CachedNetworkImage(
          imageUrl: path,
          fit: fit,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (context, url, error) => _missingLabel(colors),
        );
      }
      return Image.file(
        file!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _missingLabel(colors),
      );
    }

    return InkWell(
      onTap: canShow
          ? () => showDialog(
              context: context,
              builder: (_) => Dialog(
                child: InteractiveViewer(child: buildImage(BoxFit.contain)),
              ),
            )
          : null,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: canShow
            ? buildImage(BoxFit.cover)
            : Center(
                child: Text(
                  '$title\nالصورة غير متاحة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyS.copyWith(color: colors.ink3),
                ),
              ),
      ),
    );
  }

  Widget _missingLabel(AbragColors colors) => Center(
    child: Text(
      'الصورة غير متاحة',
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyS.copyWith(color: colors.ink3),
    ),
  );
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
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.ink3),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.body.copyWith(color: colors.ink2)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.body.copyWith(
              color: valueColor ?? colors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
