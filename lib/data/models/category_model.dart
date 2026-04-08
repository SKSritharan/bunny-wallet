import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final int color;
  final String type; // 'income' or 'expense'

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.color,
    required this.type,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get colorValue => Color(color);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon_code_point': iconCodePoint,
        'color': color,
        'type': type,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['icon_code_point'] as int,
      color: map['color'] as int,
      type: map['type'] as String,
    );
  }

  static List<CategoryModel> get defaultCategories => [
        CategoryModel(
          id: 'cat_salary',
          name: 'Salary',
          iconCodePoint: Icons.account_balance_wallet.codePoint,
          color: 0xFF66BB6A,
          type: 'income',
        ),
        CategoryModel(
          id: 'cat_freelance',
          name: 'Freelance',
          iconCodePoint: Icons.laptop_mac.codePoint,
          color: 0xFF42A5F5,
          type: 'income',
        ),
        CategoryModel(
          id: 'cat_investment',
          name: 'Investment',
          iconCodePoint: Icons.trending_up.codePoint,
          color: 0xFFAB47BC,
          type: 'income',
        ),
        CategoryModel(
          id: 'cat_gift_in',
          name: 'Gift',
          iconCodePoint: Icons.card_giftcard.codePoint,
          color: 0xFFFF7043,
          type: 'income',
        ),
        CategoryModel(
          id: 'cat_other_in',
          name: 'Other',
          iconCodePoint: Icons.more_horiz.codePoint,
          color: 0xFF78909C,
          type: 'income',
        ),
        CategoryModel(
          id: 'cat_food',
          name: 'Food',
          iconCodePoint: Icons.restaurant.codePoint,
          color: 0xFFFF7043,
          type: 'expense',
        ),
        CategoryModel(
          id: 'cat_transport',
          name: 'Transport',
          iconCodePoint: Icons.directions_car.codePoint,
          color: 0xFF42A5F5,
          type: 'expense',
        ),
        CategoryModel(
          id: 'cat_shopping',
          name: 'Shopping',
          iconCodePoint: Icons.shopping_bag.codePoint,
          color: 0xFFEC407A,
          type: 'expense',
        ),
        CategoryModel(
          id: 'cat_entertainment',
          name: 'Entertainment',
          iconCodePoint: Icons.movie.codePoint,
          color: 0xFFAB47BC,
          type: 'expense',
        ),
        CategoryModel(
          id: 'cat_bills',
          name: 'Bills',
          iconCodePoint: Icons.receipt_long.codePoint,
          color: 0xFFEF5350,
          type: 'expense',
        ),
        CategoryModel(
          id: 'cat_health',
          name: 'Health',
          iconCodePoint: Icons.favorite.codePoint,
          color: 0xFF66BB6A,
          type: 'expense',
        ),
        CategoryModel(
          id: 'cat_education',
          name: 'Education',
          iconCodePoint: Icons.school.codePoint,
          color: 0xFF5C6BC0,
          type: 'expense',
        ),
        CategoryModel(
          id: 'cat_subscriptions',
          name: 'Subscriptions',
          iconCodePoint: Icons.subscriptions.codePoint,
          color: 0xFF26A69A,
          type: 'expense',
        ),
        CategoryModel(
          id: 'cat_other_exp',
          name: 'Other',
          iconCodePoint: Icons.more_horiz.codePoint,
          color: 0xFF78909C,
          type: 'expense',
        ),
      ];
}
