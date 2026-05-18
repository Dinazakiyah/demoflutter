import 'package:flutter/material.dart';
import 'package:demoflutter/models/payment_model.dart';
import 'package:demoflutter/services/auth_service.dart';
import 'package:demoflutter/services/payment_service.dart';


class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  List<PaymentModel> payments = [];
  bool isLoading = true;
  String role = 'user';


  @override
  void initState() {
    super.initState();
    _loadRoleAndPayments();
  }

  Future<void> _loadRoleAndPayments() async {
    final r = await AuthService.getRole();
    if (!mounted) return;
    setState(() => role = r ?? 'user');
    await loadPayments();
  }



  Future<void> loadPayments() async {
    try {
      final data = await PaymentService.getPayments();

      setState(() {
        payments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> verifyPayment(String id) async {
    try {
      await PaymentService.verifyPayment(id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil diverifikasi'),
        ),
      );

      loadPayments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }


  Color statusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Pembayaran'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment ID: ${payment.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text('Amount : Rp ${payment.amount}'),
                        Text('Method : ${payment.method}'),
                        Text('Status : ${payment.status}'),

                        const SizedBox(height: 10),

                        Chip(
                          label: Text(payment.status),
                          backgroundColor:
                              statusColor(payment.status),
                        ),

                        const SizedBox(height: 10),

                        if (role == 'admin' && payment.status == 'pending')
                          ElevatedButton(
                            onPressed: () => verifyPayment(payment.id!),
                            child: const Text('Verifikasi'),
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