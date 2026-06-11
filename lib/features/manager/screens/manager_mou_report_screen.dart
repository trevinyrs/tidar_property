import 'package:flutter/material.dart';

class ManagerMouReportScreen extends StatelessWidget {
  const ManagerMouReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Laporan MoU"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Ringkasan kemitraan strategis per kuartal ini.",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),

            // Statistik Utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.account_balance,
                      title: "BANK AKTIF",
                      value: "24",
                      subtitle: "MoU Bank telah divalidasi",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      title: "AGENT AKTIF",
                      value: "158",
                      subtitle: "Agen properti mandiri",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Distribusi Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Distribusi Status",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusItem("AKTIF", "182", Colors.green),
                        _buildStatusItem("PROSES", "42", Colors.orange),
                        _buildStatusItem("REVISI", "12", Colors.red),
                        _buildStatusItem("EXPIRED", "0", Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Total 236 Dokumen",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // MoU Terbaru
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "MoU Terbaru",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Lihat Semua"),
                  ),
                ],
              ),
            ),

            _buildMouItem(
              title: "Bank Mandiri (Pusat)",
              subtitle: "Kerjasama Pembiayaan Properti",
              status: "Aktif",
              statusColor: Colors.green,
            ),
            _buildMouItem(
              title: "Ray White Indonesia",
              subtitle: "Exclusive Partnership Agreement",
              status: "Proses",
              statusColor: Colors.orange,
            ),
            _buildMouItem(
              title: "Agen Independen - Budi Santoso",
              subtitle: "Kontrak Komisi Tahunan",
              status: "Revisi",
              statusColor: Colors.red,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: const Color(0xFF1E88E5)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildMouItem({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF1E88E5),
              child: Icon(Icons.description, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}