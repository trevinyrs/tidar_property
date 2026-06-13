import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../core/providers/user_provider.dart';

class MouLegalReviewDetailScreen extends StatefulWidget {
  final MouDocument mou;

  const MouLegalReviewDetailScreen({super.key, required this.mou});

  @override
  State<MouLegalReviewDetailScreen> createState() => _MouLegalReviewDetailScreenState();
}

class _MouLegalReviewDetailScreenState extends State<MouLegalReviewDetailScreen> {
  final _revisionController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _revisionController.dispose();
    super.dispose();
  }

  // Aksi A: Berikan Revisi
  void _showRevisionDialog(BuildContext context, String currentUserId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Masukkan Catatan Revisi"),
          content: TextField(
            controller: _revisionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Contoh: Mohon perhatikan pasal 4 ayat 2 mengenai terminasi dini...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final catatan = _revisionController.text.trim();
                if (catatan.isEmpty) return;

                Navigator.pop(dialogContext); // Close dialog

                setState(() => _isProcessing = true);

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final mouService = Provider.of<MouService>(context, listen: false);

                bool success = await mouService.submitRevision(
                  idMou: widget.mou.idMou,
                  idUser: currentUserId,
                  catatan: catatan,
                );

                if (!mounted) return;
                setState(() => _isProcessing = false);

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Catatan revisi berhasil dikirim!"), backgroundColor: Colors.green),
                  );
                  navigator.pop(); // Go back
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Gagal mengirim revisi. Coba lagi."), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }

  // Aksi B: Setujui & Teruskan
  void _approveDocument(BuildContext context, String currentUserId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final mouService = Provider.of<MouService>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Setujui Dokumen?"),
        content: const Text("Apakah Anda yakin ingin menyetujui dokumen MoU ini dan meneruskannya ke tahap penandatanganan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Setujui"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    bool success = await mouService.approveAndForward(
      idMou: widget.mou.idMou,
      idUser: currentUserId,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("MoU berhasil disetujui & diteruskan!"), backgroundColor: Colors.green),
      );
      navigator.pop();
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Gagal menyetujui dokumen. Coba lagi."), backgroundColor: Colors.red),
      );
    }
  }

  // Buka Pratinjau PDF / Download manual
  void _downloadAndReviewDocument(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    var urlString = widget.mou.fileMou;
    if (!urlString.startsWith('http')) {
      urlString = 'https://$urlString';
    }
    
    final Uri url = Uri.parse(urlString);
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Gagal membuka link dokumen"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    const cardWhite = Colors.white;

    final user = Provider.of<UserProvider>(context).currentUser;
    final currentUserId = user?.uid ?? "unknown_legal";

    final type = widget.mou.jenisMou.toLowerCase();
    final title = widget.mou.title.isNotEmpty ? widget.mou.title : widget.mou.fileName;
    final entityName = type == 'agent' ? (widget.mou.idAgent ?? '-') : (widget.mou.idBank ?? '-');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "TINJAUAN MoU",
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER SECTION ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DOKUMEN  >  TINJAUAN MOU",
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: Color(0xFF7B8085),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: secondaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "TINJAUAN DRAF",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "● PRIORITAS TINGGI",
                              style: TextStyle(
                                color: Color(0xFFC62828),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── TWO ACTION BUTTONS ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => _showRevisionDialog(context, currentUserId),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primaryColor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Berikan\nRevisi",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _approveDocument(context, currentUserId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Setujui &\nTeruskan",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── CARD DETAIL MITRA ───────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Detail Mitra",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: secondaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                type == 'agent' ? Icons.person_outline : Icons.account_balance,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "NAMA ENTITAS",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    entityName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                "PERWAKILAN",
                                type == 'agent' ? entityName : "Adrian Prasetya",
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                "KATEGORI",
                                type == 'agent' ? "Agen Properti" : "Lembaga Keuangan",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── CARD KLAUSUL UTAMA & CATATAN ────────────────────
                  // ── CARD CATATAN PENGASAHAN / PENGIRIMAN ────────────
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Catatan Pengajuan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.mou.catatan != null && widget.mou.catatan!.isNotEmpty
                              ? widget.mou.catatan!
                              : "Tidak ada catatan dari BR.",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),



                  // ── PDF PREVIEW CONTAINER (SPLIT-VIEW) ──────────────
                  // ── DOCK DOWNLOAD & TINJAU DOKUMEN ──────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadAndReviewDocument(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.download_for_offline_outlined),
                      label: const Text(
                        "Unduh & Tinjau Dokumen",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }


}
