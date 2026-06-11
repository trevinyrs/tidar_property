import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidar_property/features/manager/screens/manager_mou_report_screen.dart';
import 'package:tidar_property/features/manager/screens/manager_sales_screen.dart';
import 'package:tidar_property/models/user_model.dart';
import '../../../core/providers/user_provider.dart';
import '../../../widgets/role_bottom_nav.dart';
import 'manager_profile_screen.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ManagerDashboardContent(),           // Beranda
    const ManagerSalesScreen(),
    const ManagerMouReportScreen(),
    const Center(child: Text("🏠 Properties Overview\n\nComing Soon", textAlign: TextAlign.center, style: TextStyle(fontSize: 20))),
    const ManagerProfileScreen(),              // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: RoleBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        role: UserRole.manager,
      ),
    );
  }
}

// ================== DASHBOARD CONTENT ==================
class ManagerDashboardContent extends StatelessWidget {
  const ManagerDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF1E88E5),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Selamat Datang,", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          user?.name ?? "Manager",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.notifications_outlined, size: 28),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Berikut adalah ringkasan kinerja properti Anda hari ini.",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),

          // Statistik Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildStatCard(
                  title: "TOTAL PENJUALAN",
                  value: "Rp 12,4M",
                  change: "+8.2% bulan ini",
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallStatCard("TOTAL MOU AKTIF", "42", "12 Menunggu Tanda Tangan"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallStatCard("TOTAL PROPERTI", "156", "85% Terhuni"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pertumbuhan Bulanan
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
                  const Text("Pertumbuhan Bulanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text("Data performa penjualan 6 bulan terakhir", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "📈 Grafik Pertumbuhan\n(Penjualan vs MOU)",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTab("Penjualan", true),
                      const SizedBox(width: 16),
                      _buildTab("MOU", false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Aktivitas Terkini
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Aktivitas Terkini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          _buildActivityItem("MOU Baru: Tidar Regency B-12", "Rp 1.2M", "2 jam lalu"),
          _buildActivityItem("Pembayaran Berhasil: Unit B-05", "Rp 150jt", "5 jam lalu"),

          const SizedBox(height: 24),

          // Properti Unggulan
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Properti Unggulan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage("https://picsum.photos/id/1015/800/400"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("The Tidar Grand Residence", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Mulai dari Rp 2.45 Miliar", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String change, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text(change, style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        color: isActive ? const Color(0xFF1E88E5) : Colors.grey,
      ),
    );
  }

  Widget _buildActivityItem(String title, String amount, String time) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: const CircleAvatar(child: Icon(Icons.notifications)),
      title: Text(title),
      subtitle: Text(time, style: const TextStyle(color: Colors.grey)),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}