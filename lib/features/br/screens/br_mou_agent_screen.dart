import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tidar_property/features/br/screens/br_mou_agent_add_screen.dart';
import 'package:tidar_property/features/br/screens/br_mou_agent_detail_screen.dart';
import 'package:tidar_property/features/br/screens/br_mou_agent_upload_screen.dart';

class BrMouAgentScreen extends StatelessWidget {
  const BrMouAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("MoU Agent"),
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
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Kelola kemitraan strategis dengan agen properti profesional dalam ekosistem Anda.",
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
              ),
            ),

            // Tambah Agent Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BrMouAgentAddScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "+ Tambah Agent",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Realtime
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildRealtimeStatCard("TOTAL AGENT", null, Colors.blue),
                  const SizedBox(width: 12),
                  _buildRealtimeStatCard("AKTIF", "AKTIF", Colors.green),
                  const SizedBox(width: 12),
                  _buildRealtimeStatCard(
                    "KADALUARSA",
                    "KADALUARSA",
                    Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by agent name...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    _buildFilterChip("Expired", false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mou_agents') // ← Koleksi baru
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                // Debug
                print("📡 StreamBuilder called");
                print("Has data: ${snapshot.hasData}");
                print("Error: ${snapshot.error}");
                print("Docs count: ${snapshot.data?.docs.length ?? 0}");

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        "Belum ada data agen",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final agents = snapshot.data!.docs;

                return Column(
                  children: agents.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    print("✅ Agent ditemukan: ${data['name']}"); // Debug

                    return _buildAgentItem(
                      context: context,
                      documentId: doc.id,
                      name: data['name']?.toString() ?? 'Nama Agent',
                      company: data['company']?.toString() ?? '-',
                      status: data['status']?.toString() ?? 'AKTIF',
                      statusColor: _getStatusColor(
                        data['status']?.toString() ?? 'AKTIF',
                      ),
                      lastActive:
                          data['lastActive']?.toString() ??
                          'Aktif baru-baru ini',
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ================== REALTIME STAT CARD ==================
  Widget _buildRealtimeStatCard(
    String title,
    String? statusFilter,
    Color color,
  ) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'agent');

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AKTIF':
        return Colors.green;
      case 'PROSES':
        return Colors.blue;
      case 'KADALUARSA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

     // ================== CARD AGENT DENGAN NAVIGASI (SUDAH BENAR) ==================
  Widget _buildAgentItem({
    required String documentId,
    required String name,
    required String company,
    required String status,
    required Color statusColor,
    required String lastActive,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BrMouAgentUploadScreen(
        agentName: name,
        company: company,
      ),
    ),
  );
},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            leading: _buildStatusIcon(status, statusColor),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status, Color statusColor) {
    Color bgColor;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'AKTIF':
        bgColor = Colors.blue[50]!;
        icon = Icons.person;
        break;
      case 'PROSES':
        bgColor = Colors.orange[50]!;
        icon = Icons.hourglass_empty;
        break;
      case 'KADALUARSA':
        bgColor = Colors.red[50]!;
        icon = Icons.timer_off;
        break;
      default:
        bgColor = Colors.grey[200]!;
        icon = Icons.person;
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: bgColor,
      child: Icon(icon, color: statusColor, size: 28),
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
}
