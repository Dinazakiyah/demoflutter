class PaymentModel {
  final String? id;
  final String? bookingId;
  final String? userId;
  final double? amount;
  final String? method;
  final String status;
  final String? proofImage;
  final String? notes;
  final String? adminNotes;
  final DateTime? createdAt;
  final Map<String, dynamic>? booking;

  PaymentModel({
    this.id,
    this.bookingId,
    this.userId,
    this.amount,
    this.method,
    this.status = 'pending',
    this.proofImage,
    this.notes,
    this.adminNotes,
    this.createdAt,
    this.booking,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] as String?,
      bookingId: json['booking'] is String
          ? json['booking'] as String?
          : (json['booking'] as Map<String, dynamic>?)?['_id'],
      userId: json['user'] is String
          ? json['user'] as String?
          : (json['user'] as Map<String, dynamic>?)?['_id'],
      amount: (json['amount'] as num?)?.toDouble(),
      method: json['method'] as String?,
      status: json['status'] as String? ?? 'pending',
      proofImage: json['proofImage'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      booking: json['booking'] is Map ? json['booking'] as Map<String, dynamic> : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking': bookingId,
      'amount': amount,
      'method': method,
      if (proofImage != null) 'proofImage': proofImage,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Menunggu Verifikasi';
      case 'verified': return 'Terverifikasi';
      case 'rejected': return 'Ditolak';
      case 'refunded': return 'Direfund';
      default: return status;
    }
  }
}