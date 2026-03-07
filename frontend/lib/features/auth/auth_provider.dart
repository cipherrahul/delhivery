import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? role;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.token,
    this.role,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? role,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() => AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: data['user']['role'],
        token: data['token'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
