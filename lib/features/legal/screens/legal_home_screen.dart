import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tidar_property/features/legal/screens/legal_profile_screen.dart';
import 'package:tidar_property/features/legal/screens/mou_legal_review_detail_screen.dart';
import 'package:tidar_property/features/legal/screens/legal_mou_list_screen.dart';
import 'package:tidar_property/models/user_model.dart';
import '../../../core/providers/user_provider.dart';
import '../../../widgets/role_bottom_nav.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';

// ======================= WARNA SISTEM =======================
const _primary = Color(0xFF1F658A);
const _bgColor = Color(0xFFF5F6F8);
const _cardWhite = Colors.white;
// ============================================================

class LegalHomeScreen extends StatefulWidget {
  const LegalHomeScreen({super.key});

  @override
  State<LegalHomeScreen> createState() => _LegalHomeScreenState();
}

class _LegalHomeScreenState extends State<LegalHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      LegalDashboardContent(
        onNavigateToMou: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ), // Beranda
      const LegalMouListScreen(),
      const LegalProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: IndexedStack(index: _currentIndex, children: _pages),
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
  final VoidCallback onNavigateToMou;

  const LegalDashboardContent({super.key, required this.onNavigateToMou});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: CustomAppBar(
        titleWidget: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFEDF1F4),
              backgroundImage:
                  (user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty)
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── GREETING SECTION ────────────────────────────────────
            Container(
              color: _cardWhite,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final firstName = (user?.name ?? '').split(' ').first;
                      final greeting = firstName.isNotEmpty
                          ? firstName
                          : 'Legal';
                      return Text(
                        'Selamat datang, $greeting 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2B36),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monitoring & peninjauan MoU real estat.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF7B8D9A)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── STATISTIK CARD ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildRealtimeStatCard(
                    context,
                    'MENUNGGU',
                    'Draf',
                    _primary,
                    Icons.schedule_outlined,
                  ),
                  const SizedBox(width: 10),
                  _buildRealtimeStatCard(
                    context,
                    'REVISI',
                    'Revisi',
                    const Color(0xFFE67E22),
                    Icons.edit_note_outlined,
                  ),
                  const SizedBox(width: 10),
                  _buildRealtimeStatCard(
                    context,
                    'SELESAI',
                    'Aktif',
                    const Color(0xFF2ECC71),
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── AKTIVITAS TERBARU ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2B36),
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToMou,
                    style: TextButton.styleFrom(
                      foregroundColor: _primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            StreamBuilder<List<MouDocument>>(
              stream: Provider.of<MouService>(
                context,
                listen: false,
              ).getRecentMousStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada aktivitas terbaru',
                          style: TextStyle(color: Color(0xFF9E9E9E)),
                        ),
                      ),
                    ),
                  );
                }

                final activities = snapshot.data!;

                return Column(
                  children: activities.map((mou) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MouLegalReviewDetailScreen(mou: mou),
                          ),
                        );
                      },
                      child: _buildActivityItem(
                        mou.title.isNotEmpty ? mou.title : mou.fileName,
                        mou.jenisMou,
                        mou.statusMou,
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── BANNER PEDOMAN HUKUM ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F658A), Color(0xFF2A8BBF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PEMBARUAN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Pedoman Hukum\nProperti 2025',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ketentuan baru mengenai legalitas\nkontrak & properti.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: const Text('Unduh PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: Colors.white,
                        size: 36,
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

  Widget _buildActivityItem(String title, String subtitle, String status) {
    // Tentukan warna badge berdasarkan status
    final Color badgeColor;
    final Color badgeBg;
    final IconData badgeIcon;

    switch (status.toLowerCase()) {
      case 'revisi':
        badgeColor = const Color(0xFFE67E22);
        badgeBg = const Color(0xFFFFF3E0);
        badgeIcon = Icons.edit_note_outlined;
        break;
      case 'disetujui':
        badgeColor = const Color(0xFF2ECC71);
        badgeBg = const Color(0xFFE8F8F0);
        badgeIcon = Icons.check_circle_outline;
        break;
      default:
        badgeColor = _primary;
        badgeBg = const Color(0xFFE3F2FF);
        badgeIcon = Icons.schedule_outlined;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
            child: Icon(
              Icons.description_outlined,
              color: badgeColor,
              size: 22,
            ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C2B36),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7B8D9A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, size: 12, color: badgeColor),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeStatCard(
    BuildContext context,
    String title,
    String statusKeyword,
    Color color,
    IconData icon,
  ) {
    final Stream<int> countStream =
        Provider.of<MouService>(context, listen: false).getMousStream().map(
          (list) => list
              .where(
                (mou) =>
                    mou.statusMou.toLowerCase() == statusKeyword.toLowerCase(),
              )
              .length,
        );

    return Expanded(
      child: StreamBuilder<int>(
        stream: countStream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF7B8D9A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
