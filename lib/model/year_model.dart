import 'package:sbku_app/data/dummy_year.dart';

class YearModel {
  final String yearId; // e.g. Y1
  final String yearName; // e.g. Year 1

  const YearModel({
    required this.yearId,
    required this.yearName,
  });

  // ---------------------------
  // Convert yearName → yearId
  // ---------------------------
  static String? nameToId(String? yearName) {
    if (yearName == null) return null;

    final match = dummyYears.firstWhere(
      (y) => y.yearName == yearName,
      orElse: () => const YearModel(yearId: '', yearName: ''),
    );

    return match.yearId.isEmpty ? null : match.yearId;
  }

  // ---------------------------
  // Convert yearId → yearName
  // ---------------------------
  static String? idToName(String? yearId) {
    if (yearId == null) return null;

    final match = dummyYears.firstWhere(
      (y) => y.yearId == yearId,
      orElse: () => const YearModel(yearId: '', yearName: ''),
    );

    return match.yearName.isEmpty ? null : match.yearName;
  }
}
