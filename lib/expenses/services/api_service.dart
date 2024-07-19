import 'package:dio/dio.dart';
import 'package:expense_manager/expenses/data/model/expense_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['token'];
    } catch (e) {
      throw Exception('Failed to login');
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw Exception('Failed to register');
    }
  }

  Future<List<ExpenseModel>> getExpenses(String token) async {
    try {
      print('Fetching expenses with token: $token'); // Log pour le débogage
      final response = await _dio.get('/expenses',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      print('Response status: ${response.statusCode}'); // Log pour le débogage
      print('Response data: ${response.data}'); // Log pour le débogage
      return (response.data as List)
          .map((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Detailed error in getExpenses: $e'); // Log détaillé de l'erreur
      if (e is DioError) {
        print('DioError response: ${e.response}');
        print('DioError type: ${e.type}');
      }
      throw Exception('Failed to get expenses: $e');
    }
  }

  Future<ExpenseModel> addExpense(String token, ExpenseModel expense) async {
    try {
      final response = await _dio.post('/expenses',
          data: expense.toJson(),
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ExpenseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add expense');
    }
  }

  Future<ExpenseModel> updateExpense(String token, ExpenseModel expense) async {
    try {
      final response = await _dio.put('/expenses/${expense.id}',
          data: expense.toJson(),
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return ExpenseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update expense');
    }
  }

  Future<void> deleteExpense(String token, int id) async {
    try {
      await _dio.delete('/expenses/$id',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
    } catch (e) {
      throw Exception('Failed to delete expense');
    }
  }
}
