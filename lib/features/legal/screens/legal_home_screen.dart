import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidar_property/features/legal/screens/legal_mou_review_screen.dart';
import 'package:tidar_property/features/legal/screens/legal_profile_screen.dart';
import 'package:tidar_property/models/user_model.dart';
import '../../../core/providers/user_provider.dart';
import '../../../widgets/role_bottom_nav.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';

class LegalHomeScreen extends StatefulWidget {
  const LegalHomeScreen({super.key});

  @override
  State<LegalHomeScreen> createState() => _LegalHomeScreenState();
}

class _LegalHomeScreenState extends State<LegalHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const LegalDashboardContent(), // Beranda
    const LegalMouReviewScreen(documentId: ''),
    const Center(
      child: Text(
        "✅ Tugas\n\nComing Soon",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    ),
    const Center(
      child: Text(
        "⚙️ Sistem\n\nComing Soon",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      ),
    ),
    const LegalProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // ← Ini yang penting agar bottom nav bisa berpindah
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: RoleBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        role: UserRole.legal,
      ),
    );
  }
}

// ================== DASHBOARD CONTENT ==================
class LegalDashboardContent extends StatelessWidget {
  const LegalDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Dashboard Legal",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Monitoring dan peninjauan MoU real estat.",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          // Statistik
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildRealtimeStatCard(
                  context,
                  "MENUNGGU",
                  "Draf",
                  Colors.blue,
                ),
                const SizedBox(width: 7),
                _buildRealtimeStatCard(
                  context,
                  "PERLU REVISI",
                  "Revisi",
                  Colors.orange,
                ),
              ],
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

          StreamBuilder<List<MouDocument>>(
            stream: Provider.of<MouService>(context, listen: false).getRecentMousStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Belum ada aktivitas terbaru",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final activities = snapshot.data!;

              return Column(
                children: activities.map((mou) {
                  final docId = mou.idMou;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LegalMouReviewScreen(documentId: docId),
                        ),
                      );
                    },
                    child: _buildActivityItem(
                      mou.title.isNotEmpty ? mou.title : mou.fileName,
                      mou.jenisMou,
                      mou.statusMou,
                      Colors.blue,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Pembaruan Pedoman Hukum
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage("https://picsum.photos/id/1015/800/400"),
                  fit: BoxFit.cover,
                  opacity: 0.85,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pembaruan Pedoman Hukum",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pembaruan ketentuan baru mengenai properti dan legalitas kontrak.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Unduh PDF"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
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
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMouItem(
    String title,
    String company,
    String date,
    String status,
  ) {
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
            const Icon(
              Icons.description_outlined,
              size: 40,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    company,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status.contains("Revisi")
                    ? Colors.orange[100]
                    : Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status.contains("Revisi")
                      ? Colors.orange
                      : Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
  Widget _buildRealtimeStatCard(BuildContext context, String title, String statusKeyword, Color color) {
    final Stream<int> countStream = Provider.of<MouService>(context, listen: false).getMousStream().map((list) {
      return list.where((mou) => mou.statusMou.toLowerCase() == statusKeyword.toLowerCase()).length;
    });

    return Expanded(
      child: StreamBuilder<int>(
        stream: countStream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;

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
}
