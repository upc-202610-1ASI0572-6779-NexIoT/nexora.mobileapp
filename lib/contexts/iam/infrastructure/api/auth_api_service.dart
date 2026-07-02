import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dto/profile_dto.dart';
import '../dto/user_dto.dart';

class AuthApiService {
  static const String baseUrl = 'https://api.nexora.local/api/v1';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authentication/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'] ?? '';
    }

    throw Exception('Invalid email or password.');
  }

  Future<UserDto> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final parts = fullName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final response = await http.post(
      Uri.parse('$baseUrl/authentication/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'country': 'Perú',
        'city': 'Lima',
        'address': 'Av. Principal 123',
        'phoneNumber': null,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final now = DateTime.now();

      return UserDto(
        id: data['userId'] ?? 0,
        email: data['email'] ?? email,
        isActive: true,
        failedLoginAttempts: 0,
        lockedAt: null,
        createdAt: now,
        updatedAt: now,
      );
    }

    throw Exception('Could not create account.');
  }

  Future<UserDto> getAuthenticatedUser({
    required String token,
  }) async {
    final now = DateTime.now();

    return UserDto(
      id: 0,
      email: '',
      isActive: true,
      failedLoginAttempts: 0,
      lockedAt: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<ProfileDto> getProfile({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profiles/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ProfileDto.fromJson(jsonDecode(response.body));
    }

    throw Exception('Could not load profile.');
  }

  Future<ProfileDto> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String address,
    String? phoneNumber,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profiles/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'country': country,
        'city': city,
        'address': address,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return ProfileDto.fromJson(jsonDecode(response.body));
    }

    throw Exception('Could not update profile.');
  }
}