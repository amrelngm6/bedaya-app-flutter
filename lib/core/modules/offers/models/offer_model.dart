/// Represents a redeemable offer shown to the patient.
///
/// Field names are matched defensively against the most likely backend
/// keys (snake_case) since multiple naming variants (`image` / `image_url`,
/// `points` / `points_required`, ...) are common across this API.
class OfferApiModel {
  const OfferApiModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.points,
    this.arabicTitle,
    this.description,
    this.arabicDescription,
    this.expiryDate,
    this.isActive = true,
    this.isRedeemed = false,
  });

  final int id;
  final String title;
  final String? arabicTitle;
  final String? description;
  final String? arabicDescription;
  final String imageUrl;
  final int points;
  final DateTime? expiryDate;
  final bool isActive;
  final bool isRedeemed;

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  String get formattedExpiryDate {
    if (expiryDate == null) return '';
    return '${expiryDate!.day.toString().padLeft(2, '0')}/'
        '${expiryDate!.month.toString().padLeft(2, '0')}/'
        '${expiryDate!.year}';
  }

  factory OfferApiModel.fromJson(Map<String, dynamic> json) {
    return OfferApiModel(
      id: (json['offer_id'] ?? json['id']) as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      arabicTitle: (json['arabic_title'] ?? json['title_ar']) as String?,
      description: (json['description'] ?? json['details']) as String?,
      arabicDescription:
          (json['arabic_description'] ?? json['description_ar']) as String?,
      imageUrl:
          (json['image'] ?? json['image_url'] ?? json['picture'] ?? '')
              as String,
      points:
          int.tryParse(
            (json['points'] ?? json['points_required'] ?? json['cost'] ?? 0)
                .toString(),
          ) ??
          0,
      expiryDate: _parseDate(
        json['expiry_date'] ?? json['expires_at'] ?? json['expiration_date'],
      ),
      isActive: (json['is_active'] ?? true) as bool,
      isRedeemed: (json['is_redeemed'] ?? json['redeemed'] ?? false) as bool,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
