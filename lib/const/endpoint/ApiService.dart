import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:s_a/const/Modal/BookingDetailsResModal.dart';
import 'package:s_a/const/Modal/CatServiceListModal.dart';
import 'package:s_a/const/Modal/CreateProfessionalResModal.dart';
import 'package:s_a/const/Modal/SubcategoryListModal.dart';
import 'package:s_a/const/Modal/VerifyOtpresModal.dart';
import 'package:s_a/const/Modal/addShedule.dart';
import 'package:s_a/const/Modal/addressModal.dart';
import 'package:s_a/const/Modal/categoryListModal.dart';
import 'package:s_a/const/Modal/createBookngResModal.dart';
import 'package:s_a/const/Modal/createServiceResModal.dart';
import 'package:s_a/const/Modal/customerBookingListModal.dart';
import 'package:s_a/const/Modal/earninModal.dart';
import 'package:s_a/const/Modal/earningListModal.dart';
import 'package:s_a/const/Modal/owmerBookingListModal.dart';
import 'package:s_a/const/Modal/ownerReviewListaModal.dart';
import 'package:s_a/const/Modal/ownerServiceListModal.dart';
import 'package:s_a/const/Modal/profectionalListModal.dart';
import 'package:s_a/const/Modal/reviewListModal.dart';
import 'package:s_a/const/Modal/schedule_modal.dart';
import 'package:s_a/const/Modal/serviceDetailModal.dart';
import 'package:s_a/const/Modal/serviceListModal.dart';
import 'package:s_a/const/Modal/userdetailModal.dart';
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
    required String state,
    required String adharNo,
    // required int serviceId,
    File? imageFile,
    File? adharImage,
  }) async {
    try {
      // 1. Prepare Text Data
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "city": city,
        "state": state,
        "adhar_no": adharNo,
        // "service_id": serviceId, // Uncommented: ensuring it's sent
        "role": "owner",
      };

      // 2. Add Profile Image
      if (imageFile != null) {
        data["profile_image"] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      // 3. Add Aadhar Image
      if (adharImage != null) {
        data["adhar_image"] = await MultipartFile.fromFile(
          adharImage.path,
          filename: adharImage.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(data);

      // ─── DEBUG PAYLOAD PRINTER ───
      debugPrint("\n╔═══════════ API REQUEST PAYLOAD ═══════════");
      debugPrint("║ 🔗 URL: ${ApiEndoint.baseUrl}${ApiEndoint.owner_register}");

      // Print fields (Text data)
      for (var field in formData.fields) {
        // Redacting Aadhaar digits in logs for privacy
        String value = (field.key == "adhar_no") ? "[Aadhar Redacted]" : field.value;
        debugPrint("║ 📝 Field: ${field.key.padRight(12)} = $value");
      }

      // Print files (Images data)
      for (var file in formData.files) {
        debugPrint("║ 📂 File:  ${file.key.padRight(12)} = ${file.value.filename} (Path: ${file.value.filename})");
      }
      debugPrint("╚═══════════════════════════════════════════\n");

      // 4. API Call
      final response = await _dio.post(
        ApiEndoint.owner_register,
        data: formData,
      );

      // ─── SUCCESS LOG ───
      debugPrint("✅ [API SUCCESS]: Status: ${response.statusCode}");
      debugPrint("📊 [API DATA]: ${response.data}");

      return response;

    } on DioException catch (e) {
      // ─── DETAILED ERROR LOG ───
      debugPrint("\n❌ [API ERROR DETECTED]");
      debugPrint("║ Type: ${e.type}");
      debugPrint("║ Msg:  ${e.message}");

      if (e.response != null) {
        debugPrint("║ Code: ${e.response?.statusCode}");
        debugPrint("║ Data: ${e.response?.data}");
        debugPrint("║ Headers: ${e.response?.headers}");
      } else {
        debugPrint("║ Error: Response is null. Check internet or server URL.");
      }
      debugPrint("╚═══════════════════════════════════════════\n");

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


  // ─── CREATE PROFESSIONAL PROFILE (With Image) ───
  // ─── CREATE PROFESSIONAL PROFILE (Full Debug) ───
  static Future<Map<String, dynamic>?> createProfessional({
    required String phone,
    required String name,
    required String profession,
    required int experienceYears,
    required String address,
    required String description,
    required int userId,
    dynamic imageFile, // XFile or File
  }) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.createProfession.trim()}";

    try {
      // 1. Prepare the Map
      Map<String, dynamic> map = {
        "phone": phone,
        "name": name,
        "profession": profession,
        "experience_years": experienceYears,
        "address": address,
        "description": description,
        "user_id": userId,
      };

      // 2. Attach Image as Multipart if exists
      if (imageFile != null) {
        map["image"] = await MultipartFile.fromFile(
            imageFile.path,
            filename: "professional_profile_${DateTime.now().millisecondsSinceEpoch}.jpg"
        );
      }

      FormData payload = FormData.fromMap(map);

      // ─── DEBUG PLAYLOAD PRINT START ───
      debugPrint("╔══════════════ 👷 PROFESSIONAL REGISTRATION ══════════════╗");
      debugPrint("║ 🔗 URL: $url");
      debugPrint("╟──────────────────────────────────────────────────────────");

      // Print text fields
      for (var field in payload.fields) {
        debugPrint("║ 🔑 ${field.key.padRight(18)} : ${field.value}");
      }

      // Print file info
      if (payload.files.isNotEmpty) {
        for (var file in payload.files) {
          debugPrint("║ 📄 ${file.key.padRight(18)} : [FILE] ${file.value.filename}");
        }
      } else {
        debugPrint("║ 📄 image              : No image attached");
      }
      debugPrint("╚══════════════════════════════════════════════════════════╝");
      // ─── DEBUG PLAYLOAD PRINT END ───

      // 3. Execute Request
      final response = await _dio.post(url, data: payload);

      // ─── DEBUG RESPONSE PRINT ───
      debugPrint("✅ [SERVER RESPONSE]: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return response.data;
        }
      }
      return null;

    } catch (e) {
      debugPrint("💀 [API FATAL ERROR]: $e");

      // Detailed error logging for validation issues (e.g., 422 errors)
      if (e is DioException && e.response != null) {
        debugPrint("╔══════════════ 🚫 SERVER ERROR DETAIL ══════════════╗");
        debugPrint("║ Status Code : ${e.response?.statusCode}");
        debugPrint("║ Error Data  : ${e.response?.data}");
        debugPrint("╚════════════════════════════════════════════════════╝");
      }
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
    required int ownerId,
    required String date,
    required String time,
 // Added bookingId as a required parameter
    required int professionalId, // Changed to camelCase for standard Dart style
    required int address,
  }) async
  {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.createBooking.trim()}";

    try {
      // 1. Construct the FormData
      FormData payload = FormData.fromMap({
        "customer_id": userId,
        "service_id": serviceId,
        "owner_id": ownerId,
        "booking_date": date,

        "booking_time": time,
        "professional_id": professionalId,
        "user_address_id": address,
        "status": "pending",
      });

      // ─── DEBUG PRINT START ───
      // ─── DEBUG PRINT START ───
      debugPrint("╔══════════════ 📦 DECODED PAYLOAD ══════════════╗");
      debugPrint("║ URL: $url");

// 1. Print Text Fields
      for (var field in payload.fields) {
        debugPrint("║ 🔑 ${field.key.padRight(15)} : ${field.value}");
      }

// 2. Print Files (If any)
      for (var file in payload.files) {
        debugPrint("║ 📄 ${file.key.padRight(15)} : [FILE] ${file.value.filename}");
      }

      debugPrint("╚═════════════════════════════════════════════════╝");
// ─── DEBUG PRINT END ───
      // ─── DEBUG PRINT END ───

      final response = await _dio.post(url, data: payload);

      debugPrint("📄 [API RESPONSE]: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateBookingResModal.fromJson(response.data);
      }

      return null;
    } catch (e) {
      debugPrint("💀 [API ERROR]: $e");
      // If it's a DioError, we can see the server's error message
      if (e is DioException && e.response != null) {
        debugPrint("🚫 Server Error Data: ${e.response?.data}");
      }
      return null;
    }
  }



  // ─── FETCH CUSTOMER BOOKINGS ───
  static Future<customerBookingListModal?> fetchCustomerBookings(int userId) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.customerBookingList.trim()}";

    try {
      // ─── QUERY PARAMETERS ───
      final Map<String, dynamic> params = {
        "customer_id": userId,
      };

      debugPrint("📡 [API REQUEST] Fetching Bookings");
      debugPrint("🔗 URL: $url");
      debugPrint("❓ PARAMS: $params");

      // Pass the params map to the queryParameters argument
      final response = await _dio.get(
        url,
        queryParameters: params,
      );

      // ─── DEBUG PRINT RESPONSE ───
      debugPrint("✅ [API RESPONSE] Status Code: ${response.statusCode}");
      debugPrint("📄 [DATA]: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return customerBookingListModal.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("💀 [API ERROR]: $e");
      if (e is DioException && e.response != null) {
        debugPrint("🚫 Server Error Data: ${e.response?.data}");
        debugPrint("🚫 Status Code: ${e.response?.statusCode}");
      }
      return null;
    }
  }


  // ─── FETCH OWNER BOOKINGS ───
  static Future<OwnerBookingListModal?> fetchOwnerBookings(int ownerId) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.ownerBookingList.trim()}";

    try {
      // ─── QUERY PARAMETERS ───
      final Map<String, dynamic> params = {
        "owner_id": ownerId,
      };

      debugPrint("🏢 [API REQUEST] Fetching Owner Bookings");
      debugPrint("🔗 URL: $url");
      debugPrint("❓ PARAMS: $params");

      final response = await _dio.get(
        url,
        queryParameters: params,
      );

      // ─── DEBUG PRINT RESPONSE ───
      debugPrint("✅ [API RESPONSE] Status Code: ${response.statusCode}");
      // Using a snippet of data to avoid flooding the console if the list is huge
      debugPrint("📄 [DATA]: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OwnerBookingListModal.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("💀 [API ERROR]: $e");
      if (e is DioException && e.response != null) {
        debugPrint("🚫 Server Error Data: ${e.response?.data}");
      }
      return null;
    }
  }



  // ─── UPDATE BOOKING STATUS ───
  static Future<bool> updateBookingStatus({
    required int bookingId,
    required String status, // 'pending', 'accepted', 'completed', 'cancelled'
  }) async
  {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.updateStatus.trim()}";

    try {
      // 1. Construct the FormData Payload
      FormData payload = FormData.fromMap({
        "booking_id": bookingId,
        "status": status,
      });

      // ─── DEBUG PRINT PAYLOAD ───
      debugPrint("🔄 [API REQUEST] Updating Booking Status");
      debugPrint("🔗 URL: $url");
      for (var field in payload.fields) {
        debugPrint("║ 🔑 ${field.key.padRight(12)} : ${field.value}");
      }

      // 2. Execute POST request
      final response = await _dio.post(url, data: payload);

      // ─── DEBUG PRINT RESPONSE ───
      debugPrint("✅ [API RESPONSE]: ${response.data}");

      // 3. Handle specific Boolean status from your JSON
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("💀 [API ERROR]: $e");
      if (e is DioException && e.response != null) {
        debugPrint("🚫 Server Message: ${e.response?.data}");
      }
      return false;
    }
  }



// ─── ADD SERVICE REVIEW ───
  static Future<Map<String, dynamic>?> addReview({
    required int bookingId,
    required int userId,
    required int serviceId,
    required int rating,
    required String comment,
  }) async
  {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.addReview.trim()}";

    try {
      // 1. Construct the FormData Payload
      FormData payload = FormData.fromMap({
        "booking_id": bookingId,
        "user_id": userId,
        "service_id": serviceId,
        "rating": rating,
        "comment": comment,
      });

      // ─── DEBUG PRINT PAYLOAD (Playload) ───
      debugPrint("⭐ [API REQUEST] Adding Review");
      debugPrint("🔗 URL: $url");
      for (var field in payload.fields) {
        debugPrint("║ 🔑 ${field.key.padRight(12)} : ${field.value}");
      }

      // 2. Execute POST request
      final response = await _dio.post(url, data: payload);

      // ─── DEBUG PRINT RESPONSE ───
      debugPrint("✅ [API RESPONSE]: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return response.data; // Returns the full map containing message and review_id
        }
      }
      return null;
    } catch (e) {
      debugPrint("💀 [API ERROR]: $e");
      if (e is DioException && e.response != null) {
        debugPrint("🚫 Server Error Data: ${e.response?.data}");
      }
      return null;
    }
  }


  // ─── FETCH REVIEWS ───
  static Future<reviewListModal?> fetchReviews(int ownerId) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.reviewList.trim()}";

    try {
      // ─── QUERY PARAMETERS ───
      final Map<String, dynamic> params = {
        "service_id": ownerId, // Passing owner_id to see all reviews for that salon
      };

      debugPrint("💬 [API REQUEST] Fetching Review List");
      debugPrint("🔗 URL: $url");
      debugPrint("❓ PARAMS: $params");

      final response = await _dio.get(
        url,
        queryParameters: params,
      );

      // ─── DEBUG PRINT RESPONSE ───
      debugPrint("✅ [API RESPONSE] Status Code: ${response.statusCode}");
      debugPrint("📄 [DATA]: ${response.data}");

      if (response.statusCode == 200) {
        return reviewListModal.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("💀 [API ERROR]: $e");
      if (e is DioException && e.response != null) {
        debugPrint("🚫 Server Error Data: ${e.response?.data}");
      }
      return null;
    }
  }


  // ─── EDIT PROFILE API (With Image Support) ───
  static Future<Map<String, dynamic>?> editProfile({
    required int userId,
    required String name,
    required String email,
    required String phone,
    dynamic imageFile, // Can be XFile (from image_picker) or File
  }) async {
    // Ensure the endpoint matches your backend route
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.editcustomer}";

    try {
      // 1. Prepare the base map
      Map<String, dynamic> map = {
        "user_id": userId,
        "name": name,
        "email": email,
        "phone": phone,
      };

      // 2. Attach image if the user selected one
      if (imageFile != null) {
        map["image"] = await MultipartFile.fromFile(
            imageFile.path,
            filename: "profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg"
        );
      }

      FormData payload = FormData.fromMap(map);

      // ─── DEBUG PLAYLOAD PRINT START ───
      debugPrint("╔══════════════ 👤 EDIT PROFILE REQUEST ══════════════╗");
      debugPrint("║ 🔗 URL: $url");
      debugPrint("╟──────────────────────────────────────────────────────");

      for (var field in payload.fields) {
        debugPrint("║ 🔑 ${field.key.padRight(15)} : ${field.value}");
      }

      if (payload.files.isNotEmpty) {
        for (var file in payload.files) {
          debugPrint("║ 📄 ${file.key.padRight(15)} : [FILE] ${file.value.filename}");
        }
      } else {
        debugPrint("║ 📄 image           : No new image selected");
      }
      debugPrint("╚══════════════════════════════════════════════════════╝");
      // ─── DEBUG PLAYLOAD PRINT END ───

      // 3. Execute POST request
      final response = await _dio.post(url, data: payload);

      debugPrint("✅ [SERVER RESPONSE]: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true) {
          return response.data; // Returns the updated user data
        }
      }
      return null;

    } catch (e) {
      debugPrint("💀 [EDIT PROFILE ERROR]: $e");
      if (e is DioException && e.response != null) {
        debugPrint("🚫 Server Error: ${e.response?.data}");
      }
      return null;
    }
  }


  // ─── GET USER PROFILE (GET METHOD) ───
  static Future<UserProfileModal?> fetchProfile(int userId) async {
    final String url = "${ApiEndoint.baseUrl.trim()}${ApiEndoint.userData}";

    try {
      // ─── DEBUG REQUEST START ───
      debugPrint("🔍 [API REQUEST] Fetching Profile...");
      debugPrint("║ 🔗 URL    : $url");
      debugPrint("║ 🔑 Params : {user_id: $userId}");
      debugPrint("╚═══════════════════════════════════════╝");

      final response = await _dio.get(
        url,
        queryParameters: {
          "user_id": userId, // Dio adds this as ?user_id=3
        },
      );

      // ─── DEBUG RESPONSE ───
      debugPrint("✅ [SERVER RESPONSE]: ${response.data}");

      if (response.statusCode == 200) {
        return UserProfileModal.fromJson(response.data);
      }
      return null;

    } catch (e) {
      debugPrint("💀 [GET PROFILE ERROR]: $e");
      if (e is DioException && e.response != null) {
        debugPrint("║ 🚫 Error Data : ${e.response?.data}");
      }
      return null;
    }
  }


  // ─── FETCH REVIEWS LIST (GET) ───
  static Future<ReviewModal?> ownerfetchReviews(int ownerId) async {
    // Endpoint adjust kar lena agar backend par different ho
    final String url = "${ApiEndoint.baseUrl.trim()}owner-reviews";

    try {
      // ─── DEBUG REQUEST START ───
      debugPrint("💬 [API REQUEST] Fetching Client Feedback...");
      debugPrint("║ 🔗 URL    : $url");
      debugPrint("║ 🔑 Params : {owner_id: $ownerId}");
      debugPrint("╚═══════════════════════════════════════╝");

      final response = await _dio.get(
        url,
        queryParameters: {
          "owner_id": ownerId, // Professional/Owner ID ke basis par reviews fetch honge
        },
      );

      // ─── DEBUG RESPONSE ───
      debugPrint("✅ [REVIEWS RESPONSE]: ${response.data}");

      if (response.statusCode == 200) {
        return ReviewModal.fromJson(response.data);
      }
      return null;

    } catch (e) {
      debugPrint("💀 [REVIEWS ERROR]: $e");
      if (e is DioException && e.response != null) {
        debugPrint("║ 🚫 Error : ${e.response?.data}");
      }
      return null;
    }
  }


  // --- FETCH OWNER EARNINGS (GET) ---
  static Future<OwnerEarningModal?> fetchOwnerEarnings(int ownerId) async {
    final String url = "${ApiEndoint.baseUrl.trim()}owner-earning";

    try {
      final response = await _dio.get(
        url,
        queryParameters: {"owner_id": ownerId},
      );

      if (response.statusCode == 200) {
        return OwnerEarningModal.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("💀 Earning Fetch Error: $e");
      return null;
    }
  }




  // ─── FETCH OWNER EARNING LIST (GET) ───
  static Future<OwnerEarningListModal?> fetchOwnerEarningList(int ownerId) async {
    final String url = "${ApiEndoint.baseUrl.trim()}owner-earning-list";

    try {
      debugPrint("💰 [API REQUEST] Fetching Earning History...");
      debugPrint("║ 🔗 URL: $url?owner_id=$ownerId");

      final response = await _dio.get(
        url,
        queryParameters: {"owner_id": ownerId},
      );

      debugPrint("✅ [SERVER RESPONSE]: ${response.data}");

      if (response.statusCode == 200) {
        return OwnerEarningListModal.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("💀 [EARNING LIST ERROR]: $e");
      return null;
    }
  }


  // ─── DELETE SERVICE (POST/FormData) ───
  Future<Map<String, dynamic>?> deleteService(int serviceId) async {
    final String url = "${ApiEndoint.baseUrl.trim()}delete-service";

    try {
      debugPrint("🗑️ [API REQUEST] Deleting Service...");
      debugPrint("║ 🔗 URL: $url");
      debugPrint("║ 📦 Service ID: $serviceId");

      FormData formData = FormData.fromMap({
        "service_id": serviceId,
      });

      final response = await _dio.post(url, data: formData);

      debugPrint("✅ [DELETE RESPONSE]: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint("💀 [DELETE ERROR]: $e");
      return null;
    }
  }


  // ─── CHECK OWNER STATUS (GET) ───
  static Future<Map<String, dynamic>?> checkOwnerStatus(int ownerId) async {
    final String url = "${ApiEndoint.baseUrl.trim()}check-owner-active";
    try {
      final response = await _dio.get(url, queryParameters: {"owner_id": ownerId});
      if (response.statusCode == 200) return response.data;
      return null;
    } catch (e) {
      debugPrint("💀 Status Check Error: $e");
      return null;
    }
  }


  Future<AddressResponse?> addUserAddress({
    required int userId,
    required String address,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) async {
    try {
      // 1. Create a raw Map first for debugging and payload
      final Map<String, dynamic> dataMap = {
        'user_id': userId,
        'address': address,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
      };

      // 2. Print Request Payload as JSON
      print("🚀 --- API REQUEST PAYLOAD ---");
      print(const JsonEncoder.withIndent('  ').convert(dataMap));
      print("-------------------------------");

      // 3. Convert to FormData (Only if your PHP/Node.js backend requires it)
      final FormData payload = FormData.fromMap(dataMap);

      final response = await _dio.post(
        ApiEndoint.add_address, // Fixed your 'Endoint' typo
        data: payload,
      );

      // 4. PRINT THE RESPONSE
      print("✅ --- API RESPONSE RECEIVED ---");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${jsonEncode(response.data)}"); // Prints the full JSON response
      print("---------------------------------");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddressResponse.fromJson(response.data);
      }
      return null;

    } on DioException catch (e) {
      print("❌ --- API ERROR ---");
      print("Message: ${e.message}");
      if (e.response != null) {
        print("Error Status: ${e.response?.statusCode}");
        print("Error Body: ${jsonEncode(e.response?.data)}");
      }
      return null;
    } catch (e) {
      print("⚠️ GENERAL ERROR: $e");
      return null;
    }
  }


  Future<Map<String, dynamic>?> getUserAddresses(int userId) async {
    try {

print("🚀 Fetching addresses for User ID: $userId");

      final response = await _dio.post(
        ApiEndoint.get_address, // Replace with your actual endpoint
         data:FormData.fromMap({
           "user_id":userId
         })
      );

      if (response.statusCode == 200) {
        return response.data; // Returns the full JSON you provided
      }
      return null;
    } on DioException catch (e) {
      debugPrint("Fetch Address Error: ${e.message}");
      return null;
    }
  }



  static Future<addSherdule?> addSchedule({
    required int professionalId,
    required String day,
    required List<String> timeSlots,
  }) async {
    print("🚀 [API] Sending exact format for Pro ID: $professionalId");

    try {
      // 1. FORMATTING THE LIST
      // This converts ["09:00 AM", "01:00 PM"]
      // into the string: "09:00 AM, 01:00 PM"
      String formattedTimeSlots = timeSlots.join(", ");

      // 2. CREATING THE EXACT FORMDATA
      final FormData formData = FormData.fromMap({
        "professional_id": professionalId.toString(),
        "day": day,
        "time_slots": formattedTimeSlots, // Single string value
      });

      final response = await _dio.post(
        'add_schedule',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      print("📡 [API] Server Response: ${response.data}");

      if (response.statusCode == 200) {
        return addSherdule.fromJson(response.data);
      }
    } on DioException catch (e) {
      print("❌ [API] Error: ${e.message}");
      if (e.response != null) print("Data: ${e.response?.data}");
    }
    return null;
  }


  // Change the return type to List<ScheduleItem>
  static Future<List<ScheduleItem>> getProfessionalSchedule(int proId) async {
    print("🚀 [API] Fetching schedule for Professional ID: $proId");

    try {
      final response = await _dio.post(
        'get_professional_schedule',
        // FIXED: Use queryParameters instead of data/FormData for GET requests
        data: FormData.fromMap({
          "professional_id": proId
        }),
      );

      // DEBUG: Print the raw response so you can see the "double-encoded" string
      print("📡 [API] Raw Response: ${response.data}");

      if (response.statusCode == 200) {
        // Ensure we are accessing the 'data' key from your ScheduleResponse wrapper
        final scheduleResponse = ScheduleResponse.fromJson(response.data);

        if (scheduleResponse.status == true) {
          print("✅ [API] Successfully parsed ${scheduleResponse.data?.length ?? 0} days");
          return scheduleResponse.data ?? [];
        } else {
          print("⚠️ [API] Server returned status false");
        }
      }
    } on DioException catch (e) {
      print("❌ [API] Dio Error: ${e.message}");
      if (e.response != null) {
        print("❌ [API] Server Error Data: ${e.response?.data}");
      }
    } catch (e) {
      print("❌ [API] General Error: $e");
    }

    return [];
  }




  static Future<BookingItem?> getBookingDetails(int id) async {
    try {
      final response = await _dio.get(
        'booking_list_api',
        queryParameters: {"booking_id": id},
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return BookingItem.fromJson(response.data['data'][0]);
      }
    } catch (e) {
      print("API Error: $e");
    }
    return null;
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