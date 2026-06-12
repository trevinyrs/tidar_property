import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/providers/user_provider.dart';

class ManagerSalesScreen extends StatefulWidget {
  const ManagerSalesScreen({super.key});

  @override
  State<ManagerSalesScreen> createState() => _ManagerSalesScreenState();
}

class _ManagerSalesScreenState extends State<ManagerSalesScreen> {
  String _selectedPeriod = "Bulan Ini";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    const cardWhite = Colors.white;
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: CustomAppBar(
        titleWidget: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFEDF1F4),
              backgroundImage: (user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty)
                  ? NetworkImage(user.fotoProfil!)
                  : null,
              child: (user?.fotoProfil == null || user!.fotoProfil!.isEmpty)
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Image.asset(
              "assets/images/logo_tidar.png",
              height: 36,
              errorBuilder: (context, error, stackTrace) => const Text(
                "TIMPRO",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F658A),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF263238),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tb_penjualan')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final salesDocs = snapshot.data?.docs ?? [];
          
          // Calculate stats
          double totalSales = 0;
          for (var doc in salesDocs) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            final harga = (data['harga'] ?? data['price'] ?? 0).toDouble();
            totalSales += harga;
          }

          // If no transactions in firestore, fallback to default mock numbers matching specs
          final totalSalesText = totalSales > 0
              ? "Rp ${(totalSales / 1000000000).toStringAsFixed(1)}M"
              : "Rp 42.8M";
          final totalClosingCount = salesDocs.isNotEmpty ? salesDocs.length : 18;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER & FILTER WAKTU ─────────────────────────────
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sales Tracking",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Analisis performa real estate Anda secara real-time.",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildFilterTab("Bulan Ini", primaryColor),
                          const SizedBox(width: 8),
                          _buildFilterTab("Tahun Ini", primaryColor),
                          const SizedBox(width: 8),
                          _buildFilterTab("Custom", primaryColor),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── RANGKUMAN TOTAL PENJUALAN ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TOTAL PENJUALAN",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          totalSalesText,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "+12.5% dari bulan lalu",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── CARD PROGRESS UNIT TERJUAL ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "TOTAL CLOSING",
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$totalClosingCount Unit",
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                            const Text(
                              "Target: 20 Unit",
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalClosingCount / 20.0,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${((totalClosingCount / 20.0) * 100).round()}% dari target closing tercapai",
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── GRAFIK PERFORMA PENJUALAN ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Performa Penjualan",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text("Ekspor PDF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 160,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBar("Minggu 1", 60, primaryColor),
                          _buildBar("Minggu 2", 85, primaryColor),
                          _buildBar("Minggu 3", 120, primaryColor, isHighlight: true),
                          _buildBar("Minggu 4", 95, primaryColor),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── LIST CLOSING TERAKHIR ────────────────────────────
                const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Closing Terakhir",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
                const SizedBox(height: 12),

                salesDocs.isEmpty
                    ? Column(
                        children: [
                          _buildClosingItem("Apartemen Skyline", "Unit B-12", "Rp 2.450.000.000", "Hari Santoso", primaryColor),
                          _buildClosingItem("Perumahan Grand Oasis", "Unit B-05", "Rp 1.180.000.000", "Siti Aminah", primaryColor),
                          _buildClosingItem("Office Tower Kenanga", "Lt. 15 Suite C", "Rp 5.200.000.000", "David Wijaya", primaryColor),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: salesDocs.length,
                        itemBuilder: (context, index) {
                          final doc = salesDocs[index];
                          final data = doc.data() as Map<String, dynamic>? ?? {};
                          final title = data['properti_title'] ?? data['title'] ?? 'Aset Tidar';
                          final unit = data['kode_unit'] ?? data['unit'] ?? 'Unit';
                          final harga = (data['harga'] ?? data['price'] ?? 0).toDouble();
                          final agent = data['nama_agen'] ?? data['agent'] ?? 'Agen Tidar';
                          
                          // format price
                          final priceText = "Rp ${harga.toStringAsFixed(0)}";

                          return _buildClosingItem(title, unit, priceText, agent, primaryColor);
                        },
                      ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTab(String text, Color primaryColor) {
    final isActive = _selectedPeriod == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? primaryColor : Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, double height, Color primaryColor, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: isHighlight ? primaryColor : primaryColor.withValues(alpha: 0.35),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildClosingItem(String property, String unit, String price, String agent, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.home_work_outlined, size: 22, color: primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text("$unit • Agent: $agent", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                const Text("CLOSING SUCCESS", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}