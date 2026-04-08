class PaymentReminderModel {
  final String id;
  final String creditCardId;
  final int daysBefore;
  final bool isEnabled;

  const PaymentReminderModel({
    required this.id,
    required this.creditCardId,
    required this.daysBefore,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'credit_card_id': creditCardId,
        'days_before': daysBefore,
        'is_enabled': isEnabled ? 1 : 0,
      };

  factory PaymentReminderModel.fromMap(Map<String, dynamic> map) {
    return PaymentReminderModel(
      id: map['id'] as String,
      creditCardId: map['credit_card_id'] as String,
      daysBefore: map['days_before'] as int,
      isEnabled: (map['is_enabled'] as int? ?? 1) == 1,
    );
  }

  PaymentReminderModel copyWith({
    String? id,
    String? creditCardId,
    int? daysBefore,
    bool? isEnabled,
  }) {
    return PaymentReminderModel(
      id: id ?? this.id,
      creditCardId: creditCardId ?? this.creditCardId,
      daysBefore: daysBefore ?? this.daysBefore,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
