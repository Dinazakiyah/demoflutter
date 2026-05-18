import 'package:flutter/material.dart';
import 'package:demoflutter/models/booking_model.dart';
import 'package:demoflutter/services/payment_service.dart';

class PaymentFormScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentFormScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  bool isLoading = false;
  // Match enum backend swagger:
  // transfer_bank, kartu_kredit, kartu_debit, e_wallet, tunai
  String paymentMethod = 'transfer_bank';


  Future<void> submitPayment() async {
    setState(() {
      isLoading = true;
    });

    try {
      await PaymentService.createPayment(
        bookingId: widget.booking.id!,
        amount: widget.booking.totalAmount ?? 0,
        method: paymentMethod,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil dikirim'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField(
              initialValue: paymentMethod,
              items: const [
                DropdownMenuItem(
                  value: 'transfer_bank',
                  child: Text('Transfer Bank'),
                ),
                DropdownMenuItem(
                  value: 'tunai',
                  child: Text('Tunai'),
                ),
                // Opsional bila backend mendukung
                DropdownMenuItem(
                  value: 'kartu_kredit',
                  child: Text('Kartu Kredit'),
                ),
                DropdownMenuItem(
                  value: 'kartu_debit',
                  child: Text('Kartu Debit'),
                ),
                DropdownMenuItem(
                  value: 'e_wallet',
                  child: Text('E-Wallet'),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : submitPayment,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Bayar Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}