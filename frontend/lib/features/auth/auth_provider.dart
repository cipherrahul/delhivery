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
  AuthState build() {
    // In a real app, you would check secure storage here
    return AuthState();
  }

  void updateToken(String? token) {
    if (token != null) {
      apiClient.dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      apiClient.dio.options.headers.remove('Authorization');
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      final token = data['token'];
      
      updateToken(token);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: data['user']['role'],
        token: token,
      );

      // Save to secure storage here:
      // await storage.write(key: 'jwt_token', value: token);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void logout() {
    updateToken(null);
    state = AuthState();
  }
}

final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
