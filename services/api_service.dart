import 'dart:convert';
import 'dart:io';
import 'package:fit/models/bot/chatbot_request.dart';
import 'package:fit/models/coach/coach_stats.dart';
import 'package:fit/models/coach/performance_stats.dart';
import 'package:fit/models/coach/program_model.dart';
import 'package:fit/models/coach/store_front_tier.dart';
import 'package:fit/models/coach/tier_model.dart';
import 'package:fit/models/coach/toggle_tier_request.dart';
import 'package:fit/models/coach/trainee_subscriptions.dart';
import 'package:fit/models/coach/wallet_model.dart';
import 'package:fit/models/coach/wallet_transaction_model.dart';
import 'package:fit/models/trainee/coach_programs_model.dart';
import 'package:fit/models/trainee/discovery_coach.dart';
import 'package:fit/models/community/comment.dart';
import 'package:fit/models/community/community_post.dart';
import 'package:fit/models/community/post_likers.dart';
import 'package:fit/models/chat/chat.dart';
import 'package:fit/models/notification/notification.dart';
import 'package:fit/models/profile/certificate.dart';
import 'package:fit/models/profile/follower.dart';
import 'package:fit/models/profile/following.dart';
import 'package:fit/models/profile/profile_posts.dart';
import 'package:fit/models/profile/recommendations.dart';
import 'package:fit/models/profile/user_profile.dart';
import 'package:fit/models/store/product.dart';
import 'package:fit/models/trainee/refund_reviews_model.dart';
import 'package:fit/models/trainee/subscribed_coach.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. تحديث الرابط إلى الـ Dev Tunnel الفعلي واستخدام https
  static const String baseUrl = 'https://sporta.runasp.net/api';

  // دالة مساعدة لتخطي صفحة الحماية الخاصة بـ Dev Tunnels
  static const Map<String, String> _tunnelHeader = {
    'X-Tunnel-Skip-AntiPhishing-Page': 'true',
  };

  // Register user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    DateTime? birthDate,
    String? gender,
    int? height,
    double? weight,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/register'),
        headers: {
          'Content-Type': 'application/json',
          ..._tunnelHeader, // إضافة الهيدر السحري هنا لفتح البوابة
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
          'birthDate': birthDate?.toIso8601String(),
          'gender': gender,
          'height': height,
          'weight': weight,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonDecode(response.body)['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed. Please try again.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/Auth/login');

      print("🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴");
      print("🔴 EXACT URL: $url");
      print("🔴 BASE URL: $baseUrl");
      print("🔴 EMAIL: $email");
      print("🔴 PASSWORD: ${password.substring(0, 1)}****");
      print("🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("🔴 RESPONSE STATUS: ${response.statusCode}");
      print("🔴 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'message': 'Login successful',
        };
      } else {
        return {'success': false, 'message': 'Invalid email or password'};
      }
    } catch (e) {
      print("🔴 EXCEPTION: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Verify email code
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/verify-email'),
        headers: {
          'Content-Type': 'application/json',
          ..._tunnelHeader, // إضافة الهيدر السحري
        },
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': 'Invalid verification code'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Forgot password - send reset code
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          ..._tunnelHeader, // إضافة الهيدر السحري
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Reset code sent to your email'};
      } else {
        return {'success': false, 'message': 'Email not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Reset password with code
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          ..._tunnelHeader, // إضافة الهيدر السحري
        },
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': 'Failed to reset password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // دالة مساعدة تجيب الـ Header اللي فيه التوكن + هيدر تخطي الحماية الافتراضي
  static Future<Map<String, String>> _getAuthHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
      'X-Tunnel-Skip-AntiPhishing-Page':
          'true', // دمج الهيدر هنا ليعمل مع جلب المنتجات وأي دالة تعتمد على التوكن
    };
  }

  // دالة جلب المنتجات المحدثة لترجع المنتجات وعدد الصفحات معاً
  static Future<Map<String, dynamic>> getProducts({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/Products/search?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      final response = await http.get(url, headers: headers);

      print("🔹 API Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic dataField = responseData['data'] ?? responseData['Data'];

        // جلب عدد الصفحات الإجمالي من السيرفر (افتراضياً 1 إذا لم يرسله)
        int serverTotalPages = 1;
        List<dynamic> itemsList = [];

        if (dataField != null) {
          serverTotalPages =
              dataField['totalPages'] ?? dataField['TotalPages'] ?? 1;
          itemsList = dataField['items'] ?? dataField['Items'] ?? [];
        } else if (responseData['items'] != null ||
            responseData['Items'] != null) {
          serverTotalPages =
              responseData['totalPages'] ?? responseData['TotalPages'] ?? 1;
          itemsList = responseData['items'] ?? responseData['Items'] ?? [];
        }

        List<Product> parsedProducts = itemsList
            .map((json) => Product.fromJson(json))
            .toList();

        // نرجع الخريطة التي تحتوي على البيانات معاً
        return {'products': parsedProducts, 'totalPages': serverTotalPages};
      } else {
        throw Exception(
          'Failed to load products. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error while fetching products: $e');
    }
  }

  // Add item to cart - الصياغة الصحيحة والمباشرة
  static Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Cart/items');

      // بناء الهيدرز وتأكيد نوع البيانات JSON
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...authHeaders,
      };

      // الـ Body يحتوي فقط وفقط على الـ productId والـ quantity كما يتوقع السيرفر تماماً
      final Map<String, dynamic> requestBody = {
        'productId': productId,
        'quantity': quantity,
      };

      print("📤 Sending Request to: $url");
      print("I/flutter: 📤 Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        url,
        headers: requestHeaders,
        body: jsonEncode(requestBody),
      );

      print("I/flutter: 🔹 API Response Status: ${response.statusCode}");
      print("I/flutter: 🔹 API Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Product added to cart successfully!',
        };
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to add product.',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // مسح السلة بالكامل بناءً على المسار الصحيح للسيرفر
  static Future<bool> clearCart() async {
    try {
      final authHeaders = await _getAuthHeaders();

      // الرابط المباشر الصحيح تماماً كما يتوقعه السيرفر
      final url = Uri.parse('$baseUrl/Cart');

      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...authHeaders,
      };

      print("🗑️ Sending DELETE request to: $url");

      final response = await http.delete(url, headers: requestHeaders);

      print("🔹 Clear Cart Response Status: ${response.statusCode}");
      print("🔹 Clear Cart Response Body: ${response.body}");

      // السيرفرات تعود بـ 200 أو 204 عند نجاح الحذف الكامل
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Clear Cart Error: $e");
      return false;
    }
  }

  // دالة تحديث الكمية: ترسل الفارق (+1 أو -1) وتقرأ أخطاء المخزون من السيرفر
  static Future<void> updateCartQuantity({
    required String productId,
    required int quantity, // This is now receiving the delta (+1 or -1)
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Cart/items');

      final Map<String, dynamic> requestBody = {
        'productId': productId,
        'quantity': quantity,
      };

      print("🔄 Sending Delta Quantity ($quantity) for product: $productId");

      final response = await http.post(
        url,
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      // 🛡️ LAYER 1 DEFENSE: Handle backend rejections (like Out of Stock)
      if (response.statusCode != 200 && response.statusCode != 201) {
        try {
          // Attempt to read the error message sent by your backend
          final errorData = jsonDecode(response.body);

          // Using 'message' as the key. (Change it if your backend uses 'error' or something else)
          final serverMessage =
              errorData['message'] ?? 'Item is out of stock or unavailable.';

          // Throw the specific server message so the UI can catch it
          throw Exception(serverMessage);
        } catch (_) {
          // Fallback if the server sends HTML or an empty body instead of JSON
          throw Exception(
            'Failed to update quantity (Error ${response.statusCode})',
          );
        }
      }
    } catch (e) {
      print("❌ Update Error: $e");
      // Use 'rethrow' so the exact Exception message goes up to the CartScreen's catch block
      rethrow;
    }
  }

  // 2. دالة حذف منتج المصححة (تأكد منها أيضاً بالأمان)
  static Future<void> removeFromCart({required String productId}) async {
    try {
      final authHeaders = await _getAuthHeaders();

      // إرسال الـ productId كـ String في الرابط مباشرة
      final url = Uri.parse('$baseUrl/Cart/items/$productId');

      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...authHeaders,
      };

      print("❌ Removing Item from: $url");

      final response = await http.delete(url, headers: requestHeaders);

      print("🔹 Remove Response Status: ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove item');
      }
    } catch (e) {
      throw Exception('Network error while removing item: $e');
    }
  }

  static Future<Map<String, dynamic>> submitProductReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Products/reviews');

      final response = await http.post(
        url,
        headers: authHeaders,
        body: jsonEncode({
          'productId': productId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // 🚨 CATCHING THE BUSINESS RULE ERRORS HERE
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ?? 'Failed to submit review.';
          throw Exception(
            errorMessage,
          ); // Throw the exact string from the backend
        } catch (_) {
          // Fallback if the backend doesn't send JSON
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // REPLACE THE OLD METHOD WITH THIS:
  static Future<bool> isUserEligibleToReview(String productId) async {
    try {
      // 1. Reuse your working order history endpoint
      final List<dynamic> orders = await getOrderHistory();

      // 2. Iterate through orders to see if this product was successfully paid for
      return orders.any((order) {
        // Enforce: Order status must be Paid or Approved
        final String currentStatus =
            (order['status'] ?? order['orderStatus'] ?? '').toString();
        bool isPaid = currentStatus == 'paid' || currentStatus == 'approved';

        if (!isPaid) return false;

        // Check flat structure: if item is directly in the order map
        if (order['productId']?.toString() == productId) return true;

        // Check nested structure: if items are in an inner list
        final items =
            order['items'] as List<dynamic>? ??
            order['orderItems'] as List<dynamic>? ??
            [];

        return items.any((item) => item['productId']?.toString() == productId);
      });
    } catch (e) {
      print("❌ Error checking review eligibility locally: $e");
      return false; // Safely default to false if network fails
    }
  }

  static Future<List<dynamic>> getProductReviews(String productId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Products/$productId/reviews');

      print("📥 Fetching reviews from: $url");
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Adjust the key ('data' or 'items') based on your standard API response structure
        return (jsonResponse['data'] as List<dynamic>? ??
            jsonResponse['items'] as List<dynamic>? ??
            []);
      } else if (response.statusCode == 404) {
        return []; // Return empty list gracefully if there are no reviews yet
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching product reviews: $e");
      rethrow;
    }
  }

  // Add this inside your ApiService class
  static Future<Map<String, dynamic>> createOrderCheckout({
    required String paymentType,
    List<Map<String, dynamic>>? items,
    String?
    successUrl, // Made these optional so you can pass custom ones if needed
    String? cancelUrl,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Orders/checkout');

      print("📤 Sending Checkout Request to: $url");

      // Define your app's deep link schemes or fallback web domains
      final String defaultSuccessUrl =
          successUrl ?? "fitapp://store/payment-success";
      final String defaultCancelUrl =
          cancelUrl ?? "fitapp://store/payment-cancel";

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', ...authHeaders},
        body: jsonEncode({
          'paymentType': paymentType,
          if (items != null) 'items': items,
          // Adding the new dynamic redirect URLs your backend engineer requested
          'successUrl': defaultSuccessUrl,
          'cancelUrl': defaultCancelUrl,
        }),
      );

      print("📥 Server Response Status: ${response.statusCode}");
      print("📥 Server Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print("❌ API SERVICE ERROR: $e");
      throw e;
    }
  }

  static Future<List<dynamic>> getOrderHistory() async {
    try {
      print("DEBUG: Function started");

      // 1. Get the correct headers (Token + Tunnel Skip)
      final headers = await _getAuthHeaders();

      // 2. Use the exact URL path from your working cURL
      final url = Uri.parse('$baseUrl/Orders/my-orders');

      print("DEBUG: Calling URL: $url");
      final response = await http.get(url, headers: headers);

      print("DEBUG: Response received with status ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Use the 'data' key as you confirmed previously
        return (jsonResponse['data']['items'] as List<dynamic>);
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print("DEBUG: CRASHED IN APISERVICE: $e");
      rethrow;
    }
  }

  static Future<UserProfile> getUserProfile(String id) async {
    try {
      // 👇 ADD THIS LINE HERE TO SEE THE ID VALUE
      print("🆔 DEBUG: The ID being passed into getUserProfile is: '$id'");

      final authHeaders = await _getAuthHeaders();

      print("🌐 DEBUG: Requesting full URL -> $baseUrl/Profile/$id/header");

      final url = Uri.parse('$baseUrl/Profile/$id/header');

      final response = await http.get(url, headers: authHeaders);

      print("📥 Profile API Status: ${response.statusCode}");
      print("📥 Profile API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return UserProfile.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching user profile from API: $e");
      rethrow;
    }
  }

  // Add this to your existing ApiService class
  static Future<String?> getImageUrlWithAuth(String imagePath) async {
    if (imagePath.isEmpty) return null;

    // If it's a local file, return as is
    if (imagePath.startsWith('/storage/') ||
        imagePath.startsWith('file://') ||
        imagePath.startsWith('/data/')) {
      return imagePath;
    }

    // For network images, create an authenticated URL
    // This assumes your backend has an endpoint to serve images with auth
    final cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;
    return '$baseUrl/Profile/image?path=$cleanPath';
  }

  // Update basic profile info
  static Future<Map<String, dynamic>> updateBasicProfile({
    required String fullName,
    required String about,
    required String country,
    required String city,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/edit/basic');

      final response = await http.put(
        url,
        headers: authHeaders,
        body: jsonEncode({
          'fullName': fullName,
          'about': about,
          'country': country,
          'city': city,
        }),
      );

      print("📤 Update Basic Profile Response: ${response.statusCode}");
      print("📤 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Profile updated successfully'};
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error updating basic profile: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update contact info
  static Future<Map<String, dynamic>> updateContactInfo({
    required String phone,
    required String address,
    required String email,
    required DateTime birthDate,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/edit/contact');

      final response = await http.put(
        url,
        headers: authHeaders,
        body: jsonEncode({
          'phone': phone,
          'address': address,
          'email': email,
          'birthDate': birthDate.toIso8601String(),
        }),
      );

      print("📤 Update Contact Info Response: ${response.statusCode}");
      print("📤 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Contact info updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update contact info: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error updating contact info: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete profile image
  static Future<Map<String, dynamic>> deleteProfileImage() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/profile-image');

      final response = await http.delete(url, headers: authHeaders);

      print("📤 Delete Profile Image Response: ${response.statusCode}");
      print("📤 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile image deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete profile image: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting profile image: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Upload profile image
  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/profile-image');

      // Create multipart request for file upload
      final request = http.MultipartRequest('PUT', url);

      // Add headers (excluding Content-Type as it will be set automatically for multipart)
      request.headers.addAll({
        'Authorization': authHeaders['Authorization'] ?? '',
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
      });

      // Add the image file
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'ProfileImage', // Field name expected by the server
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );

      request.files.add(multipartFile);

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📤 Upload Profile Image Response Status: ${response.statusCode}");
      print("📤 Response Body: $responseBody");

      if (response.statusCode == 200) {
        // Parse the response to get the new image URL
        final Map<String, dynamic> responseData = jsonDecode(responseBody);

        // The 'data' field is directly the image path string, not an object
        final String imageUrl = responseData['data'] as String;

        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Profile image uploaded successfully',
          'imageUrl': imageUrl,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload profile image: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error uploading profile image: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Upload cover image
  static Future<Map<String, dynamic>> uploadCoverImage(File imageFile) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/cover-image');

      // Create multipart request for file upload
      final request = http.MultipartRequest('PUT', url);

      // Add headers
      request.headers.addAll({
        'Authorization': authHeaders['Authorization'] ?? '',
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
      });

      // Add the image file with the correct field name
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'CoverImage', // Field name expected by the server
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );

      request.files.add(multipartFile);

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📤 Upload Cover Image Response Status: ${response.statusCode}");
      print("📤 Response Body: $responseBody");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(responseBody);

        // The 'data' field is directly the image path string
        final String imageUrl = responseData['data'] as String;

        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Cover image uploaded successfully',
          'imageUrl': imageUrl,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload cover image: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error uploading cover image: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete cover image
  static Future<Map<String, dynamic>> deleteCoverImage() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/cover-image');

      final response = await http.delete(url, headers: authHeaders);

      print("📤 Delete Cover Image Response Status: ${response.statusCode}");
      print("📤 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Cover image deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete cover image: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting cover image: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get discovery coaches (trainers)
  static Future<Map<String, dynamic>> getDiscoveryCoaches({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    double? minRating,
    double? maxPrice,
    bool? isVerified,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();

      // Build query parameters
      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (minRating != null) {
        queryParams['minRating'] = minRating.toString();
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }
      if (isVerified != null) {
        queryParams['isVerified'] = isVerified.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/discovery/coaches',
      ).replace(queryParameters: queryParams);

      print("🌐 GET Discovery Coaches URL: $uri");

      final response = await http.get(uri, headers: authHeaders);

      print("📥 Discovery Coaches API Status: ${response.statusCode}");
      print("📥 Discovery Coaches API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final dynamic dataField = jsonResponse['data'] ?? jsonResponse['Data'];

        // Extract pagination info (matching your getProducts pattern)
        int totalPages = 1;
        int totalCount = 0;
        int currentPage = pageNumber;
        List<dynamic> itemsList = [];

        if (dataField != null) {
          totalPages = dataField['totalPages'] ?? dataField['TotalPages'] ?? 1;
          totalCount = dataField['totalCount'] ?? dataField['TotalCount'] ?? 0;
          currentPage =
              dataField['currentPage'] ??
              dataField['CurrentPage'] ??
              pageNumber;
          itemsList = dataField['items'] ?? dataField['Items'] ?? [];
        } else if (jsonResponse['items'] != null ||
            jsonResponse['Items'] != null) {
          totalPages =
              jsonResponse['totalPages'] ?? jsonResponse['TotalPages'] ?? 1;
          totalCount =
              jsonResponse['totalCount'] ?? jsonResponse['TotalCount'] ?? 0;
          currentPage =
              jsonResponse['currentPage'] ??
              jsonResponse['CurrentPage'] ??
              pageNumber;
          itemsList = jsonResponse['items'] ?? jsonResponse['Items'] ?? [];
        }

        List<DiscoveryCoach> coaches = itemsList
            .map((json) => DiscoveryCoach.fromJson(json))
            .toList();

        // Return the data with pagination info (matching getProducts pattern)
        return {
          'coaches': coaches,
          'totalPages': totalPages,
          'totalCount': totalCount,
          'currentPage': currentPage,
          'hasNextPage': currentPage < totalPages,
          'hasPreviousPage': currentPage > 1,
        };
      } else {
        throw Exception('Failed to fetch coaches: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching discovery coaches: $e");
      throw Exception('Network error while fetching coaches: $e');
    }
  }

  // Get user followers with pagination
  static Future<FollowersResponse> getUserFollowers({
    required String userId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/Profile/$userId/followers?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      print("🌐 GET Followers URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Followers API Status: ${response.statusCode}");
      print("📥 Followers API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return FollowersResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch followers: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching followers: $e");
      rethrow;
    }
  }

  // Get users that a specific user is following
  static Future<FollowingResponse> getUserFollowing({
    required String userId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/users/$userId/following?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      print("🌐 GET Following URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Following API Status: ${response.statusCode}");
      print("📥 Following API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return FollowingResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch following: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching following: $e");
      rethrow;
    }
  }

  // Toggle follow/unfollow a user
  static Future<Map<String, dynamic>> toggleFollowUser({
    required String userId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/users/$userId/toggle');

      print("🌐 POST Toggle Follow URL: $url");

      final response = await http.post(
        url,
        headers: authHeaders,
        body: jsonEncode({}), // Empty body as per your endpoint
      );

      print("📥 Toggle Follow API Status: ${response.statusCode}");
      print("📥 Toggle Follow API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'isFollowing':
              jsonResponse['data']?['isFollowing'] ??
              jsonResponse['isFollowing'] ??
              false,
          'message': jsonResponse['message'] ?? 'Operation successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to toggle follow: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error toggling follow: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Check if current user is following a specific user
  static Future<Map<String, dynamic>> getFollowStatus({
    required String userId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/users/$userId/status');

      print("🌐 GET Follow Status URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Follow Status API Status: ${response.statusCode}");
      print("📥 Follow Status API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check different possible response structures
        bool isFollowing = false;
        if (jsonResponse['data'] != null) {
          isFollowing =
              jsonResponse['data']['isFollowing'] ??
              jsonResponse['data']['isFollowedByCurrentUser'] ??
              false;
        } else {
          isFollowing =
              jsonResponse['isFollowing'] ??
              jsonResponse['isFollowedByCurrentUser'] ??
              false;
        }

        return {
          'success': true,
          'isFollowing': isFollowing,
          'message': jsonResponse['message'] ?? 'Operation successful',
        };
      } else {
        throw Exception('Failed to get follow status: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error getting follow status: $e");
      rethrow;
    }
  }

  // Get coach certificates
  static Future<List<CoachCertificate>> getCoachCertificates({
    required String coachId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachCertificates/$coachId');

      print("🌐 GET Coach Certificates URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Coach Certificates API Status: ${response.statusCode}");
      print("📥 Coach Certificates API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] as List<dynamic>? ?? [];

        return data.map((item) => CoachCertificate.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to fetch coach certificates: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error fetching coach certificates: $e");
      rethrow;
    }
  }

  // Add coach certificate - EXACTLY like cover image upload
  static Future<Map<String, dynamic>> addCoachCertificate({
    required String title,
    required String issuer,
    required int date,
    File? imageFile,
    required String credentialUrl,
    List<String>? skills,
    String? description,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachCertificates');

      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': authHeaders['Authorization'] ?? '',
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
      });

      request.fields['title'] = title;
      request.fields['issuer'] = issuer;
      request.fields['Year'] = date.toString();
      request.fields['credentialUrl'] = credentialUrl;

      if (skills != null && skills.isNotEmpty) {
        request.fields['skills'] = skills.join(',');
      }
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      if (imageFile != null) {
        final stream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();
        final multipartFile = http.MultipartFile(
          'imageFile', // TRY THIS FIELD NAME
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      print("📤 FIELDS: ${request.fields}");
      print("📤 FILES: ${request.files.length}");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📥 RESPONSE: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Certificate added successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add certificate: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update coach certificate - EXACTLY like cover image upload
  static Future<Map<String, dynamic>> updateCoachCertificate({
    required String certificateId,
    required String title,
    required String issuer,
    required int date,
    File? imageFile,
    String? existingImageUrl,
    required String credentialUrl,
    List<String>? skills,
    String? description,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachCertificates/$certificateId');

      // Create multipart request
      final request = http.MultipartRequest('PUT', url);

      // Add headers
      request.headers.addAll({
        'Authorization': authHeaders['Authorization'] ?? '',
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
      });

      // Add text fields
      request.fields['title'] = title;
      request.fields['issuer'] = issuer;
      request.fields['Year'] = date.toString();
      request.fields['credentialUrl'] = credentialUrl;

      if (skills != null && skills.isNotEmpty) {
        request.fields['skills'] = skills.join(',');
      }
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      // Add existing image URL if no new file
      if (existingImageUrl != null &&
          existingImageUrl.isNotEmpty &&
          imageFile == null) {
        request.fields['image'] = existingImageUrl;
      }

      // Add image file if provided - SAME AS COVER IMAGE
      if (imageFile != null) {
        final stream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();
        final multipartFile = http.MultipartFile(
          'imageFile', // Same pattern as CoverImage and ProfileImage
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
        print("📤 Uploading certificate image: ${imageFile.path}");
      }

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📥 Update Certificate API Status: ${response.statusCode}");
      print("📥 Update Certificate API Body: $responseBody");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Certificate updated successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update certificate: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error updating coach certificate: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete coach certificate
  static Future<Map<String, dynamic>> deleteCoachCertificate({
    required String certificateId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachCertificates/$certificateId');

      print("🌐 DELETE Coach Certificate URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Certificate API Status: ${response.statusCode}");
      print("📥 Delete Certificate API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Certificate deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete certificate: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting coach certificate: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get user recommendations (received and given)
  static Future<RecommendationsResponse> getUserRecommendations({
    required String userId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/$userId/recommendations');

      print("🌐 GET Recommendations URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Recommendations API Status: ${response.statusCode}");
      print("📥 Recommendations API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return RecommendationsResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Failed to fetch recommendations: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error fetching recommendations: $e");
      rethrow;
    }
  }

  // Send a recommendation request
  static Future<Map<String, dynamic>> sendRecommendationRequest({
    required String receiverId,
    required String content,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Recommendations/request');

      final Map<String, dynamic> requestBody = {
        'receiverId': receiverId,
        'content': content,
      };

      print("🌐 POST Recommendation Request URL: $url");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        url,
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      print("📥 Recommendation Request API Status: ${response.statusCode}");
      print("📥 Recommendation Request API Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              jsonResponse['message'] ??
              'Recommendation request sent successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to send recommendation request: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error sending recommendation request: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Give a recommendation directly
  static Future<Map<String, dynamic>> giveRecommendation({
    required String receiverId,
    required String content,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Recommendations/give');

      final Map<String, dynamic> requestBody = {
        'receiverId': receiverId,
        'content': content,
      };

      print("🌐 POST Give Recommendation URL: $url");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        url,
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      print("📥 Give Recommendation API Status: ${response.statusCode}");
      print("📥 Give Recommendation API Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Recommendation given successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to give recommendation: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error giving recommendation: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete a recommendation
  static Future<Map<String, dynamic>> deleteRecommendation({
    required String recommendationId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Recommendations/$recommendationId');

      print("🌐 DELETE Recommendation URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Recommendation API Status: ${response.statusCode}");
      print("📥 Delete Recommendation API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Recommendation deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete recommendation: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting recommendation: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get notifications
  static Future<NotificationsResponse> getNotifications({
    int pageNumber = 1,
    int pageSize = 15,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/Notification?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      print("🌐 GET Notifications URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Notifications API Status: ${response.statusCode}");
      print("📥 Notifications API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return NotificationsResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      rethrow;
    }
  }

  // Mark a single notification as read
  static Future<Map<String, dynamic>> markNotificationAsRead({
    required String notificationId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Notification/$notificationId/read');

      print("🌐 PUT Mark Notification Read URL: $url");

      final response = await http.put(url, headers: authHeaders);

      print("📥 Mark Notification Read API Status: ${response.statusCode}");
      print("📥 Mark Notification Read API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Notification marked as read',
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to mark notification as read: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error marking notification as read: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Mark all notifications as read
  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Notification/read-all');

      print("🌐 PUT Mark All Notifications Read URL: $url");

      final response = await http.put(url, headers: authHeaders);

      print(
        "📥 Mark All Notifications Read API Status: ${response.statusCode}",
      );
      print("📥 Mark All Notifications Read API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'All notifications marked as read',
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to mark all notifications as read: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error marking all notifications as read: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Create a community post (with optional images and location)
  static Future<Map<String, dynamic>> createCommunityPost({
    required String content,
    List<File>? mediaFiles,
    Location? location,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/posts');

      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': authHeaders['Authorization'] ?? '',
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
      });

      request.fields['content'] = content;

      if (location != null) {
        request.fields['Location.Lat'] = location.lat.toString();
        request.fields['Location.Lng'] = location.lng.toString();
        request.fields['Location.Name'] = location.name;
      }

      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (int i = 0; i < mediaFiles.length; i++) {
          final file = mediaFiles[i];
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            'MediaFiles',
            stream,
            length,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📥 Create Post API Status: ${response.statusCode}");
      print("📥 Create Post API Body: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Post created successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error creating post: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get community feed
  static Future<CommunityFeedResponse> getCommunityFeed({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/Community/posts/feed?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      print("🌐 GET Community Feed URL: $url");

      // Make sure the headers include the tunnel bypass
      final headers = {
        ...authHeaders,
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
      };

      final response = await http.get(url, headers: headers);

      print("📥 Community Feed API Status: ${response.statusCode}");
      print(
        "📥 Community Feed API Body: ${response.body.substring(0, 200)}",
      ); // Print first 200 chars

      if (response.statusCode == 200) {
        // Check if response is JSON (not HTML)
        if (response.body.trim().startsWith('{')) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          return CommunityFeedResponse.fromJson(jsonResponse);
        } else {
          print("❌ API returned HTML instead of JSON - Tunnel blocking");
          throw Exception('Tunnel blocking the request');
        }
      } else {
        throw Exception(
          'Failed to fetch community feed: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error fetching community feed: $e");
      rethrow;
    }
  }

  // Like/Unlike a community post
  static Future<Map<String, dynamic>> likeCommunityPost({
    required String postId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/posts/$postId/like');

      print("🌐 POST Like Community Post URL: $url");

      final response = await http.post(url, headers: authHeaders);

      print("📥 Like Community Post API Status: ${response.statusCode}");
      print("📥 Like Community Post API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'isLiked': jsonResponse['data']?['isLiked'] ?? false,
          'likesCount': jsonResponse['data']?['likesCount'] ?? 0,
          'message': jsonResponse['message'] ?? 'Operation successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to like post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error liking community post: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateCommunityPost({
    required String postId,
    required String content,
    List<File>? newMediaFiles,
    List<String>? deletedMediaUrls,
    Location? location,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/posts/$postId');

      final request = http.MultipartRequest('PUT', url);

      request.headers.addAll({
        'Authorization': authHeaders['Authorization'] ?? '',
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
      });

      request.fields['content'] = content;

      if (location != null) {
        request.fields['Location.Lat'] = location.lat.toString();
        request.fields['Location.Lng'] = location.lng.toString();
        request.fields['Location.Name'] = location.name;
      }

      if (deletedMediaUrls != null && deletedMediaUrls.isNotEmpty) {
        print(
          "🗑️ SENDING DELETED URLS TO API: ${deletedMediaUrls.join(', ')}",
        );
        request.fields['DeletedMediaUrls'] = deletedMediaUrls.join(',');
      }

      if (newMediaFiles != null && newMediaFiles.isNotEmpty) {
        for (int i = 0; i < newMediaFiles.length; i++) {
          final file = newMediaFiles[i];
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            'NewMediaFiles',
            stream,
            length,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📥 Update Post API Status: ${response.statusCode}");
      print("📥 Update Post API Body: $responseBody");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Post updated successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error updating post: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete a community post
  static Future<Map<String, dynamic>> deleteCommunityPost({
    required String postId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/posts/$postId');

      print("🌐 DELETE Community Post URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Post API Status: ${response.statusCode}");
      print("📥 Delete Post API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Post deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete post: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting post: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> toggleRepost(String postId) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/posts/$postId/toggle-repost');

      print("🌐 POST Toggle Repost URL: $url");

      final response = await http.post(
        url,
        headers: {...authHeaders, 'Content-Type': 'application/json'},
      );

      print("📥 Toggle Repost API Status: ${response.statusCode}");
      print("📥 Toggle Repost API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Repost toggled successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to toggle repost: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error toggling repost: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get current user basic info
  static Future<Map<String, dynamic>> getMyBasicInfo() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/me/basic-info');

      print("🌐 GET My Basic Info URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 My Basic Info API Status: ${response.statusCode}");
      print("📥 My Basic Info API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {'success': true, 'data': jsonResponse['data']};
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching user info: $e");
      rethrow;
    }
  }

  // Get user profile posts
  static Future<ProfilePostsResponse> getUserProfilePosts({
    required String userId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/$userId/posts');

      print("🌐 GET User Profile Posts URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 User Profile Posts API Status: ${response.statusCode}");
      print("📥 User Profile Posts API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ProfilePostsResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Failed to fetch profile posts: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error fetching profile posts: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> toggleCommunityPostLike({
    required String postId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/posts/$postId/toggle-like');

      print("🌐 POST Toggle Like URL: $url");

      final response = await http.post(url, headers: authHeaders);

      print("📥 Toggle Like API Status: ${response.statusCode}");
      print("📥 Toggle Like API Body: ${response.body}");

      if (response.statusCode == 200) {
        // Try to parse the response as boolean first
        final dynamic responseData = jsonDecode(response.body);

        // If the response is just true/false
        if (responseData is bool) {
          return {
            'success': true,
            'isLiked': responseData,
            'likesCount':
                0, // You'll need to fetch this separately or from the response
          };
        }

        // If it's a JSON object
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'];
          return {
            'success': true,
            'isLiked': data is bool ? data : (data['isLiked'] ?? false),
            'likesCount': data is Map ? (data['likesCount'] ?? 0) : 0,
          };
        }

        return {'success': true, 'isLiked': true, 'likesCount': 0};
      } else {
        return {
          'success': false,
          'message': 'Failed to toggle like: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error toggling like: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get users who liked a post
  static Future<LikersResponse> getPostLikers({
    required String postId,
    int pageNumber = 1,
    int pageSize = 15,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/Community/posts/$postId/likers?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      print("🌐 GET Post Likers URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Post Likers API Status: ${response.statusCode}");
      print("📥 Post Likers API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return LikersResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch likers: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching likers: $e");
      rethrow;
    }
  }

  // Get comments for a post
  static Future<CommentsResponse> getPostComments({
    required String postId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/Community/posts/$postId/comments?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      print("🌐 GET Comments URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Comments API Status: ${response.statusCode}");
      print("📥 Comments API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return CommentsResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch comments: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching comments: $e");
      rethrow;
    }
  }

  // Add a comment
  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/comments');

      final Map<String, dynamic> requestBody = {
        'postId': postId,
        'content': content,
      };

      print("🌐 POST Add Comment URL: $url");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        url,
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      print("📥 Add Comment API Status: ${response.statusCode}");
      print("📥 Add Comment API Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Comment added',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add comment: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error adding comment: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update a comment
  static Future<Map<String, dynamic>> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/comments/$commentId');

      final Map<String, dynamic> requestBody = {'content': content};

      print("🌐 PUT Update Comment URL: $url");
      print("📤 Request Body: $requestBody");

      final response = await http.put(
        url,
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      print("📥 Update Comment API Status: ${response.statusCode}");
      print("📥 Update Comment API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Comment updated',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update comment: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error updating comment: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete a comment
  static Future<Map<String, dynamic>> deleteComment({
    required String commentId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/comments/$commentId');

      print("🌐 DELETE Comment URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Comment API Status: ${response.statusCode}");
      print("📥 Delete Comment API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Comment deleted',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete comment: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting comment: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Like/Unlike a comment
  static Future<Map<String, dynamic>> toggleCommentLike({
    required String commentId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Community/comments/$commentId/like');

      print("🌐 POST Toggle Comment Like URL: $url");

      final response = await http.post(url, headers: authHeaders);

      print("📥 Toggle Comment Like API Status: ${response.statusCode}");
      print("📥 Toggle Comment Like API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'isLiked': jsonResponse['data']?['isLiked'] ?? false,
          'likesCount': jsonResponse['data']?['likesCount'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to toggle like: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error toggling comment like: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String content,
    String? parentMessageId,
    File? attachment,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chat/send');

      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': authHeaders['Authorization'] ?? '',
        'X-Tunnel-Skip-AntiPhishing-Page': 'true',
      });

      request.fields['ReceiverId'] = receiverId;
      request.fields['Content'] = content;

      if (parentMessageId != null && parentMessageId.isNotEmpty) {
        request.fields['ParentMessageId'] = parentMessageId;
      }

      print("📤 Attachment file exists: ${attachment != null}");
      if (attachment != null) {
        final stream = http.ByteStream(attachment.openRead());
        final length = await attachment.length();
        print("📤 Attachment path: ${attachment.path}");
        print("📤 Attachment size: $length bytes");
        print("📤 Attachment name: ${attachment.path.split('/').last}");
        final multipartFile = http.MultipartFile(
          'Attachment', // ← Field name must match API expectation
          stream,
          length,
          filename: attachment.path.split('/').last,
        );
        request.files.add(multipartFile);
        print("📤 Attaching file: ${attachment.path}");
      }

      print("📤 Sending message with fields: ${request.fields}");
      print("📤 Files count: ${request.files.length}");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📥 Send Message API Status: ${response.statusCode}");
      print("📥 Send Message API Body: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Message sent',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send message: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error sending message: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get inbox (list of conversations)
  static Future<InboxResponse> getInbox({String? searchTerm}) async {
    try {
      final authHeaders = await _getAuthHeaders();
      var url = Uri.parse('$baseUrl/Chat/inbox');

      if (searchTerm != null && searchTerm.isNotEmpty) {
        url = Uri.parse('$baseUrl/Chat/inbox?searchTerm=$searchTerm');
      }

      print("🌐 GET Inbox URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Inbox API Status: ${response.statusCode}");
      print(
        "📥 Inbox API RAW BODY: ${response.body}",
      ); // ADD THIS - SEE WHAT API RETURNS

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("📥 PARSED RESPONSE: $jsonResponse"); // ADD THIS
        return InboxResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch inbox: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching inbox: $e");
      rethrow;
    }
  }

  // Get chat history with a specific user
  static Future<ChatHistoryResponse> getChatHistory({
    required String otherUserId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/Chat/history/$otherUserId?pageNumber=$pageNumber&pageSize=$pageSize',
      );

      print("🌐 GET Chat History URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Chat History API Status: ${response.statusCode}");
      print(
        "📥 Chat History API Body: ${response.body}",
      ); // MAKE SURE THIS PRINTS

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("📥 Parsed response: $jsonResponse"); // ADD THIS
        final currentUserId = await _getCurrentUserId();
        return ChatHistoryResponse.fromJson(jsonResponse, currentUserId);
      } else {
        throw Exception('Failed to fetch chat history: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching chat history: $e");
      rethrow;
    }
  }

  // Delete chat history with a user
  static Future<Map<String, dynamic>> deleteChatHistory({
    required String otherUserId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chat/history/$otherUserId');

      print("🌐 DELETE Chat History URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Chat History API Status: ${response.statusCode}");
      print("📥 Delete Chat History API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Chat history deleted',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete chat history: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting chat history: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Helper to get current user ID
  static Future<String> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  // Mark messages as read for a specific user
  static Future<Map<String, dynamic>> markMessagesAsRead({
    required String otherUserId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chat/mark-read/$otherUserId');

      print("🌐 PUT Mark Messages as Read URL: $url");

      final response = await http.put(url, headers: authHeaders);

      print("📥 Mark Messages as Read API Status: ${response.statusCode}");
      print("📥 Mark Messages as Read API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Messages marked as read',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to mark messages as read: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error marking messages as read: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Add reaction to a message
  static Future<Map<String, dynamic>> addMessageReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chat/messages/$messageId/react');

      final Map<String, dynamic> requestBody = {'emoji': emoji};

      print("🌐 POST Add Reaction URL: $url");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        url,
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      print("📥 Add Reaction API Status: ${response.statusCode}");
      print("📥 Add Reaction API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Reaction added',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add reaction: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error adding reaction: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Edit a message
  static Future<Map<String, dynamic>> editMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chat/messages/$messageId');

      final Map<String, dynamic> requestBody = {'NewContent': content};

      print("🌐 PUT Edit Message URL: $url");
      print("📤 Request Body: $requestBody");

      final response = await http.put(
        url,
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      print("📥 Edit Message API Status: ${response.statusCode}");
      print("📥 Edit Message API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Message updated',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to edit message: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error editing message: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete a message
  static Future<Map<String, dynamic>> deleteMessage({
    required String messageId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chat/messages/$messageId');

      print("🌐 DELETE Message URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Message API Status: ${response.statusCode}");
      print("📥 Delete Message API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Message deleted',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete message: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting message: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Toggle block/unblock a user
  static Future<Map<String, dynamic>> toggleBlockUser({
    required String blockedUserId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chat/users/$blockedUserId/toggle-block');

      print("🌐 POST Toggle Block User URL: $url");

      final response = await http.post(url, headers: authHeaders);

      print("📥 Toggle Block User API Status: ${response.statusCode}");
      print("📥 Toggle Block User API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'isBlocked': jsonResponse['data']?['isBlocked'] ?? false,
          'message': jsonResponse['message'] ?? 'User block status toggled',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to toggle block: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error toggling block: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete entire conversation
  static Future<Map<String, dynamic>> deleteConversation({
    required String otherUserId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chat/conversations/$otherUserId/delete');

      print("🌐 DELETE Conversation URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Conversation API Status: ${response.statusCode}");
      print("📥 Delete Conversation API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Conversation deleted',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete conversation: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting conversation: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get overall performance stats for coach workspace
  static Future<PerformanceStats> getOverallPerformanceStats() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/CoachWorkspace/overall-performance-stats',
      );

      print("🌐 GET Overall Performance Stats URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Overall Performance Stats API Status: ${response.statusCode}");
      print("📥 Overall Performance Stats API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] ?? jsonResponse;
        return PerformanceStats.fromJson(data);
      } else {
        throw Exception(
          'Failed to fetch performance stats: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error fetching performance stats: $e");
      rethrow;
    }
  }

  static Future<bool> toggleTierActiveStatus(
    String tierName,
    bool isActive,
  ) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/CoachWorkspace/tiers/$tierName/toggle-active',
      );

      final requestBody = ToggleTierRequest(isActive: isActive);

      print("🌐 PATCH Toggle Tier URL: $url");
      print("📤 Request Body: ${jsonEncode(requestBody.toJson())}");

      final response = await http.patch(
        url,
        headers: {...authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody.toJson()),
      );

      print("📥 Toggle Tier API Status: ${response.statusCode}");
      print("📥 Toggle Tier API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final toggleResponse = ToggleTierResponse.fromJson(jsonResponse);

        if (toggleResponse.isSuccess) {
          return true;
        } else {
          throw Exception('Failed to toggle tier: ${toggleResponse.message}');
        }
      } else {
        throw Exception('Failed to toggle tier: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error toggling tier: $e");
      rethrow;
    }
  }

  static Future<bool> updateTierConfiguration(
    String tierName, {
    required String oneOnOneCallsOption,
    required String emergencyAdjustmentsOption,
    required List<String> customFeatures,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachWorkspace/tiers/$tierName');

      final requestBody = UpdateTierRequest(
        oneOnOneCallsOption: oneOnOneCallsOption,
        emergencyAdjustmentsOption: emergencyAdjustmentsOption,
        customFeatures: customFeatures,
      );

      print("🌐 PUT Update Tier URL: $url");
      print("📤 Request Body: ${jsonEncode(requestBody.toJson())}");

      final response = await http.put(
        url,
        headers: {...authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody.toJson()),
      );

      print("📥 Update Tier API Status: ${response.statusCode}");
      print("📥 Update Tier API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final updateResponse = UpdateTierResponse.fromJson(jsonResponse);

        if (updateResponse.isSuccess) {
          return true;
        } else {
          throw Exception('Failed to update tier: ${updateResponse.message}');
        }
      } else {
        throw Exception('Failed to update tier: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error updating tier: $e");
      rethrow;
    }
  }

  static Future<TierDetailsData> getTierDetails(
    String tierName, {
    String timeframe = "Past Week",
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/CoachWorkspace/tiers/$tierName/details?timeframe=$timeframe',
      );

      print("🌐 GET Tier Details URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Tier Details API Status: ${response.statusCode}");
      print("📥 Tier Details API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final detailsResponse = TierDetailsResponse.fromJson(jsonResponse);

        if (detailsResponse.isSuccess) {
          return detailsResponse.data;
        } else {
          throw Exception('API Error: ${detailsResponse.message}');
        }
      } else {
        throw Exception('Failed to fetch tier details: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching tier details: $e");
      rethrow;
    }
  }

  // Create Program (POST) - Simplified
  static Future<ProgramData> createProgram({
    required String tierId,
    required String title,
    required String description,
    required String serviceType,
    required int durationInWeeks,
    required List<String> features,
    required String status,
    required double basePrice,
    required double discount,
    required String discountType,
    String? discountEndDate,
    File? thumbnailImage,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachWorkspace/programs');

      http.Response response;

      // If there's an image, use multipart
      if (thumbnailImage != null) {
        var request = http.MultipartRequest('POST', url);
        request.headers.addAll(authHeaders);

        request.fields['tierId'] = tierId;
        request.fields['title'] = title;
        request.fields['description'] = description;
        request.fields['serviceType'] = serviceType;
        request.fields['durationInWeeks'] = durationInWeeks.toString();
        request.fields['features'] = jsonEncode(features);
        request.fields['status'] = status;
        request.fields['basePrice'] = basePrice.toString();
        request.fields['discount'] = discount.toString();
        request.fields['discountType'] = discountType;
        if (discountEndDate != null && discountEndDate.isNotEmpty) {
          request.fields['discountEndDate'] = discountEndDate;
        }

        var multipartFile = await http.MultipartFile.fromPath(
          'thumbnailImage',
          thumbnailImage.path,
        );
        request.files.add(multipartFile);

        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // No image, use JSON
        final requestBody = {
          'tierId': tierId,
          'title': title,
          'description': description,
          'serviceType': serviceType,
          'durationInWeeks': durationInWeeks,
          'features': features,
          'status': status,
          'basePrice': basePrice,
          'discount': discount,
          'discountType': discountType,
          if (discountEndDate != null && discountEndDate.isNotEmpty)
            'discountEndDate': discountEndDate,
        };

        response = await http.post(
          url,
          headers: {...authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
      }

      print("📥 Create Program API Status: ${response.statusCode}");
      print("📥 Create Program API Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isSuccess'] == true) {
          // Just return a simple object with the ID
          return ProgramData(
            id: jsonResponse['data'] as String,
            tierId: tierId,
            title: title,
            description: description,
            serviceType: serviceType,
            durationInWeeks: durationInWeeks,
            features: features,
            status: status,
            basePrice: basePrice,
            discount: discount,
            discountType: discountType,
            discountEndDate: discountEndDate,
            thumbnailImage: null,
            totalSales: 0,
            netRevenue: 0,
            activeUsers: 0,
          );
        } else {
          throw Exception(
            'Failed to create program: ${jsonResponse['message']}',
          );
        }
      } else {
        throw Exception('Failed to create program: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error creating program: $e");
      rethrow;
    }
  }

  // Update Program (PUT) - Simplified
  static Future<ProgramData> updateProgram(
    String programId, {
    required String tierId,
    required String title,
    required String description,
    required String serviceType,
    required int durationInWeeks,
    required List<String> features,
    required String status,
    required double basePrice,
    required double discount,
    required String discountType,
    String? discountEndDate,
    File? thumbnailImage,
    String? existingImageUrl, // Add this parameter
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachWorkspace/programs');

      print("🌐 PUT Update Program URL: $url");

      http.Response response;

      if (thumbnailImage != null) {
        // If new image selected, use multipart
        var request = http.MultipartRequest('PUT', url);
        request.headers.addAll(authHeaders);

        request.fields['id'] = programId;
        request.fields['tierId'] = tierId;
        request.fields['title'] = title;
        request.fields['description'] = description;
        request.fields['serviceType'] = serviceType;
        request.fields['durationInWeeks'] = durationInWeeks.toString();
        request.fields['features'] = jsonEncode(features);
        request.fields['status'] = status;
        request.fields['basePrice'] = basePrice.toString();
        request.fields['discount'] = discount.toString();
        request.fields['discountType'] = discountType;
        if (discountEndDate != null && discountEndDate.isNotEmpty) {
          request.fields['discountEndDate'] = discountEndDate;
        }

        var multipartFile = await http.MultipartFile.fromPath(
          'thumbnailImage',
          thumbnailImage.path,
        );
        request.files.add(multipartFile);

        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // If no new image, send the existing image URL
        final requestBody = {
          'id': programId,
          'tierId': tierId,
          'title': title,
          'description': description,
          'serviceType': serviceType,
          'durationInWeeks': durationInWeeks,
          'features': features,
          'status': status,
          'basePrice': basePrice,
          'discount': discount,
          'discountType': discountType,
          if (discountEndDate != null && discountEndDate.isNotEmpty)
            'discountEndDate': discountEndDate,
          // DELETE this line: 'thumbnailImage': existingImageUrl,
        };

        print("📤 RAW REQUEST BODY: ${jsonEncode(requestBody)}");
        print("📤 RAW URL: $url");
        print(
          "📤 RAW HEADERS: ${{...authHeaders, 'Content-Type': 'application/json'}}",
        );

        response = await http.put(
          url,
          headers: {...authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
      }

      print("📥 Update Program API Status: ${response.statusCode}");
      print("📥 Update Program API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isSuccess'] == true) {
          return ProgramData(
            id: programId,
            tierId: tierId,
            title: title,
            description: description,
            serviceType: serviceType,
            durationInWeeks: durationInWeeks,
            features: features,
            status: status,
            basePrice: basePrice,
            discount: discount,
            discountType: discountType,
            discountEndDate: discountEndDate,
            thumbnailImage: existingImageUrl ?? thumbnailImage?.path,
            totalSales: 0,
            netRevenue: 0,
            activeUsers: 0,
          );
        } else {
          throw Exception(
            'Failed to update program: ${jsonResponse['message']}',
          );
        }
      } else {
        throw Exception('Failed to update program: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error updating program: $e");
      rethrow;
    }
  }

  // Delete Program (DELETE)
  static Future<bool> deleteProgram(String programId) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachWorkspace/programs/$programId');

      print("🌐 DELETE Program URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Program API Status: ${response.statusCode}");
      print("📥 Delete Program API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final programResponse = ProgramResponse.fromJson(jsonResponse);

        if (programResponse.isSuccess) {
          return true;
        } else {
          throw Exception(
            'Failed to delete program: ${programResponse.message}',
          );
        }
      } else {
        throw Exception('Failed to delete program: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error deleting program: $e");
      rethrow;
    }
  }

  static Future<List<StorefrontTier>> getProfileStorefront(
    String userId,
  ) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/$userId/storefront');

      final response = await http.get(url, headers: authHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isSuccess'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((e) => StorefrontTier.fromJson(e)).toList();
        } else {
          throw Exception('Failed: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createProgramSubscription({
    required String programId,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/programs/$programId/subscribe');

      final String defaultSuccessUrl =
          successUrl ?? "fitapp://programs/payment-success";
      final String defaultCancelUrl =
          cancelUrl ?? "fitapp://programs/payment-cancel";

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', ...authHeaders},
        body: jsonEncode({
          'successUrl': defaultSuccessUrl,
          'cancelUrl': defaultCancelUrl,
        }),
      );

      print("📥 Program Subscription Status: ${response.statusCode}");
      print("📥 Program Subscription Body: ${response.body}");

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("📦 Parsed Response: $jsonResponse"); // Add this

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print("❌ API SERVICE ERROR: $e");
      rethrow;
    }
  }

  static Future<CoachStatsData> getCoachWorkspaceStats() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachWorkspace/stats');

      print("🌐 GET Coach Workspace Stats URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Coach Stats API Status: ${response.statusCode}");
      print("📥 Coach Stats API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final statsResponse = CoachStatsResponse.fromJson(jsonResponse);

        if (statsResponse.isSuccess) {
          return statsResponse.data;
        } else {
          throw Exception('Failed to load stats: ${statsResponse.message}');
        }
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error loading coach stats: $e");
      rethrow;
    }
  }

  static Future<TraineesData> getTrainees({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchQuery,
    String? filterStatus,
    String? filterPackageTier,
    String? filterProgramId,
    String? filterProgramType,
    String? filterReviewStatus,
    bool? filterExpiringSoon,
    String? sortByDate,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();

      // Build query parameters
      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['searchQuery'] = searchQuery;
      }
      if (filterStatus != null && filterStatus.isNotEmpty) {
        queryParams['filterStatus'] = filterStatus;
      }
      if (filterPackageTier != null && filterPackageTier.isNotEmpty) {
        queryParams['filterPackageTier'] = filterPackageTier;
      }
      if (filterProgramId != null && filterProgramId.isNotEmpty) {
        queryParams['filterProgramId'] = filterProgramId;
      }
      if (filterProgramType != null && filterProgramType.isNotEmpty) {
        queryParams['filterProgramType'] = filterProgramType;
      }
      if (filterReviewStatus != null && filterReviewStatus.isNotEmpty) {
        queryParams['filterReviewStatus'] = filterReviewStatus;
      }
      if (filterExpiringSoon == true) {
        queryParams['filterExpiringSoon'] = 'true';
      }
      if (sortByDate != null && sortByDate.isNotEmpty) {
        queryParams['sortByDate'] = sortByDate;
      }

      final uri = Uri.parse(
        '$baseUrl/CoachWorkspace/trainees',
      ).replace(queryParameters: queryParams);

      print("🌐 GET Trainees URL: $uri");

      final response = await http.get(uri, headers: authHeaders);

      print("📥 Trainees API Status: ${response.statusCode}");
      print("📥 Trainees API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final traineesResponse = TraineesResponse.fromJson(jsonResponse);

        if (traineesResponse.isSuccess) {
          return traineesResponse.data;
        } else {
          throw Exception(
            'Failed to load trainees: ${traineesResponse.message}',
          );
        }
      } else {
        throw Exception('Failed to load trainees: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error loading trainees: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> uploadProgram({
    required String subscriptionId,
    required String programName,
    required String programCategory,
    required DateTime startDate,
    required DateTime endDate,
    required File file,
    required File coverImage,
    String? coachPrivateNote,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/CoachWorkspace/upload-program');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(authHeaders);

      request.fields['SubscriptionId'] = subscriptionId;
      request.fields['ProgramName'] = programName;
      request.fields['ProgramCategory'] = programCategory;
      request.fields['StartDate'] = startDate.toIso8601String();
      request.fields['EndDate'] = endDate.toIso8601String();
      if (coachPrivateNote != null) {
        request.fields['CoachPrivateNote'] = coachPrivateNote;
      }

      // Add the main file
      var fileStream = http.ByteStream(file.openRead());
      var fileLength = await file.length();
      var multipartFile = http.MultipartFile(
        'File',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add the cover image
      var coverStream = http.ByteStream(coverImage.openRead());
      var coverLength = await coverImage.length();
      var coverMultipartFile = http.MultipartFile(
        'CoverImage',
        coverStream,
        coverLength,
        filename: coverImage.path.split('/').last,
      );
      request.files.add(coverMultipartFile);

      print("🌐 POST Upload Program URL: $url");
      print("📤 SubscriptionId: $subscriptionId");
      print("📤 ProgramName: $programName");
      print("📤 ProgramCategory: $programCategory");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("📥 Upload Program API Status: ${response.statusCode}");
      print("📥 Upload Program API Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Program uploaded successfully',
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload program: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error uploading program: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<WalletData> getWallet() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Wallet');

      print("🌐 GET Wallet URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Wallet API Status: ${response.statusCode}");
      print("📥 Wallet API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final walletResponse = WalletResponse.fromJson(jsonResponse);

        if (walletResponse.isSuccess) {
          return walletResponse.data;
        } else {
          throw Exception('Failed to load wallet: ${walletResponse.message}');
        }
      } else {
        throw Exception('Failed to load wallet: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error loading wallet: $e");
      rethrow;
    }
  }

  // Get wallet transactions
  static Future<WalletTransactionsData> getWalletTransactions({
    int pageNumber = 1,
    int pageSize = 10,
    String? type, // Income, Fee, Withdrawal, Refund
    String? sortBy, // newest, oldest, highest, lowest
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();

      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      final uri = Uri.parse(
        '$baseUrl/Wallet/transactions',
      ).replace(queryParameters: queryParams);

      print("🌐 GET Wallet Transactions URL: $uri");

      final response = await http.get(uri, headers: authHeaders);

      print("📥 Wallet Transactions API Status: ${response.statusCode}");
      print("📥 Wallet Transactions API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final transactionsResponse = WalletTransactionsResponse.fromJson(
          jsonResponse,
        );

        if (transactionsResponse.isSuccess) {
          return transactionsResponse.data;
        } else {
          throw Exception(
            'Failed to load transactions: ${transactionsResponse.message}',
          );
        }
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error loading wallet transactions: $e");
      rethrow;
    }
  }

  // Request withdrawal
  static Future<WithdrawalResponse> requestWithdrawal({
    required double withdrawalAmount,
    required String payoutMethod,
    required String payoutMethodDetails,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Wallet/withdraw');

      final request = WithdrawalRequest(
        withdrawalAmount: withdrawalAmount,
        payoutMethod: payoutMethod,
        payoutMethodDetails: payoutMethodDetails,
      );

      print("🌐 POST Withdrawal URL: $url");
      print("📤 Request Body: ${jsonEncode(request.toJson())}");

      final response = await http.post(
        url,
        headers: {...authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print("📥 Withdrawal API Status: ${response.statusCode}");
      print("📥 Withdrawal API Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return WithdrawalResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to request withdrawal: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error requesting withdrawal: $e");
      rethrow;
    }
  }

  static Future<List<SubscribedCoach>> getSubscribedCoaches() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/TraineeWorkspace/subscriptions');

      print("🌐 GET Subscribed Coaches URL: $url");

      final response = await http.get(url, headers: authHeaders);

      print("📥 Subscribed Coaches API Status: ${response.statusCode}");
      print("📥 Subscribed Coaches API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final coachesResponse = SubscribedCoachesResponse.fromJson(
          jsonResponse,
        );

        if (coachesResponse.isSuccess) {
          return coachesResponse.data;
        } else {
          throw Exception(
            'Failed to load subscribed coaches: ${coachesResponse.message}',
          );
        }
      } else {
        throw Exception(
          'Failed to load subscribed coaches: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error loading subscribed coaches: $e");
      rethrow;
    }
  }

  static Future<CoachProgramsData> getCoachPrograms({
    required String coachId,
    String? routeType,
    String? searchQuery,
    String? filterSubscriptionId,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();

      final queryParams = <String, String>{};

      if (routeType != null && routeType.isNotEmpty) {
        queryParams['routeType'] = routeType;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['searchQuery'] = searchQuery;
      }
      if (filterSubscriptionId != null && filterSubscriptionId.isNotEmpty) {
        queryParams['filterSubscriptionId'] = filterSubscriptionId;
      }

      final uri = Uri.parse(
        '$baseUrl/TraineeWorkspace/coaches/$coachId/programs',
      ).replace(queryParameters: queryParams);

      print("🌐 GET Coach Programs URL: $uri");

      final response = await http.get(uri, headers: authHeaders);

      print("📥 Coach Programs API Status: ${response.statusCode}");
      print("📥 Coach Programs API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final programsResponse = CoachProgramsResponse.fromJson(jsonResponse);

        if (programsResponse.isSuccess) {
          return programsResponse.data;
        } else {
          throw Exception(
            'Failed to load coach programs: ${programsResponse.message}',
          );
        }
      } else {
        throw Exception(
          'Failed to load coach programs: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error loading coach programs: $e");
      rethrow;
    }
  }

  static Future<RefundResponse> requestRefund({
    required String subscriptionId,
    required String disputeReason,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/TraineeWorkspace/subscriptions/refund');

      final request = RefundRequest(
        subscriptionId: subscriptionId,
        disputeReason: disputeReason,
      );

      print("🌐 POST Refund Request URL: $url");
      print("📤 Request Body: ${jsonEncode(request.toJson())}");

      final response = await http.post(
        url,
        headers: {...authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print("📥 Refund API Status: ${response.statusCode}");
      print("📥 Refund API Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return RefundResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to request refund: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error requesting refund: $e");
      rethrow;
    }
  }

  static Future<ReviewResponse> submitReview({
    required String subscriptionId,
    required int rating,
    required String comment,
  }) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/TraineeWorkspace/reviews/submit');

      final request = ReviewRequest(
        subscriptionId: subscriptionId,
        rating: rating,
        comment: comment,
      );

      print("🌐 POST Submit Review URL: $url");
      print("📤 Request Body: ${jsonEncode(request.toJson())}");

      final response = await http.post(
        url,
        headers: {...authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print("📥 Submit Review API Status: ${response.statusCode}");
      print("📥 Submit Review API Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ReviewResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error submitting review: $e");
      rethrow;
    }
  }

  static Future<ChatbotResponse> askChatbot(String query) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Chatbot/ask');

      final requestBody = {'message': query};

      print("🌐 POST Chatbot URL: $url");
      print("📤 Request Body: $requestBody");

      final response = await http.post(
        url,
        headers: {...authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("📥 Chatbot API Status: ${response.statusCode}");
      print("📥 Chatbot API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isSuccess'] == true) {
          return ChatbotResponse.fromJson(jsonResponse);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to get response');
        }
      } else {
        throw Exception(
          'Failed to get chatbot response: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error getting chatbot response: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final authHeaders = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/Profile/delete-account');

      print("🌐 DELETE Account URL: $url");

      final response = await http.delete(url, headers: authHeaders);

      print("📥 Delete Account API Status: ${response.statusCode}");
      print("📥 Delete Account API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Clear local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Account deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete account: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error deleting account: $e");
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
