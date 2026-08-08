class SeasonOption {
  final String key;
  final String label;

  const SeasonOption({required this.key, required this.label});
}

const int firstBusinessSeasonYear = 2026;

bool isSummerMonth(int month) => month >= 5 && month <= 9;

String seasonKeyForDate(DateTime date) {
  final firstSeasonStart = DateTime(firstBusinessSeasonYear, 5, 1);
  if (date.isBefore(firstSeasonStart)) return 'summer_$firstBusinessSeasonYear';
  if (isSummerMonth(date.month)) return 'summer_${date.year}';
  if (date.month >= 10) return 'winter_${date.year}_${date.year + 1}';
  return 'winter_${date.year - 1}_${date.year}';
}

String currentSeasonKey([DateTime? now]) =>
    seasonKeyForDate(now ?? DateTime.now());

String nextSeasonKey(String key) {
  if (key.startsWith('summer_')) {
    final year = int.tryParse(key.split('_').last) ?? DateTime.now().year;
    return 'winter_${year}_${year + 1}';
  }
  if (key.startsWith('winter_')) {
    final parts = key.split('_');
    final endYear = parts.length >= 3
        ? int.tryParse(parts[2]) ?? DateTime.now().year
        : DateTime.now().year;
    return 'summer_$endYear';
  }
  return currentSeasonKey();
}

String seasonLabel(String key) {
  if (key == 'all') return 'كل المواسم';
  if (key == 'summer') return 'كل مواسم الصيف';
  if (key == 'winter') return 'كل مواسم الشتاء';
  if (key.startsWith('summer_')) {
    return 'صيف ${key.split('_').last}';
  }
  if (key.startsWith('winter_')) {
    final parts = key.split('_');
    if (parts.length >= 3) return 'شتاء ${parts[1]}/${parts[2]}';
  }
  return key;
}

List<SeasonOption> seasonOptionsAround({
  DateTime? now,
  int pastYears = 4,
  int futureYears = 2,
  bool includeGeneric = true,
}) {
  final currentYear = (now ?? DateTime.now()).year;
  final lastYear = currentYear + futureYears;
  final options = <SeasonOption>[];
  if (includeGeneric) {
    options.addAll(const [
      SeasonOption(key: 'all', label: 'كل المواسم'),
      SeasonOption(key: 'summer', label: 'كل مواسم الصيف'),
      SeasonOption(key: 'winter', label: 'كل مواسم الشتاء'),
    ]);
  }
  for (var year = lastYear; year >= firstBusinessSeasonYear; year--) {
    options.add(
      SeasonOption(
        key: 'winter_${year}_${year + 1}',
        label: 'شتاء $year/${year + 1}',
      ),
    );
    options.add(SeasonOption(key: 'summer_$year', label: 'صيف $year'));
  }
  final seen = <String>{};
  return options.where((option) => seen.add(option.key)).toList();
}

bool seasonMatchesKey(String? storedSeason, String filter) {
  if (filter == 'all') return true;
  final season = storedSeason ?? 'all';
  if (season == 'all') return filter == 'all';
  if (filter == 'summer') {
    return season == 'summer' || season.startsWith('summer_');
  }
  if (filter == 'winter') {
    return season == 'winter' || season.startsWith('winter_');
  }
  return season == filter;
}

bool seasonMatchesDate(DateTime date, String filter) {
  if (filter == 'all') return true;
  final key = seasonKeyForDate(date);
  if (filter == 'summer') return key.startsWith('summer_');
  if (filter == 'winter') return key.startsWith('winter_');
  return key == filter;
}

String normalizeStoredSeason(String? storedSeason, DateTime fallbackDate) {
  if (storedSeason == null || storedSeason == 'all') {
    return seasonKeyForDate(fallbackDate);
  }
  if (storedSeason == 'summer' || storedSeason == 'winter') {
    return seasonKeyForDate(fallbackDate);
  }
  return storedSeason;
}
