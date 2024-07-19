import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'api_service.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(apiServiceProvider)),
);

class AuthState {
  final bool isAuthenticated;
  final String? token;

  AuthState({required this.isAuthenticated, this.token});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState(isAuthenticated: false));

  Future<void> login(String email, String password) async {
    try {
      final token = await _apiService.login(email, password);
      state = AuthState(isAuthenticated: true, token: token);
    } catch (e) {
      state = AuthState(isAuthenticated: false);
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      await _apiService.register(name, email, password);
      await login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    state = AuthState(isAuthenticated: false);
  }
}
