class DoctorService {
  const DoctorService({
    required this.id,
    required this.name,
    this.isOnline = false,
    this.arabicName,
    this.price,
    this.priceA,
    this.priceB,
  });

  final int id;
  final String name;
  final bool isOnline;
  final String? arabicName;
  final double? price;
  final double? priceA;
  final double? priceB;

  factory DoctorService.fromJson(Map<String, dynamic> json) => DoctorService(
    id: json['service_id'] as int,
    isOnline: json['service']['is_online'] as bool? ?? false,
    name: json['service']['name'] as String? ?? '',
    arabicName: json['service']['arabic_name'] as String?,
    price: double.tryParse(
      json['service']['price']?.toString() ?? '0.0',
    )?.toDouble(),
    priceA: double.tryParse(
      json['service']['price_foreign_a']?.toString() ?? '0.0',
    ),
    priceB: double.tryParse(
      json['service']['price_foreign_b']?.toString() ?? '0.0',
    ),
  );

  double getPriceForUserType(String userType) {
    switch (userType) {
      case 'foreign_a':
        return priceA ?? price ?? 0.0;
      case 'foreign_b':
        return priceB ?? price ?? 0.0;
      default:
        return price ?? 0.0;
    }
  }
}
