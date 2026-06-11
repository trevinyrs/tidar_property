import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import 'br_mou_bank_screen.dart';
import 'br_mou_agent_screen.dart';

class BrMouScreen extends StatelessWidget {
  const BrMouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manajemen MoU",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F658A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pilih tipe manajemen dokumen untuk melanjutkan proses administrasi kerjasama.",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Card MoU Bank (dengan background icon watermark di kanan)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildMouCard(
                context: context,
                icon: Icons.account_balance_outlined,
                watermarkIcon: Icons.account_balance,
                title: "MoU Bank",
                subtitle: "Kelola kerjasama dan dokumen dengan institusi perbankan.",
                buttonText: "Pilih Institusi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrMouBankScreen()),
                  );
                },
              ),
            ),

            // Card MoU Agent (dengan background icon watermark di kanan)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildMouCard(
                context: context,
                icon: Icons.contact_page_outlined,
                watermarkIcon: Icons.account_box,
                title: "MoU Agent",
                subtitle: "Kelola kemitraan dan komisi dengan agen properti eksternal.",
                buttonText: "Lihat Kemitraan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrMouAgentScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Blue Info Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F658A),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F658A).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        "Semua dokumen MoU yang dikelola akan tersinkronisasi dengan sistem legal dan keuangan secara otomatis.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildMouCard({
    required BuildContext context,
    required IconData icon,
    required IconData watermarkIcon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Watermark Icon
          Positioned(
            right: -10,
            top: 10,
            child: Icon(
              watermarkIcon,
              size: 130,
              color: const Color(0xFFEDF1F4).withOpacity(0.4),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF96D3FD).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1F658A),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 60), // Hindari menimpa watermark
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buttonText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F658A),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF1F658A),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
