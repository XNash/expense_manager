import 'package:expense_manager/expenses/data/model/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_service.dart';

final expenseNotifierProvider =
    StateNotifierProvider<ExpenseNotifier, List<Map<String, dynamic>>>(
  (ref) => ExpenseNotifier(ref.read(apiServiceProvider)),
);

class ExpenseNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ApiService _apiService;

  ExpenseNotifier(this._apiService) : super([]);

  Future<void> fetchExpenses(String token) async {
    try {
      final expenses = await _apiService.getExpenses(token);
      state = expenses.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addExpense(String token, Map<String, dynamic> expense) async {
    try {
      await _apiService.addExpense(token, expense as ExpenseModel);
      await fetchExpenses(token);
    } catch (e) {
      rethrow;
    }
  }
}
