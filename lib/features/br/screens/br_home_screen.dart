import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidar_property/features/br/screens/br_mou_screen.dart';
import 'package:tidar_property/models/user_model.dart';
import '../../../core/providers/user_provider.dart';
import '../../../widgets/role_bottom_nav.dart';
import 'br_stock_screen.dart';
import 'br_profile_screen.dart';
import 'add_property_screen.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/property_service.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';

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
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Avatar di kiri, Logo di tengah, Notif di kanan)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                    Image.asset("assets/images/logo_tidar.png", height: 36),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: Color(0xFF263238),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selamat pagi, ${user?.name ?? 'Alexander'}",
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Dashboard Performa",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F658A),
                  ),
                ),
              ],
            ),
          ),

          // 1. TOTAL PENJUALAN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TOTAL PENJUALAN",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Rp 4.28B",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1F658A)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.trending_up, size: 16, color: Colors.teal),
                          const SizedBox(width: 4),
                          Text(
                            "+12.5% dari bulan lalu",
                            style: TextStyle(color: Colors.teal.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF96D3FD).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFF1F658A),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. TOTAL AGENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF96D3FD).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      color: Color(0xFF1F658A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "TOTAL AGENT",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  _buildAgentCountStream(context),
                ],
              ),
            ),
          ),

          // 3. TOTAL PROPERTI (Card Biru/Primary)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildPropertyCard(context),
          ),

          // 4. GRAFIK PERTUMBUHAN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Grafik",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            "Pertumbuhan",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF1F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              "6 Bulan Terakhir",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Monthly Performance Sales\n(2024)",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  _buildSalesChart(),
                ],
              ),
            ),
          ),

          // 5. AKTIVITAS TERBARU
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Aktivitas Terbaru",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Lihat Semua",
                    style: TextStyle(color: Color(0xFF1F658A), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // StreamBuilder untuk Aktivitas Realtime dari MOU
          StreamBuilder<List<MouDocument>>(
            stream: Provider.of<MouService>(context, listen: false).getRecentMousStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    "Belum ada aktivitas terbaru",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final activities = snapshot.data!;

              return Column(
                children: activities.map((mou) {
                  return _buildActivityItem(
                    mou.title.isNotEmpty ? mou.title : (mou.fileName.isNotEmpty ? mou.fileName : "Dokumen Baru"),
                    mou.jenisMou,
                    mou.statusMou,
                    const Color(0xFF1F658A),
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

  // Widget untuk mengambil jumlah agent secara realtime
  Widget _buildAgentCountStream(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder<List<AppUser>>(
      stream: authService.getUsersStream(roleFilter: 'Agent'),
      builder: (context, snapshot) {
        final agents = snapshot.data ?? [];
        final count = agents.length;

        return Text(
          count > 0 ? "$count" : "124",
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        );
      },
    );
  }

  // Widget untuk mengambil jumlah properti secara realtime dan merender Card Biru Primary
  Widget _buildPropertyCard(BuildContext context) {
    final propertyService = Provider.of<PropertyService>(context, listen: false);
    return StreamBuilder<List<dynamic>>(
      stream: propertyService.getProperties(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 856;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1F658A),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F658A).withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL PROPERTI",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "$count",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text(
                "Listing Aktif",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${count > 10 ? (count * 0.037).floor() : 32} Baru Minggu Ini",
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white70, size: 16),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Grafik Pertumbuhan dengan bar bulat
  Widget _buildSalesChart() {
    final months = ["JAN", "FEB", "MAR", "APR", "MEI", "JUN"];
    final values = [40, 55, 45, 75, 110, 60];

    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (index) {
          final isMax = index == 4; // Mei
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isMax)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F658A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "128M",
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: (values[index] * 1.1).toDouble(),
                decoration: BoxDecoration(
                  color: isMax
                      ? const Color(0xFF1F658A)
                      : const Color(0xFFEDF1F4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                months[index],
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Aktivitas Terbaru minimalis
  Widget _buildActivityItem(
    String title,
    String subtitle,
    String status,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF96D3FD).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined, color: Color(0xFF1F658A), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MoU Baru: $title",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Penandatanganan oleh Agent $subtitle",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "2 jam lalu",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: status.toUpperCase() == 'AKTIF' ? Colors.teal : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
