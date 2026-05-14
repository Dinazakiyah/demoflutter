import 'package:flutter/material.dart';
import 'package:demoflutter/models/car_model.dart';
import 'package:demoflutter/services/booking_service.dart';
import 'package:demoflutter/widgets/loading_indicator.dart';
import '../auth/booking_list_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final CarModel car;
  const BookingFormScreen({super.key, required this.car});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalAmount => _totalDays * widget.car.pricePerDay;

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (now.add(const Duration(days: 1)))
          : (_startDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 2))),
      firstDate: isStart ? now : (_startDate ?? now),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A1A2E)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_totalDays <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal selesai harus setelah tanggal mulai'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await BookingService.createBooking(
        carId: widget.car.id!,
        startDate: _startDate!,
        endDate: _endDate!,
        notes: _notesController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking berhasil dibuat!'), backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BookingListScreen()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatPrice(double price) {
    String s = price.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      count++;
      result = s[i] + result;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return result;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator(message: 'Membuat pesanan...'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pesanan'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.white, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.car.name,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${widget.car.brand} • ${widget.car.type.toUpperCase()}',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Rp ${_formatPrice(widget.car.pricePerDay)}/hari',
                              style: const TextStyle(color: Colors.amber, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text('Tanggal Sewa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: _DatePickerTile(
                      label: 'Mulai',
                      date: _startDate,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerTile(
                      label: 'Selesai',
                      date: _endDate,
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),

              // Summary
              if (_totalDays > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_totalDays hari × Rp ${_formatPrice(widget.car.pricePerDay)}',
                              style: TextStyle(color: Colors.blue.shade700, fontSize: 13)),
                          const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Text('Rp ${_formatPrice(_totalAmount)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Text('Catatan (opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan untuk driver / admin...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('Konfirmasi Pesanan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerTile({required this.label, this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: date != null ? const Color(0xFF1A1A2E) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16,
                    color: date != null ? const Color(0xFF1A1A2E) : Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  date != null
                      ? '${date!.day}/${date!.month}/${date!.year}'
                      : 'Pilih tanggal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: date != null ? const Color(0xFF1A1A2E) : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}