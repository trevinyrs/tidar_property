import 'package:flutter/material.dart';

class ManagerSalesScreen extends StatelessWidget {
  const ManagerSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
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
                "Analisis performa real estate Anda secara real-time.",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab("Bulan Ini", true),
                  const SizedBox(width: 8),
                  _buildTab("Tahun Ini", false),
                  const SizedBox(width: 8),
                  _buildTab("Custom", false),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Total Penjualan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TOTAL PENJUALAN", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const Text(
                      "Rp 42.8M",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "+12.5% bulan lalu",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Total Closing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TOTAL CLOSING", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const Text(
                          "18",
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Text("Unit Terjual", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Target: 20 Unit", style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("90%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Performa Penjualan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Performa Penjualan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text("Ekspor PDF"),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBar("Minggu 1", 60),
                          _buildBar("Minggu 2", 85),
                          _buildBar("Minggu 3", 120, isHighlight: true),
                          _buildBar("Minggu 4", 95),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Closing Terakhir
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Closing Terakhir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            _buildClosingItem("Apartemen Skyline", "Unit B-12", "Rp 2.450.000.000", "Hari Santoso"),
            _buildClosingItem("Perumahan Grand Oasis", "Unit B-05", "Rp 1.180.000.000", "Siti Aminah"),
            _buildClosingItem("Office Tower Kenanga", "Lt. 15 Suite C", "Rp 5.200.000.000", "David Wijaya"),

            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text("Lihat Semua Transaksi", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isActive ? Border.all(color: const Color(0xFF1E88E5)) : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF1E88E5) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, double height, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: height,
          decoration: BoxDecoration(
            color: isHighlight ? const Color(0xFF1E88E5) : Colors.blue[200],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildClosingItem(String property, String unit, String price, String buyer) {
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
            const Icon(Icons.home_work_outlined, size: 40, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(unit, style: const TextStyle(color: Colors.grey)),
                  Text(buyer, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("Closing", style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}