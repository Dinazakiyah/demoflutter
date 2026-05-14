import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/booking_model.dart';
import 'auth_service.dart';

class BookingService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<BookingModel>> getBookings() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/bookings');
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> list = body['data']['bookings'] ?? [];
      return list.map((e) => BookingModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data booking');
    }
  }

  static Future<BookingModel> getBookingById(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id');
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Booking tidak ditemukan');
    }
  }

  static Future<BookingModel> createBooking({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/bookings');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'car': carId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 201) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat booking');
    }
  }

  static Future<void> cancelBooking(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id/cancel');
    final headers = await _authHeaders();
    final response = await http.put(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal membatalkan booking');
    }
  }

  // Admin only
  static Future<void> confirmBooking(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id/confirm');
    final headers = await _authHeaders();
    final response = await http.put(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal mengkonfirmasi booking');
    }
  }

  static Future<void> completeBooking(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/bookings/$id/complete');
    final headers = await _authHeaders();
    final response = await http.put(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal menyelesaikan booking');
    }
  }
}