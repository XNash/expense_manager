import 'package:expense_manager/expenses/data/model/expense_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/api_service.dart';

class ExpenseRepository extends StateNotifier<List<ExpenseModel>> {
  final ApiService _apiService;
  final String _token;

  ExpenseRepository(this._apiService, this._token) : super([]) {
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    try {
      print('Fetching expenses in repository'); // Log pour le débogage
      final expenses = await _apiService.getExpenses(_token);
      print('Fetched ${expenses.length} expenses'); // Log pour le débogage
      state = expenses;
    } catch (e) {
      print('Detailed error in fetchExpenses: $e');
      state = [];
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final newExpense = await _apiService.addExpense(_token, expense);
      state = [...state, newExpense];
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final updatedExpense = await _apiService.updateExpense(_token, expense);
      state = [
        for (final e in state)
          if (e.id == updatedExpense.id) updatedExpense else e
      ];
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _apiService.deleteExpense(_token, id);
      state = state.where((expense) => expense.id != id).toList();
    } catch (e) {
      // Handle error
    }
  }
}
