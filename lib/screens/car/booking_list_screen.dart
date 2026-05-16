import 'package:flutter/material.dart';
import 'package:demoflutter/models/booking_model.dart';
import 'package:demoflutter/services/booking_service.dart';
import 'package:demoflutter/services/auth_service.dart';
import '../auth/payment_form_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<BookingModel> bookings = [];
  bool isLoading = true;
  String role = 'user';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    role = await AuthService.getRole() ?? 'user';

    final data = await BookingService.getBookings();

    setState(() {
      bookings = data;
      isLoading = false;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Booking'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.carName ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Status : ${booking.status}'),
                        Text('Total : Rp ${booking.totalAmount ?? 0}'),
                        const SizedBox(height: 10),
                        Chip(
                          label: Text(booking.status),
                          backgroundColor: statusColor(booking.status),
                        ),
                        const SizedBox(height: 10),

                        if (role == 'user')
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentFormScreen(
                                    booking: booking,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Bayar'),
                          ),

                        if (role == 'admin')
                          ElevatedButton(
                            onPressed: () async {
                              await BookingService.confirmBooking(
                                booking.id!,
                              );
                              loadData();
                            },
                            child: const Text('Konfirmasi Booking'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}