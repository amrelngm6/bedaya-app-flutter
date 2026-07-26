import 'package:easy_localization/easy_localization.dart';

class PregnancyData {
  final DateTime lastMenstrualPeriod;
  final DateTime expectedDueDate;
  final int weeksPregnant;
  final int daysPregnant;
  final int monthsPregnant;
  final double progressPercentage;
  final String trimester;
  final String babySize;
  final String developmentStage;

  PregnancyData({
    required this.lastMenstrualPeriod,
    required this.expectedDueDate,
    required this.weeksPregnant,
    required this.daysPregnant,
    required this.monthsPregnant,
    required this.progressPercentage,
    required this.trimester,
    required this.babySize,
    required this.developmentStage,
  });

  factory PregnancyData.calculate(DateTime lmp) {
    final now = DateTime.now();
    final daysPregnant = now.difference(lmp).inDays;
    final weeksPregnant = (daysPregnant / 7).floor();
    final monthsPregnant = (weeksPregnant / 4.33).floor();

    // Expected due date is 280 days (40 weeks) from LMP
    final expectedDueDate = lmp.add(const Duration(days: 280));
    final progressPercentage = (daysPregnant / 280) * 100;

    String trimester;
    if (weeksPregnant < 13) {
      trimester = 'First Trimester';
    } else if (weeksPregnant < 27) {
      trimester = 'Second Trimester';
    } else {
      trimester = 'Third Trimester';
    }

    String babySize = _getBabySize(weeksPregnant);
    String developmentStage = _getDevelopmentStage(weeksPregnant);

    return PregnancyData(
      lastMenstrualPeriod: lmp,
      expectedDueDate: expectedDueDate,
      weeksPregnant: weeksPregnant,
      daysPregnant: daysPregnant,
      monthsPregnant: monthsPregnant,
      progressPercentage: progressPercentage.clamp(0, 100),
      trimester: trimester,
      babySize: babySize,
      developmentStage: developmentStage.tr(),
    );
  }

  static String _getBabySize(int weeks) {
    if (weeks < 4) return 'Poppy seed';
    if (weeks < 5) return 'Sesame seed';
    if (weeks < 6) return 'Lentil';
    if (weeks < 7) return 'Blueberry';
    if (weeks < 8) return 'Apricot';
    if (weeks < 9) return 'Grape';
    if (weeks < 10) return 'Kumquat';
    if (weeks < 11) return 'Fig';
    if (weeks < 12) return 'Lime';
    if (weeks < 13) return 'Plum';
    if (weeks < 14) return 'Lemon';
    if (weeks < 15) return 'Apple';
    if (weeks < 16) return 'Avocado';
    if (weeks < 17) return 'Pear';
    if (weeks < 18) return 'Bell pepper';
    if (weeks < 19) return 'Sweet potato';
    if (weeks < 20) return 'Banana';
    if (weeks < 21) return 'Carrot';
    if (weeks < 22) return 'Papaya';
    if (weeks < 23) return 'Grapefruit';
    if (weeks < 24) return 'Cantaloupe';
    if (weeks < 25) return 'Cauliflower';
    if (weeks < 27) return 'Orange';
    if (weeks < 28) return 'Apple';
    if (weeks < 30) return 'Mango';
    if (weeks < 31) return 'Eggplant';
    if (weeks < 32) return 'Coconut';
    if (weeks < 33) return 'Pineapple';
    if (weeks < 35) return 'Honeydew melon';
    if (weeks < 36) return 'Capucha';
    if (weeks < 37) return 'Swiss chard';
    if (weeks < 38) return 'Pumpkin';
    if (weeks < 40) return 'Watermelon';
    return 'Watermelon';
  }

  static String _getDevelopmentStage(int weeks) {
    if (weeks < 4) return 'Implantation beginning';
    if (weeks < 5) return 'Heart forming';
    if (weeks < 6) return 'Brain developing';
    if (weeks < 7) return 'Arms & legs budding';
    if (weeks < 8) return 'Webbed fingers forming';
    if (weeks < 9) return 'Toes developing';
    if (weeks < 10) return 'Vital organs formed';
    if (weeks < 11) return 'Bones hardening';
    if (weeks < 12) return 'Reflexes developing';
    if (weeks < 13) return 'Vocal cords forming';
    if (weeks < 14) return 'Facial features clear';
    if (weeks < 16) return 'Gender may be visible';
    if (weeks < 18) return 'Movement felt';
    if (weeks < 20) return 'Hair growing';
    if (weeks < 22) return 'Senses developing';
    if (weeks < 24) return 'Hearing sounds';
    if (weeks < 26) return 'Eyes opening';
    if (weeks < 28) return 'Dreaming begins';
    if (weeks < 30) return 'Brain growing rapidly';
    if (weeks < 32) return 'Practicing breathing';
    if (weeks < 34) return 'Immune system developing';
    if (weeks < 36) return 'Gaining weight';
    if (weeks < 38) return 'Fully developed';
    if (weeks < 40) return 'Ready for birth';
    return 'Full term baby';
  }

  String get remainingDays {
    final remaining = expectedDueDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining.toString() : '0';
  }

  String get formattedDueDate {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[expectedDueDate.month - 1]} ${expectedDueDate.day}, ${expectedDueDate.year}';
  }
}
