import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:s_a/const/Modal/CreateProfessionalResModal.dart';
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
  }) async
  {
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
  }) async
  {
    try
    {
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


  Future<Response?> sendOtp({required String phone, required String role}) async {
    // 1. Construct and Clean URL
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.login.trim()}";

    debugPrint("🚀 DEBUG: [Signup] Process Started");
    debugPrint("🔗 DEBUG: [API] Full Target URL: $url");
    debugPrint("📦 DEBUG: [API] Payload: { phone: $phone, role: $role }");
    FormData formData = FormData.fromMap({
      "phone": phone,
      "role": role,
    });

    try {
      // 2. Execute POST Request
      final response = await _dio.post(
        url,
        data: formData
      );

      // 3. Log Successful Response
      debugPrint("✅ DEBUG: [API] Success. Status Code: ${response.statusCode}");
      debugPrint("📄 DEBUG: [API] Response Data: ${response.data}");

      return response;

    } on DioException catch (e) {
      // 4. Detailed Error Logging
      debugPrint("💥 DEBUG: [DioException] at $url");

      if (e.type == DioExceptionType.connectionTimeout) {
        debugPrint("⏳ DEBUG: Connection Timeout");
      } else if (e.type == DioExceptionType.badResponse) {
        debugPrint("❌ DEBUG: Server Error Data: ${e.response?.data}");
        debugPrint("❌ DEBUG: Status Code: ${e.response?.statusCode}");
      } else {
        debugPrint("❓ DEBUG: Unknown Network Error: ${e.message}");
      }

      // Return the response even on error so UI can show the 'message' from backend
      return e.response;

    } catch (e) {
      // 5. Catch any other unexpected errors
      debugPrint("💀 DEBUG: Unexpected Error: $e");
      return null;
    }
  }


  // ── VERIFY OTP METHOD ──
  Future<Response?> verifyOtp({required String phone, required String otp}) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.verify_otp.trim()}";

    debugPrint("🚀 DEBUG: [Verify OTP] Process Started");
    debugPrint("🔗 DEBUG: [API] URL: $url");

    try {
      // 1. Create FormData payload
      FormData formData = FormData.fromMap({
        "phone": phone,
        "otp": otp,
      });

      debugPrint("📦 DEBUG: [API] Payload: phone=$phone, otp=$otp");

      // 2. Execute POST Request
      final response = await _dio.post(
        url,
        data: formData,
      );

      // 3. Log Success
      debugPrint("✅ DEBUG: [API] Verification Success");
      debugPrint("📄 DEBUG: [API] Response Data: ${response.data}");

      return response;

    } on DioException catch (e) {
      debugPrint("💥 DEBUG: [DioException] at $url");

      if (e.response != null) {
        debugPrint("❌ DEBUG: Status Code: ${e.response?.statusCode}");
        debugPrint("❌ DEBUG: Server Error Message: ${e.response?.data}");
      } else {
        debugPrint("❓ DEBUG: Connection Error: ${e.message}");
      }

      return e.response;

    } catch (e) {
      debugPrint("💀 DEBUG: Unexpected Error: $e");
      return null;
    }
  }


  // ── CREATE PROFESSIONAL PROFILE ──
  Future<createProfessionalResModal?> createProfessional({
    required String phone,
    required String name,
    required String profession,
    required String experience,
    required String address,
    required String description,
  }) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.createProfession.trim()}";

    debugPrint("🚀 DEBUG: [Create Professional] Process Started");
    debugPrint("🔗 DEBUG: [API] URL: $url");

    try {
      // 1. Create FormData payload
      FormData formData = FormData.fromMap({
        "phone": phone,
        "name": name,
        "profession": profession,
        "experience_years": experience,
        "address": address,
        "description": description,
      });

      debugPrint("📦 DEBUG: [API] Payload: $phone, $name, $profession");

      // 2. Execute POST Request
      final response = await _dio.post(
        url,
        data: formData,
      );

      // 3. Log and Parse Response
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ DEBUG: [API] Profile Creation Success");
        debugPrint("📄 DEBUG: [API] Response Data: ${response.data}");

        // Map the dynamic map to your Modal class
        return createProfessionalResModal.fromJson(response.data);
      } else {
        debugPrint("⚠️ DEBUG: [API] Unexpected Status Code: ${response.statusCode}");
        return createProfessionalResModal.fromJson(response.data);
      }

    } on DioException catch (e) {
      debugPrint("💥 DEBUG: [DioException] at $url");

      if (e.response != null) {
        debugPrint("❌ DEBUG: Status Code: ${e.response?.statusCode}");
        debugPrint("❌ DEBUG: Server Error: ${e.response?.data}");

        // Even on error, try to parse the message from the server into your modal
        try {
          return createProfessionalResModal.fromJson(e.response?.data);
        } catch (mapError) {
          debugPrint("❌ DEBUG: Parsing Error: $mapError");
          return null;
        }
      } else {
        debugPrint("❓ DEBUG: Connection Error: ${e.message}");
        return null;
      }

    } catch (e) {
      debugPrint("💀 DEBUG: Unexpected Error: $e");
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