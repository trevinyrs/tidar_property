import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManagerSalesDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ManagerSalesDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['properti_title'] ?? data['title'] ?? 'Aset Tidar';
    final unit = data['kode_unit'] ?? data['unit'] ?? 'Unit';
    final agent = data['nama_agen'] ?? data['agent'] ?? 'Agen Tidar';
    final harga = (data['harga'] ?? data['price'] ?? 0).toDouble();
    final priceText = "Rp ${harga.toStringAsFixed(0)}";
    
    DateTime? date;
    if (data['created_at'] != null) {
      if (data['created_at'] is Timestamp) {
        date = (data['created_at'] as Timestamp).toDate();
      } else if (data['created_at'] is String) {
        date = DateTime.tryParse(data['created_at']);
      }
    }
    date ??= DateTime.now();

    final dateString = DateFormat('dd MMM yyyy, HH:mm').format(date);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          "Detail Penjualan",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Success Icon Section
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  ),
                  const SizedBox(height: 20),
                  const Text("Transaksi Closing Berhasil", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(priceText, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(dateString, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Detail Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rincian Properti", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 20),
                  _buildDetailRow("Nama Properti", title),
                  const Divider(height: 32, color: Color(0xFFEDF1F4)),
                  _buildDetailRow("Kode Unit", unit),
                  const Divider(height: 32, color: Color(0xFFEDF1F4)),
                  _buildDetailRow("Nama Agen Penjual", agent),
                  const Divider(height: 32, color: Color(0xFFEDF1F4)),
                  _buildDetailRow("Status Pembayaran", "Lunas (Deal)", isHighlight: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: isHighlight ? Colors.green : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
