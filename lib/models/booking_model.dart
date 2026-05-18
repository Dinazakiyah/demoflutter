class BookingModel {
  final String? id;
  final String? carId;
  final String? userId;
  final String? carName;
  final String? carBrand;
  final double? carPricePerDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? totalDays;
  final double? totalAmount;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final Map<String, dynamic>? car;
  final Map<String, dynamic>? user;

  BookingModel({
    this.id,
    this.carId,
    this.userId,
    this.carName,
    this.carBrand,
    this.carPricePerDay,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.totalAmount,
    this.status = 'pending',
    this.notes,
    this.createdAt,
    this.car,
    this.user,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['_id'] ?? json['id'];

    String? normalizeId(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      return v.toString();
    }

    String? carIdValue;
    final carJson = json['car'];
    if (carJson is String) {
      carIdValue = carJson;
    } else if (carJson is Map) {
      carIdValue = normalizeId(carJson['_id'] ?? carJson['id']);
    }

    String? userIdValue;
    final userJson = json['user'];
    if (userJson is String) {
      userIdValue = userJson;
    } else if (userJson is Map) {
      userIdValue = normalizeId(userJson['_id'] ?? userJson['id']);
    }

    return BookingModel(
      id: normalizeId(idValue),
      carId: carIdValue,
      userId: userIdValue,
      carName: carJson is Map ? (carJson as Map<String, dynamic>)['name'] : null,
      carBrand:
          carJson is Map ? (carJson as Map<String, dynamic>)['brand'] : null,
      carPricePerDay: carJson is Map
          ? ((carJson as Map<String, dynamic>)['pricePerDay'] as num?)?.toDouble()
          : null,
      startDate:
          json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      totalDays: json['totalDays'] as int?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      car: carJson is Map ? carJson as Map<String, dynamic> : null,
      user: userJson is Map ? userJson as Map<String, dynamic> : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'car': carId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'confirmed': return 'Dikonfirmasi';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  // ignore: unused_element
  String get _statusColor {
    switch (status) {
      case 'pending': return 'orange';
      case 'confirmed': return 'blue';
      case 'completed': return 'green';
      case 'cancelled': return 'red';
      default: return 'grey';
    }
  }
}