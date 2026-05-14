import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/payment_model.dart';
import 'auth_service.dart';

class PaymentService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<PaymentModel>> getPayments() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/payments');
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> list = body['data']['payments'] ?? [];
      return list.map((e) => PaymentModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data pembayaran');
    }
  }

  static Future<PaymentModel> getPaymentById(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/payments/$id');
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return PaymentModel.fromJson(body['data']['payment']);
    } else {
      throw Exception(body['message'] ?? 'Pembayaran tidak ditemukan');
    }
  }

  static Future<PaymentModel> createPayment({
    required String bookingId,
    required double amount,
    required String method,
    String? proofImage,
    String? notes,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/payments');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'booking': bookingId,
        'amount': amount,
        'method': method,
        if (proofImage != null && proofImage.isNotEmpty) 'proofImage': proofImage,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 201) {
      return PaymentModel.fromJson(body['data']['payment']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat pembayaran');
    }
  }

  // Admin only
  static Future<void> verifyPayment(String id, {String? adminNotes}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/payments/$id/verify');
    final headers = await _authHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode({
        if (adminNotes != null && adminNotes.isNotEmpty) 'adminNotes': adminNotes,
      }),
    );
    final body = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal memverifikasi pembayaran');
    }
  }

  static Future<void> refundPayment(String id, {String? adminNotes}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/payments/$id/refund');
    final headers = await _authHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: json.encode({
        if (adminNotes != null && adminNotes.isNotEmpty) 'adminNotes': adminNotes,
      }),
    );
    final body = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal merefund pembayaran');
    }
  }
}