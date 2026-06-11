import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'br_mou_bank_upload_screen.dart';

class BrMouBankScreen extends StatelessWidget {
  const BrMouBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("MoU Bank"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Mengelola semua MOU bank",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),

            // Tambah MoU Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BrMouBankUploadScreen(bankName: '',)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("+ Tambah MoU", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Realtime
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildRealtimeStatCard("MOU AKTIF", "ACTIVE", Colors.blue),
                  const SizedBox(width: 12),
                  _buildRealtimeStatCard("DALAM PROSES", "PROCESS", Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatCard("MOU EXP", "0", Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by bank name...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("All", true),
                    const SizedBox(width: 8),
                    _buildFilterChip("Active", false),
                    const SizedBox(width: 8),
                    _buildFilterChip("In Process", false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bank List dengan onTap
            _buildBankItem(
              logoUrl: "assets/images/mandiri.png",
              bankName: "Bank Mandiri",
              description: "Strategic partnership for premium mortgage financing and liquidity management.",
              status: "ACTIVE",
              statusColor: Colors.green,
              onTap: () => _goToUploadScreen(context, "Bank Mandiri"),
            ),

            _buildBankItem(
              logoUrl: "assets/images/bca.png",
              bankName: "Bank BCA",
              description: "Awaiting final verification of digital lending protocols and risk assessment.",
              status: "ACTIVE",
              statusColor: Colors.green,
              onTap: () => _goToUploadScreen(context, "Bank BCA"),
            ),

            _buildBankItem(
              logoUrl: "assets/images/bri.png",
              bankName: "Bank BRI",
              description: "Agreement terminated due to annual cycle expiration. Requires renewal audit.",
              status: "ACTIVE",
              statusColor: Colors.green,
              onTap: () => _goToUploadScreen(context, "Bank BRI"),
            ),

            _buildBankItem(
              logoUrl: "assets/images/bni.png",
              bankName: "Bank BNI",
              description: "Commercial real estate development financing partner for metropolitan projects.",
              status: "ACTIVE",
              statusColor: Colors.green,
              onTap: () => _goToUploadScreen(context, "Bank BNI"),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _goToUploadScreen(BuildContext context, String bankName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrMouBankUploadScreen(bankName: bankName),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E88E5) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

 Widget _buildBankItem({
    required String logoUrl,
    required String bankName,
    required String description,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        logoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bankName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                const SizedBox(height: 12),
                Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildRealtimeStatCard(String title, String status, Color color) {
  return Expanded(
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mou_documents')
          .where('type', isEqualTo: 'Bank')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                count.toString(),
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