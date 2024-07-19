import 'package:expense_manager/expenses/data/model/expense_model.dart';
import 'package:expense_manager/expenses/data/providers/expense_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditPage extends HookConsumerWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = ref.watch(selectedExpense);
    final isEditing = ref.watch(isEditingExpense);

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Text('No expense selected'),
        ),
      );
    }

    final nameCtrl = TextEditingController(text: expense.name);
    final amountCtrl = TextEditingController(text: expense.amount.toString());
    final dateCtrl = TextEditingController(text: expense.date);
    final categoryCtrl = TextEditingController(text: expense.category);
    final descriptionCtrl = TextEditingController(text: expense.description);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          isEditing ? 'Edit Expense' : expense.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                final updatedExpense = ExpenseModel(
                  id: expense.id,
                  name: nameCtrl.text,
                  amount: int.parse(amountCtrl.text),
                  date: dateCtrl.text,
                  category: categoryCtrl.text,
                  description: descriptionCtrl.text,
                  userId: expense.userId,
                );
                ref
                    .read(expenseRepositoryProvider.notifier)
                    .updateExpense(updatedExpense);
                ref.read(selectedExpense.notifier).state = updatedExpense;
              }
              ref.read(isEditingExpense.notifier).state = !isEditing;
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing
            ? Column(
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(expense.date),
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
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ${expense.amount} MGA',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Date: ${expense.date}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Category: ${expense.category}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text('Description:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(expense.description,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
      ),
      floatingActionButton: isEditing
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Expense'),
                    content: const Text(
                        'Are you sure you want to delete this expense?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          ref
                              .read(expenseRepositoryProvider.notifier)
                              .deleteExpense(expense.id);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
