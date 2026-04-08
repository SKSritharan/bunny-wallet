class CreditCardModel {
  final String id;
  final String name;
  final String lastFourDigits;
  final double creditLimit;
  final double currentBalance;
  final int billingDay;
  final int dueDay;
  final int gradientIndex;
  final bool isActive;
  final DateTime createdAt;

  const CreditCardModel({
    required this.id,
    required this.name,
    required this.lastFourDigits,
    required this.creditLimit,
    this.currentBalance = 0,
    required this.billingDay,
    required this.dueDay,
    this.gradientIndex = 0,
    this.isActive = true,
    required this.createdAt,
  });

  double get availableCredit => creditLimit - currentBalance;
  double get utilizationRate =>
      creditLimit > 0 ? (currentBalance / creditLimit).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'last_four_digits': lastFourDigits,
        'credit_limit': creditLimit,
        'current_balance': currentBalance,
        'billing_day': billingDay,
        'due_day': dueDay,
        'gradient_index': gradientIndex,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory CreditCardModel.fromMap(Map<String, dynamic> map) {
    return CreditCardModel(
      id: map['id'] as String,
      name: map['name'] as String,
      lastFourDigits: map['last_four_digits'] as String,
      creditLimit: (map['credit_limit'] as num).toDouble(),
      currentBalance: (map['current_balance'] as num).toDouble(),
      billingDay: map['billing_day'] as int,
      dueDay: map['due_day'] as int,
      gradientIndex: map['gradient_index'] as int? ?? 0,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  CreditCardModel copyWith({
    String? id,
    String? name,
    String? lastFourDigits,
    double? creditLimit,
    double? currentBalance,
    int? billingDay,
    int? dueDay,
    int? gradientIndex,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CreditCardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      billingDay: billingDay ?? this.billingDay,
      dueDay: dueDay ?? this.dueDay,
      gradientIndex: gradientIndex ?? this.gradientIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
