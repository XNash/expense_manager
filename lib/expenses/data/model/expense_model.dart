import 'package:flutter/cupertino.dart';

class ExpenseModel extends ChangeNotifier {
  final int id;
  late final String name;
  final int amount;
  final String date;
  final String category;
  final String description;
  final int userId;

  ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
    required this.userId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: int.parse(json['id']),
      name: json['name'],
      amount: int.parse(json['amount']),
      date: json['date'],
      category: json['category'],
      description: json['description'],
      userId: int.parse(json['userId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'name': name,
      'amount': amount.toString(),
      'date': date,
      'category': category,
      'description': description,
      'userId': userId.toString(),
    };
  }
}
