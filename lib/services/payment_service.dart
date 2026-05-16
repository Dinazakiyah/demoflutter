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

  final token = await AuthService.getToken();

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  final body = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final payments = body['data']['payments'];

    return List<PaymentModel>.from(
      payments.map(
        (x) => PaymentModel.fromJson(x),
      ),
    );
  } else {
    throw Exception(body['message']);
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
  static Future<void> verifyPayment(String id) async {
    // Backend: PUT /api/payments/:id/verify (authorize('admin'))
    final url = Uri.parse('${ApiConfig.baseUrl}/api/payments/$id/verify');
    final token = await AuthService.getToken();

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': 'success'}),
    );

    // Beberapa backend bisa balas 200 tanpa body.
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (body is Map && body['message'] != null) {
      throw Exception(body['message']);
    }
    throw Exception(
      'Gagal memverifikasi pembayaran (statusCode: ${response.statusCode}).',
    );
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