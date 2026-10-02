/// Patient's loyalty points balance summary.
class LoyaltyBalanceModel {
  const LoyaltyBalanceModel({
    required this.pointsBalance,
    this.totalEarned,
    this.totalRedeemed,
    this.tier,
  });

  final int pointsBalance;
  final int? totalEarned;
  final int? totalRedeemed;
  final String? tier;

  factory LoyaltyBalanceModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyBalanceModel(
      pointsBalance:
          int.tryParse(
            (json['points_balance'] ?? json['balance'] ?? json['points'] ?? 0)
                .toString(),
          ) ??
          0,
      totalEarned: int.tryParse(
        (json['total_earned'] ?? json['total_points_earned'] ?? '')
            .toString(),
      ),
      totalRedeemed: int.tryParse(
        (json['total_redeemed'] ?? json['total_points_redeemed'] ?? '')
            .toString(),
      ),
      tier: (json['tier'] ?? json['loyalty_tier']) as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loyalty transaction
// ─────────────────────────────────────────────────────────────────────────────

enum LoyaltyTransactionType { earn, redeem, other }

class LoyaltyTransactionModel {
  const LoyaltyTransactionModel({
    required this.id,
    required this.points,
    required this.type,
    this.description,
    this.createdAt,
  });

  final int id;
  final int points;
  final LoyaltyTransactionType type;
  final String? description;
  final DateTime? createdAt;

  bool get isEarn => type == LoyaltyTransactionType.earn;

  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day.toString().padLeft(2, '0')}/'
        '${createdAt!.month.toString().padLeft(2, '0')}/'
        '${createdAt!.year}';
  }

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? json['transaction_type'] ?? '')
        .toString()
        .toLowerCase();
    return LoyaltyTransactionModel(
      id: (json['transaction_id'] ?? json['id']) as int,
      points:
          int.tryParse((json['points'] ?? json['amount'] ?? 0).toString()) ??
          0,
      type: rawType.contains('redeem') || rawType.contains('debit')
          ? LoyaltyTransactionType.redeem
          : rawType.contains('earn') || rawType.contains('credit')
          ? LoyaltyTransactionType.earn
          : LoyaltyTransactionType.other,
      description: (json['description'] ?? json['note']) as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
