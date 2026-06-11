import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'br_mou_bank_upload_screen.dart';
import 'br_mou_bank_detail_screen.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';

class BrMouBankScreen extends StatefulWidget {
  const BrMouBankScreen({super.key});

  @override
  State<BrMouBankScreen> createState() => _BrMouBankScreenState();
}

class _BrMouBankScreenState extends State<BrMouBankScreen> {
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(
        titleText: "MoU Bank",
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Text(
                "Mengelola semua MOU bank",
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),

            // Tambah MoU Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BrMouBankUploadScreen(bankName: "Bank Mandiri")),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label: const Text(
                    "Tambah MoU",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F658A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Realtime (MOU AKTIF, DALAM PROSES, MOU EXP)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildRealtimeStatCard(context, "MOU AKTIF", "Aktif", const Color(0xFF1F658A)),
                  const SizedBox(width: 12),
                  _buildRealtimeStatCard(context, "DALAM PROSES", "Draf", Colors.orange),
                  const SizedBox(width: 12),
                  _buildRealtimeStatCard(context, "MOU EXP", "Kadaluarsa", Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search by bank name...",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildFilterChip("All"),
                        const SizedBox(width: 8),
                        _buildFilterChip("Active"),
                        const SizedBox(width: 8),
                        _buildFilterChip("In Process"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bank List
            _buildBankItem(
              context: context,
              logoWidget: Container(
                width: 50,
                height: 50,
                color: const Color(0xFF0F4C81),
                child: const Center(child: Text("Bank", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
              ),
              bankName: "Global Standard Bank",
              description: "Strategic partnership for premium mortgage financing and liquidity management.",
              status: "ACTIVE",
              statusColor: Colors.green,
              validText: "VALID UNTIL\nOct 12, 2026",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BrMouBankDetailScreen(bankName: "Global Standard Bank")),
                );
              },
            ),

            _buildBankItem(
              context: context,
              logoWidget: Container(
                width: 50,
                height: 50,
                color: const Color(0xFF1B2C3F),
                child: const Center(child: Text("Finance", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
              ),
              bankName: "Lumina Finance",
              description: "Awaiting final verification of digital lending protocols and risk assessment.",
              status: "PROCESS",
              statusColor: const Color(0xFF96D3FD),
              validText: "UPDATED\nYesterday, 14:20",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BrMouBankDetailScreen(bankName: "Lumina Finance")),
                );
              },
            ),

            _buildBankItem(
              context: context,
              logoWidget: Container(
                width: 50,
                height: 50,
                color: const Color(0xFF34495E),
                child: const Center(child: Text("BRI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
              ),
              bankName: "Bank Mandiri (Persero)",
              description: "Commercial real estate development financing partner for metropolitan projects.",
              status: "EXPIRED",
              statusColor: Colors.grey,
              validText: "EXPIRED\nOct 12, 2025",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BrMouBankDetailScreen(bankName: "Bank Mandiri (Persero)")),
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1F658A) : const Color(0xFFEDF1F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBankItem({
    required BuildContext context,
    required Widget logoWidget,
    required String bankName,
    required String description,
    required String status,
    required Color statusColor,
    required String validText,
    required VoidCallback onTap,
  }) {
    if (_searchQuery.isNotEmpty && !bankName.toLowerCase().contains(_searchQuery)) {
      return const SizedBox.shrink();
    }
    if (_selectedFilter == "Active" && status != "ACTIVE") return const SizedBox.shrink();
    if (_selectedFilter == "In Process" && status != "PROCESS") return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: logoWidget,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor == Colors.grey ? Colors.grey.shade700 : statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  bankName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEDF1F4)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          validText.split('\n').first,
                          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          validText.split('\n').last,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDF1F4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeStatCard(BuildContext context, String title, String statusName, Color color) {
    return Expanded(
      child: StreamBuilder<List<MouDocument>>(
        stream: Provider.of<MouService>(context, listen: false)
            .getMousByTypeAndStatusStream('Bank', statusName),
        builder: (context, snapshot) {
          final count = snapshot.data?.length ?? 0;
          String countText = count < 10 ? "0$count" : "$count";
          if (title == "MOU AKTIF" && count == 0) countText = "12"; // Fallback static data mock
          if (title == "DALAM PROSES" && count == 0) countText = "04";
          if (title == "MOU EXP" && count == 0) countText = "02";

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  countText,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}