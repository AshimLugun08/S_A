import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:s_a/const/Modal/CatServiceListModal.dart';
import 'package:s_a/const/Modal/CreateProfessionalResModal.dart';
import 'package:s_a/const/Modal/SubcategoryListModal.dart';
import 'package:s_a/const/Modal/VerifyOtpresModal.dart';
import 'package:s_a/const/Modal/categoryListModal.dart';
import 'package:s_a/const/Modal/createBookngResModal.dart';
import 'package:s_a/const/Modal/createServiceResModal.dart';
import 'package:s_a/const/Modal/ownerServiceListModal.dart';
import 'package:s_a/const/Modal/profectionalListModal.dart';
import 'package:s_a/const/Modal/serviceDetailModal.dart';
import 'package:s_a/const/Modal/serviceListModal.dart';
import 'package:s_a/const/endpoint/endpoint.dart';
import 'package:s_a/const/session/session.dart';

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
    // ── COMBINE BASE + ENDPOINT ──
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.serviceList.trim()}";

    final Dio debugDio = Dio();

    debugPrint("--------------------------------------------------");
    debugPrint("🚀 DEBUG: [Service List] Fetch Started");
    debugPrint("🔗 FULL URL: $url");
    debugPrint("--------------------------------------------------");

    try {
      final response = await debugDio.get(url);

      if (response.statusCode == 200) {
        debugPrint("✅ SUCCESS: Request successful at $url");

        // ── PRINT THE DATA HERE ──
        debugPrint("📄 RAW DATA FROM SERVER: ${response.data}");

        // If you want to see if the mapping works, print a specific field:
        final modal = serviceListModal.fromJson(response.data);
        debugPrint("📦 MAPPED DATA: ${modal.data?.length} services found.");

        return modal;
      } else {
        debugPrint("⚠️ ERROR: Status ${response.statusCode} at $url");
        debugPrint("📄 ERROR BODY: ${response.data}");
        return null;
      }
    } catch (e) {
      debugPrint("💥 CRASH: Could not connect to $url");
      debugPrint("Error Details: $e");
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
  Future<VerifyOtpresModal?> verifyOtp({required String phone, required String otp}) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.verify_otp.trim()}";

    try {
      FormData formData = FormData.fromMap({
        "phone": phone,
        "otp": otp,
      });

      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        VerifyOtpresModal modal = VerifyOtpresModal.fromJson(response.data);

        if (modal.status == true && modal.userId != null) {
          // --- PASS ALL DATA TO PREFS ---
          await UserPref.saveUser(
            id: modal.userId!,
            phone: modal.phone ?? "",
            role: modal.role ?? "customer",
            name: modal.name ?? "",
            address: modal.address, // Now passing from API
            city: modal.city,       // Now passing from API
            state: modal.state,     // Now passing from API
          );
        }

        return modal;
      }
      return null;

    } on DioException catch (e) {
      if (e.response != null) {
        return VerifyOtpresModal.fromJson(e.response?.data);
      }
      return null;
    } catch (e) {
      debugPrint("💀 Unexpected Error: $e");
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
  }) async
  {
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



  Future<createServiceResModal?> addService({
    required String name,
    required String description,
    required dynamic category,
    required dynamic subcategory,
    required dynamic ownerId,
    required dynamic amount,
    List<File>? images,
  }) async
  {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.addService.trim()}";

    try {
      // 1. Create the base data map
      Map<String, dynamic> dataMap = {
        "name": name,
        "description": description,
        "category": category,
        "subcategory": subcategory,
        "owner_id": ownerId,
        "amount": amount,
      };

      // 2. Prepare the list of MultipartFiles
      if (images != null && images.isNotEmpty) {
        List<MultipartFile> multipartImageList = [];

        for (var file in images) {
          // Verify file exists before adding
          if (await file.exists()) {
            multipartImageList.add(
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
                // Some backends require explicit content type
                // contentType: MediaType('image', 'jpeg'),
              ),
            );
          }
        }

        dataMap["images"] = multipartImageList;
      }

      // 3. Create FormData from the updated map
      FormData formData = FormData.fromMap(dataMap);

      // 4. Post with progress tracking
      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: (sent, total) {
          debugPrint("Upload: ${(sent / total * 100).toStringAsFixed(0)}%");
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return createServiceResModal.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        debugPrint("Dio Error: ${e.response?.data ?? e.message}");
      } else {
        debugPrint("General Error: $e");
      }
      return null;
    }
  }

  static Future<SubcategoryListModal?> fetchSubcategories({required int categoryId}) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.subcategorylist}";
    final Dio debugDio = Dio();

    debugPrint("--------------------------------------------------");
    debugPrint("🚀 DEBUG: [Subcategory List] Fetch Started");
    debugPrint("🔗 BASE URL: $url");
    debugPrint("❓ QUERY PARAM: category_id=$categoryId");
    // This helps you see the exact link you can paste in a browser
    debugPrint("🌐 FULL DEBUG URL: $url?category_id=$categoryId");
    debugPrint("--------------------------------------------------");

    try {
      final response = await debugDio.get(
        url,
        queryParameters: {'category_id': categoryId},
      );

      debugPrint("✅ SUCCESS: Status ${response.statusCode}");

      if (response.statusCode == 200) {
        // ── PRINT RAW DATA ──
        debugPrint("📄 RAW DATA: ${response.data}");

        return SubcategoryListModal.fromJson(response.data);
      } else {
        debugPrint("⚠️ ERROR: Status ${response.statusCode} at $url");
        return null;
      }
    } on DioException catch (e) {
      debugPrint("💥 CRASH: DioException at $url");
      if (e.response != null) {
        debugPrint("❌ SERVER DATA: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      debugPrint("💀 UNEXPECTED ERROR: $e");
      return null;
    }
  }



  Future<OwnerServiceListModal?> getOwnerServices({required dynamic ownerId}) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.user_services.trim()}";

    try {
      // DEBUG: Check if ownerId is null before sending
      debugPrint("Fetching services for Owner ID: $ownerId");

      // Attempting POST request.
      // If this fails, try changing '.post' to '.get' and move owner_id to 'queryParameters'
      final response = await _dio.post(
        url,
        data: FormData.fromMap({
          "user_id": ownerId, // Most APIs prefer a simple Map (JSON) over FormData for IDs
        }),
      );

      debugPrint("Server Response Code: ${response.statusCode}");
      debugPrint("Server Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          return OwnerServiceListModal.fromJson(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      // Detailed error logging
      debugPrint("Dio Error Type: ${e.type}");
      debugPrint("Dio Error Message: ${e.message}");
      debugPrint("Dio Response Body: ${e.response?.data}");
      return null;
    } catch (e) {
      debugPrint("General API Error: $e");
      return null;
    }
  }


  static Future<CategoryListModal?> fetchCategoryList() async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.cateList.trim()}";
    final Dio _dio = Dio();

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Category API Success: ${response.data}");
        return CategoryListModal.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ Category API Dio Error: ${e.response?.data ?? e.message}");
      return null;
    } catch (e) {
      debugPrint("❌ Category API General Error: $e");
      return null;
    }
  }


  // --- FETCH CATEGORY SERVICE LIST ---
  static Future<CatServiceListModal?> fetchCatServiceList(int subcatId) async {
    // 1. Construct the URL from your endpoint constants
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.catServiceList.trim()}";

    try {
      debugPrint("🚀 [API] Fetching Category Services: $url");

      // 2. Use the internal _dio instance (or a fresh one if calling statically)
      // Note: If calling from a static context, ensure _dio is initialized
      final response = await _dio.get(url
      , queryParameters: {
        "subcategory_id": subcatId, // Example parameter, replace with actual value
          });

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ [API] Category Services Success");

        // 3. Parse the JSON using your model
        return CatServiceListModal.fromJson(response.data);
      } else {
        debugPrint("⚠️ [API] Unexpected Status: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      debugPrint("❌ [Dio Error]: ${e.response?.data ?? e.message}");
      return null;
    } catch (e) {
      debugPrint("💀 [General Error]: $e");
      return null;
    }
  }





  // --- FETCH SERVICE DETAILS BY ID ---
  static Future<BusDetailsModal?> fetchServiceDetails(int serviceId) async {

    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.ServiceDetails}/$serviceId/";

    try {
      debugPrint("🚀 [API] Fetching Service Details: $url");

      final response = await _dio.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ [API] Details Fetch Success");

        // Map the single object response to your BusDetailsModal
        return BusDetailsModal.fromJson(response.data);
      } else {
        debugPrint("⚠️ [API] Unexpected Status: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      debugPrint("❌ [Dio Error]: ${e.response?.data ?? e.message}");
      return null;
    } catch (e) {
      debugPrint("💀 [General Error]: $e");
      return null;
    }
  }

  // --- FETCH PROFESSIONALS BY OWNER ID ---
  static Future<ProffectionalModal?> fetchProfessionals(int ownerId) async {
    // Assuming endpoint is: http://192.168.1.64:8000/api/professionals/
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.profectionalList.trim()}";

    try {
      debugPrint("🚀 [API] Fetching Professionals for Owner: $ownerId");

      final response = await _dio.get(
        url,
        queryParameters: {
          "owner_id": ownerId, // Query parameter matching your backend
        },
      );

      if (response.statusCode == 200) {
        return ProffectionalModal.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ [Dio Error]: ${e.response?.data ?? e.message}");
      return null;
    } catch (e) {
      debugPrint("💀 [General Error]: $e");
      return null;
    }
  }



  // --- CREATE NEW BOOKING ---
  Future<CreateBookingResModal?> createBooking({
    required int userId,
    required int serviceId,
    required String date,
    required String time,
    required String address,
  }) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.createBooking.trim()}";

    try {
      // ─── UPDATED KEYS BASED ON SERVER ERROR ───
      final Map<String, dynamic> payload = {
        "user_id": userId,       // 'user_id' ko 'customer' kar diya
        "service_id": serviceId,     // 'service_id' ko 'service' kar diya
        "booking_date": date,
        "booking_time": time,
        "address": address,
      };

      debugPrint("--------------------------------------------------");
      debugPrint("🚀 [API REQUEST] PAYLOAD: $payload");
      debugPrint("--------------------------------------------------");

      final response = await _dio.post(url, data: payload);

      debugPrint("📄 [API RESPONSE] DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateBookingResModal.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("💀 [API ERROR]: $e");
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