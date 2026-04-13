import 'dart:io';
import 'package:dio/dio.dart';
import 'package:s_a/const/Modal/serviceListModal.dart';
import 'package:s_a/const/endpoint/endpoint.dart';

class ApiService {
  // Singleton setup
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

 static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndoint.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Initialize with Interceptors
  void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add Auth Token here dynamically
          // options.headers["Authorization"] = "Bearer $token";
          print("Request: ${options.method} ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print("API Error: ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }



  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
    required String state,
    String role = "customer",
    File? imageFile,
  }) async {
    try {
      // 1. Create the map of user data
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "password": password,
        "phone_no": phone,
        "address": address,
        "city": city,
        "state": state,
        "role": role,
      };


      if (imageFile != null) {
        data["profile_image"] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      // 3. Convert to FormData for Multipart request
      FormData formData = FormData.fromMap(data);

      // 4. Hit the registration endpoint
      final response = await _dio.post(
        ApiEndoint.register,
        data: formData,
      );

      return response;
    } on DioException catch (e) {
      // Throws the formatted error message we created in the previous step
      throw _handleError(e);
    }
  }


  // Inside lib/const/endpoint/ApiService.dart

  Future<Response> registerOwner({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required int serviceId,
    required String state,
    File? imageFile,
  }) async {
    try {
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "city": city,
        "service_ids": serviceId,
        "state": state,
        "role": "owner",
      };

      if (imageFile != null) {
        data["profile_image"] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(data);

      // ─── DEBUG: LOG REQUEST DATA ───
      print("🚀 --- API REQUEST START --- 🚀");
      print("URL: ${_dio.options.baseUrl}/register");
      formData.fields.forEach((field) {
        print("Field: ${field.key} = ${field.value}");
      });
      formData.files.forEach((file) {
        print("File: ${file.key} = ${file.value.filename}");
      });

      final response = await _dio.post(
        ApiEndoint.owner_register,
        data: formData,
      );

      // ─── DEBUG: LOG RESPONSE DATA ───
      print("✅ --- API RESPONSE --- ✅");
      print("Status Code: ${response.statusCode}");
      print("Data: ${response.data}");
      print("-------------------------");

      return response;
    } on DioException catch (e) {
      // ─── DEBUG: LOG ERROR ───
      print("❌ --- API ERROR --- ❌");
      print("Message: ${e.message}");
      print("Response: ${e.response?.data}");
      throw _handleError(e);
    }
  }



  static Future<serviceListModal?> fetchServiceList() async {
    try {
      // POST request with no body data
      final response = await _dio.post(ApiEndoint.serviceList);

      if (response.statusCode == 200) {
        return serviceListModal.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching services: $e");
      return null;
    }
  }




  // GET Request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timed out";
      case DioExceptionType.badResponse:
        return "Server error: ${error.response?.statusCode}";
      case DioExceptionType.connectionError:
        return "Check your internet connection";
      default:
        return "Something went wrong";
    }
  }
}