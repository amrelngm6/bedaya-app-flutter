import 'package:bedaya2/core/modules/auth/models/auth_models.dart';

class PatientModel extends UserModel {
  final String phoneNumber;
  final MedicalProfile? medicalProfile;

  PatientModel({
    required super.id,
    required super.phone,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.gender,
    required super.address,
    required this.phoneNumber,
    required super.nationality,
    this.medicalProfile,
  });

  @override
  String get fullName => '$firstName $lastName';

  int get age {
    // final now = DateTime.now();
    // int age = now.year - fullName.year;
    // if (now.month < dateOfBirth.month ||
    //     (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
    //   age--;
    // }
    return 1;
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
    id: json['id'] as int,
    phone: json['phone'] as String? ?? '',
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    email: json['email'] as String?,
    phoneNumber: json['phone'] as String? ?? '',
    gender: json['gender'] as String? ?? '',
    address: json['address'] as String?,
    nationality: json['nationality'] as String? ?? '',
  );
}

class MedicalProfile {
  final String bloodType; // A+, B+, AB+, O+, A-, B-, AB-, O-
  final double? height; // in cm
  final double? weight; // in kg
  final List<String> allergies;
  final List<String> chronicDiseases;
  final List<Medication> currentMedications;
  final List<MedicalHistory> medicalHistory;
  final List<Vaccination> vaccinations;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final String? notes;

  MedicalProfile({
    required this.bloodType,
    this.height,
    this.weight,
    required this.allergies,
    required this.chronicDiseases,
    required this.currentMedications,
    required this.medicalHistory,
    required this.vaccinations,
    this.insuranceProvider,
    this.insuranceNumber,
    this.notes,
  });

  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'N/A';
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
  });
}

class MedicalHistory {
  final String id;
  final String condition;
  final DateTime date;
  final String? treatment;
  final String? doctorName;
  final String? notes;

  MedicalHistory({
    required this.id,
    required this.condition,
    required this.date,
    this.treatment,
    this.doctorName,
    this.notes,
  });
}

class Vaccination {
  final String id;
  final String name;
  final DateTime date;
  final String? administeredBy;
  final DateTime? nextDoseDate;

  Vaccination({
    required this.id,
    required this.name,
    required this.date,
    this.administeredBy,
    this.nextDoseDate,
  });
}
