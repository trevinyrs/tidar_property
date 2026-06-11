import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tidar_property/features/br/screens/br_mou_screen.dart';
import 'package:tidar_property/models/user_model.dart';
import '../../../core/providers/user_provider.dart';
import '../../../widgets/role_bottom_nav.dart';
import 'br_stock_screen.dart';
import 'br_profile_screen.dart';

class BrHomeScreen extends StatefulWidget {
  const BrHomeScreen({super.key});

  @override
  State<BrHomeScreen> createState() => _BrHomeScreenState();
}

class _BrHomeScreenState extends State<BrHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BrDashboardContent(),
    const BrMouScreen(),
    const BrStockScreen(),
    const Center(
      child: Text(
        "📊 Reports\n\nComing Soon",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    ),
    const BrProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: RoleBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        role: UserRole.br,
      ),
    );
  }
}

// ================== DASHBOARD CONTENT ==================
class BrDashboardContent extends StatelessWidget {
  const BrDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (tetap sama)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                    const SizedBox(width: 10),

                    Image.asset("assets/images/logo_tidar.png", height: 38),
                  ],
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF263238),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selamat pagi, ${user?.name ?? 'Alexander'}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Dashboard Performa",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),

          // Total Penjualan & Statistik (tetap sama)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL PENJUALAN",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  "Rp 4.28B",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 18,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "+12.5% dari bulan lalu",
                      style: TextStyle(color: Colors.green.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildRealtimeStatCard(
                  "TOTAL AGENT",
                  "users",
                  "agent",
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildRealtimeStatCard(
                  "TOTAL PROPERTI",
                  "properties",
                  null,
                  Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Grafik (tetap sama)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Grafik Penjualan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "6 Bulan Terakhir",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSalesChart(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ================== AKTIVITAS TERBARU REALTIME ==================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Aktivitas Terbaru",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Lihat Semua", style: TextStyle(color: Color(0xFF1E88E5))),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // StreamBuilder untuk Aktivitas Realtime dari MOU
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mou_documents')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Belum ada aktivitas terbaru",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final activities = snapshot.data!.docs;

              return Column(
                children: activities.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildActivityItem(
                    data['title'] ?? "Dokumen Baru",
                    data['uploadedBy'] ?? "BR User",
                    "Review",
                    Colors.blue,
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ================== METHOD LAIN TETAP SAMA ==================
  Widget _buildSalesChart() {
    final months = ["JAN", "FEB", "MAR", "APR", "MEI", "JUN"];
    final values = [45, 52, 38, 65, 78, 105];

    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: (values[index] * 1.2).toDouble(),
                decoration: BoxDecoration(
                  color: index == 5
                      ? const Color(0xFF1E88E5)
                      : Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                months[index],
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRealtimeStatCard(
    String title,
    String collection,
    String? roleFilter,
    Color color,
  ) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: roleFilter != null
            ? FirebaseFirestore.instance
                  .collection(collection)
                  .where('role', isEqualTo: roleFilter)
                  .snapshots()
            : FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          final count = snapshot.data?.docs.length ?? 0;
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
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 32,
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

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String status,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.description_outlined, color: color, size: 24),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
