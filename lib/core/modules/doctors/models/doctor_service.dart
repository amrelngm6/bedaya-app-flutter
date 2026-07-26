class DoctorService {
  const DoctorService({
    required this.id,
    required this.name,
    this.arabicName,
    this.price,
    this.priceA,
    this.priceB,
  });

  final int id;
  final String name;
  final String? arabicName;
  final double? price;
  final double? priceA;
  final double? priceB;

  factory DoctorService.fromJson(Map<String, dynamic> json) => DoctorService(
    id: json['service_id'] as int,
    name: json['service']['service_name'] as String? ?? '',
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
}
