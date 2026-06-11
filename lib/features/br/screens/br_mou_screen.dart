import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import 'br_mou_bank_screen.dart';
import 'br_mou_agent_screen.dart'; // ← Import ini

class BrMouScreen extends StatelessWidget {
  const BrMouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header seperti Dashboard
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
                        backgroundImage: AssetImage(
                          "assets/images/profile.png",
                        ),
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
                "Management MoU",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C75),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Pilih tipe manajemen dokumen untuk\nmelanjutkan proses administrasi kerjasama.",
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // MoU Bank Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildMouCard(
                icon: Icons.account_balance_outlined,
                title: "MoU Bank",
                subtitle:
                    "Kelola kerjasama dan dokumen dengan institusi perbankan.",
                buttonText: "Pilih Institusi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrMouBankScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // MoU Agent Card → Langsung ke BrMouAgentScreen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildMouCard(
                icon: Icons.person_outline,
                title: "MoU Agent",
                subtitle:
                    "Kelola kemitraan dan komisi dengan agen properti eksternal.",
                buttonText: "Lihat Kemitraan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrMouAgentScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Blue Info Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Semua dokumen MoU yang dikelola akan tersinkronisasi dengan sistem Legal dan Manager secara otomatis.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMouCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
              child: Icon(icon, color: const Color(0xFF1E88E5), size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Color(0xFF1E88E5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
