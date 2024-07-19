import 'package:expense_manager/expenses/data/model/expense_model.dart';
import 'package:expense_manager/expenses/data/repository/expense_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/api_service.dart';
import '../../services/auth_notifier.dart';

final expenseRepositoryProvider =
    StateNotifierProvider<ExpenseRepository, List<ExpenseModel>>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    final authState = ref.watch(authNotifierProvider);
    return ExpenseRepository(apiService, authState.token ?? '');
  },
);

final selectedExpense = StateProvider<ExpenseModel?>((ref) => null);

final isEditingExpense = StateProvider((ref) => false);

final isPickingDate = StateProvider((ref) => false);
