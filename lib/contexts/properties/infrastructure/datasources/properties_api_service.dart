import 'dart:convert';
import 'package:nexoraiot/shared/api_client.dart';

class PropertyDto {
  final int id;
  final String propertyCode;
  final String name;
  final String? description;
  final String propertyType;
  final String country;
  final String city;
  final String address;
  final String status;
  final bool isSecurityModeArmed;
  final LandlordDto landlord;

  PropertyDto({
    required this.id,
    required this.propertyCode,
    required this.name,
    this.description,
    required this.propertyType,
    required this.country,
    required this.city,
    required this.address,
    required this.status,
    required this.isSecurityModeArmed,
    required this.landlord,
  });

  factory PropertyDto.fromJson(Map<String, dynamic> json) {
    return PropertyDto(
      id: json['id'] ?? 0,
      propertyCode: json['propertyCode'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      propertyType: json['propertyType'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      isSecurityModeArmed: json['isSecurityModeArmed'] ?? false,
      landlord: LandlordDto.fromJson(json['landlord'] ?? {}),
    );
  }
}

class LandlordDto {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  LandlordDto({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  factory LandlordDto.fromJson(Map<String, dynamic> json) {
    return LandlordDto(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}

class PropertiesApiService {
  Future<List<PropertyDto>> getProperties() async {
    final response = await ApiClient.get('/properties');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PropertyDto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load properties. Status: ${response.statusCode}');
    }
  }

  Future<int> getPropertiesStats() async {
    final response = await ApiClient.get('/properties/stats');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['total'] ?? 0;
    } else {
      throw Exception('Failed to load properties stats. Status: ${response.statusCode}');
    }
  }
}
