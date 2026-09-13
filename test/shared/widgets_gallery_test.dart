import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abrag/core/theme/app_theme.dart';
import 'package:abrag/shared/widgets/widgets.dart';

import '../support/test_fonts.dart';

/// Design-system gallery: smoke test (RTL + LTR) and dark-theme goldens.
///
/// Goldens are dev-only safety nets for the shared kit. They are generated
/// on Windows; if a platform renders text differently, regenerate locally
/// with: flutter test --update-goldens test/shared/widgets_gallery_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadAppFonts);

  Widget gallery(TextDirection direction) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Directionality(
        textDirection: direction,
        child: const _GalleryScreen(),
      ),
    );
  }

  Future<void> pumpGallery(WidgetTester tester, TextDirection dir) async {
    tester.view.physicalSize = const Size(390, 2750);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(gallery(dir));
    // Fixed pumps instead of pumpAndSettle: LoadingSkeleton animates forever.
    await tester.pump(const Duration(milliseconds: 350));
  }

  testWidgets('gallery renders without exceptions in RTL', (tester) async {
    await pumpGallery(tester, TextDirection.rtl);
    expect(find.byType(StatCard), findsWidgets);
    expect(find.byType(NavRow), findsWidgets);
    expect(find.byType(AppButton), findsWidgets);
    expect(find.byType(StatusChip), findsWidgets);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.byType(LoadingSkeleton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gallery renders without exceptions in LTR', (tester) async {
    await pumpGallery(tester, TextDirection.ltr);
    expect(tester.takeException(), isNull);
  });

  testWidgets('golden: dark gallery RTL', (tester) async {
    await pumpGallery(tester, TextDirection.rtl);
    await expectLater(
      find.byType(_GalleryScreen),
      matchesGoldenFile('goldens/widgets_gallery_dark_rtl.png'),
    );
  });

  testWidgets('golden: dark gallery LTR', (tester) async {
    await pumpGallery(tester, TextDirection.ltr);
    await expectLater(
      find.byType(_GalleryScreen),
      matchesGoldenFile('goldens/widgets_gallery_dark_ltr.png'),
    );
  });
}

class _GalleryScreen extends StatelessWidget {
  const _GalleryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AbragAppBar(
        title: 'معرض المكونات',
        subtitle: 'Design system gallery',
        showBack: true,
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          children: [
            const SectionTitle(title: 'الإحصائيات'),
            Row(
              children: const [
                Expanded(
                  child: StatCard(
                    icon: Icons.apartment,
                    label: 'الشقق',
                    value: '24',
                    sub: '18 مشغولة',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.calendar_month,
                    label: 'حجوزات اليوم',
                    value: '7',
                    tint: Color(0xFFFCBC15),
                  ),
                ),
              ],
            ),
            const SectionTitle(title: 'التنقل'),
            const NavRow(
              icon: Icons.book_online,
              title: 'الحجوزات الصيفية',
              sub: '12 حجز نشط',
              badge: '3',
            ),
            NavRow(
              icon: Icons.description,
              title: 'عقود الشتاء',
              sub: '8 عقود',
              trailing: const StatusChip(
                label: 'متأخر',
                kind: StatusChipKind.warn,
              ),
              onTap: () {},
            ),
            const SectionTitle(title: 'الحالات'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                StatusChip(label: 'مدفوع', kind: StatusChipKind.ok),
                StatusChip(label: 'متأخر', kind: StatusChipKind.warn),
                StatusChip(label: 'ملغي', kind: StatusChipKind.err),
                StatusChip(label: 'صيفي', kind: StatusChipKind.summer),
                StatusChip(label: 'شتوي', kind: StatusChipKind.winter),
                StatusChip(label: 'مسودة', kind: StatusChipKind.neutral),
                StatusChip(
                  label: 'جديد',
                  kind: StatusChipKind.brand,
                  icon: Icons.star,
                ),
              ],
            ),
            const SectionTitle(title: 'الأزرار'),
            Row(
              children: [
                Expanded(
                  child: AppButton(label: 'حفظ', onPressed: () {}),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'تأكيد',
                    variant: AppButtonVariant.royal,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'إلغاء',
                    variant: AppButtonVariant.ghost,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'تعديل',
                    variant: AppButtonVariant.outline,
                    small: true,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: AppButton(label: 'معطل', onPressed: null),
                ),
              ],
            ),
            const SectionTitle(title: 'الإدخال'),
            const AppTextField(
              label: 'اسم الضيف',
              hint: 'أدخل الاسم الكامل',
              prefixIcon: Icons.person_outline,
            ),
            const SectionTitle(title: 'تفاصيل'),
            AppCard(
              child: Column(
                children: const [
                  DetailRow(label: 'رقم الشقة', value: '12'),
                  Divider(),
                  DetailRow(label: 'المدة', value: '5 ليالٍ'),
                  Divider(),
                  DetailRow(
                    label: 'الإجمالي',
                    value: '3,500 ج.م',
                    strong: true,
                  ),
                ],
              ),
            ),
            const SectionTitle(title: 'الموسم والتقدم'),
            SeasonHero(
              season: Season.summer,
              child: Row(
                children: const [
                  MiniMetric(
                    icon: Icons.wb_sunny_outlined,
                    value: '14',
                    label: 'حجز نشط',
                    tint: Color(0xFFFCBC15),
                  ),
                  SizedBox(width: 24),
                  MiniMetric(
                    icon: Icons.payments_outlined,
                    value: '82٪',
                    label: 'نسبة التحصيل',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const AppProgressBar(value: 0.64),
            const SectionTitle(title: 'الشقق'),
            Row(
              children: const [
                Expanded(
                  child: ApartmentCell(
                    number: '12',
                    statusColor: Color(0xFF34D6A0),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ApartmentCell(
                    number: '14',
                    statusColor: Color(0xFFFB5A66),
                    selected: true,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ApartmentCell(
                    number: '15',
                    statusColor: Color(0xFFFCBC15),
                  ),
                ),
              ],
            ),
            const SectionTitle(title: 'الجدول الزمني'),
            AppCard(
              child: PaymentTimeline(
                entries: const [
                  PaymentTimelineEntry(
                    title: 'دفعة أكتوبر',
                    subtitle: 'مدفوعة — 1,200 ج.م',
                    state: TimelineNodeState.paid,
                  ),
                  PaymentTimelineEntry(
                    title: 'دفعة نوفمبر',
                    subtitle: 'مستحقة الآن',
                    state: TimelineNodeState.active,
                  ),
                  PaymentTimelineEntry(
                    title: 'دفعة ديسمبر',
                    state: TimelineNodeState.due,
                  ),
                ],
              ),
            ),
            const SectionTitle(title: 'عناصر متفرقة'),
            Row(
              children: [
                const AppAvatar(name: 'نور أحمد'),
                const SizedBox(width: 12),
                AppIconButton(
                  icon: Icons.notifications_outlined,
                  badgeCount: 3,
                  onPressed: () {},
                ),
                AppIconButton(
                  icon: Icons.search,
                  active: true,
                  onPressed: () {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniNavCard(
                    icon: Icons.build_outlined,
                    title: 'الصيانة',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedTabs(
              labels: const ['الكل', 'نشط', 'منتهي'],
              index: 0,
              onChanged: (_) {},
            ),
            const SectionTitle(title: 'حالات الشاشة'),
            const SizedBox(
              height: 360,
              child: EmptyState(
                title: 'لا توجد حجوزات',
                sub: 'أضف أول حجز لهذا الموسم',
                icon: Icons.inbox_outlined,
              ),
            ),
            SizedBox(
              height: 320,
              child: ErrorState(
                title: 'تعذّر تحميل البيانات',
                message: 'تحقّق من الاتصال وحاول مرة أخرى.',
                retryLabel: 'إعادة المحاولة',
                onRetry: () {},
              ),
            ),
            const LoadingSkeleton(label: 'جارٍ التحميل…'),
            const SizedBox(height: 16),
            BottomActionBar(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'إلغاء',
                    variant: AppButtonVariant.ghost,
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: AppButton(label: 'حفظ', onPressed: () {}),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: AppFab(label: 'إضافة', onPressed: () {}),
    );
  }
}
