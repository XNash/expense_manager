import 'package:expense_manager/expenses/data/model/expense_model.dart';
import 'package:expense_manager/expenses/data/providers/expense_providers.dart';
import 'package:expense_manager/expenses/presentation/pages/edit_page.dart';
import 'package:expense_manager/expenses/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/auth_notifier.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final expenseRepository = ref.watch(expenseRepositoryProvider.notifier);
    final expenses = ref.watch(expenseRepositoryProvider);
    final isLoading = useState(false);
    final error = useState<String?>(null);

    useEffect(() {
      if (authState.isAuthenticated) {
        isLoading.value = true;
        error.value = null;
        expenseRepository.fetchExpenses().then((_) {
          isLoading.value = false;
        }).catchError((e) {
          isLoading.value = false;
          error.value = 'Failed to fetch expenses: $e';
          print('Error in HomePage: $e');
        });
      }
      return null;
    }, [authState.isAuthenticated]);

    if (!authState.isAuthenticated) {
      return const LoginPage();
    }

    if (isLoading.value) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error.value != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${error.value}'),
        ),
      );
    }
    final searchController = TextEditingController();

    if (!authState.isAuthenticated) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Nasshu's expense manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search for an expense",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedExpense.notifier).state = expense;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditPage()),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      color: Colors.green,
                      child: ListTile(
                        leading: const Icon(Icons.money_outlined),
                        title: Text(
                          expense.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text("${expense.amount} MGA on ${expense.date}"),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          showAddDialog(context, ref);
        },
      ),
    );
  }

  void showAddDialog(BuildContext context, WidgetRef ref) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Add new expense",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Name",
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Amount",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Date",
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    dateCtrl.text = date.toIso8601String().split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Category",
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Description",
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              final newExpense = ExpenseModel(
                id: 0, // The backend will assign the real ID
                name: nameCtrl.text,
                amount: int.parse(amountCtrl.text),
                date: dateCtrl.text,
                category: categoryCtrl.text,
                description: descriptionCtrl.text,
                userId: 0, // The backend will assign the real user ID
              );
              ref
                  .read(expenseRepositoryProvider.notifier)
                  .addExpense(newExpense);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
