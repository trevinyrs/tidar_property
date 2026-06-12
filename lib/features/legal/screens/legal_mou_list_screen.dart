import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';
import 'mou_legal_review_detail_screen.dart';
import '../../../core/providers/user_provider.dart';

class LegalMouListScreen extends StatefulWidget {
  const LegalMouListScreen({super.key});

  @override
  State<LegalMouListScreen> createState() => _LegalMouListScreenState();
}

class _LegalMouListScreenState extends State<LegalMouListScreen> {
  String _selectedFilter = "Semua";
  final List<String> _filters = ["Semua", "Draf", "Revisi", "Menunggu TTD", "Aktif"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: CustomAppBar(
        titleWidget: Row(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TITLE & SUBTITLE ──────────────────────────────────────
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Daftar Dokumen MoU",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2B36),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Kelola, tinjau, dan setujui draf kemitraan bank atau agen.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF7B8D9A)),
                ),
              ],
            ),
          ),

          // ── FILTER CHIPS ──────────────────────────────────────────
          Container(
            height: 52,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    backgroundColor: const Color(0xFFF1F5F9),
                    checkmarkColor: Colors.white,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ── MOU LIST STREAM ───────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<MouDocument>>(
              stream: Provider.of<MouService>(context, listen: false).getMousStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada dokumen MoU",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                var documents = snapshot.data!;
                if (_selectedFilter != "Semua") {
                  documents = documents
                      .where((doc) => doc.statusMou.toLowerCase() == _selectedFilter.toLowerCase())
                      .toList();
                }

                if (documents.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada dokumen dengan status '$_selectedFilter'",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final mou = documents[index];
                    final title = mou.title.isNotEmpty ? mou.title : mou.fileName;
                    final category = mou.jenisMou;

                    // Badge color matching status
                    final Color badgeColor;
                    final Color badgeBg;
                    final IconData badgeIcon;

                    switch (mou.statusMou.toLowerCase()) {
                      case 'revisi':
                        badgeColor = const Color(0xFFE67E22);
                        badgeBg = const Color(0xFFFFF3E0);
                        badgeIcon = Icons.edit_note_outlined;
                        break;
                      case 'disetujui':
                      case 'aktif':
                        badgeColor = const Color(0xFF2ECC71);
                        badgeBg = const Color(0xFFE8F8F0);
                        badgeIcon = Icons.check_circle_outline;
                        break;
                      default:
                        badgeColor = primaryColor;
                        badgeBg = const Color(0xFFE3F2FF);
                        badgeIcon = Icons.schedule_outlined;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.toLowerCase() == 'agent' ? Icons.person_outline : Icons.account_balance,
                            color: primaryColor,
                          ),
                        ),
                        title: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Kategori: ${category.toUpperCase()}",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                    mou.statusMou,
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MouLegalReviewDetailScreen(mou: mou),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
