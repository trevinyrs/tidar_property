import 'package:flutter/material.dart';
import '../../../models/mou_model.dart';
import 'br_mou_agent_upload_screen.dart';

class MouTrackingDetailScreen extends StatelessWidget {
  final MouDocument mou;
  final String agentName;
  final String company;

  const MouTrackingDetailScreen({
    super.key,
    required this.mou,
    required this.agentName,
    required this.company,
  });

  // Custom date formatter to avoid dependency on 'intl' package
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    const bgColor = Color(0xFFF5F6F8);
    const cardWhite = Colors.white;

    final status = mou.statusMou;
    
    bool isStep1Done = false;
    bool isStep2Done = false;
    bool isStep3Done = false;
    bool isStep4Done = false;
    bool isStep5Done = false;

    bool isStep1Active = false;
    bool isStep2Active = false;
    bool isStep3Active = false;
    bool isStep4Active = false;
    bool isStep5Active = false;

    if (status == 'Draf') {
      isStep1Active = true;
    } else if (status == 'Menunggu TTD') {
      isStep1Done = true;
      isStep2Active = true;
    } else if (status == 'Revisi') {
      isStep1Done = true;
      isStep2Done = true;
      isStep3Active = true;
    } else if (status == 'Aktif') {
      isStep1Done = true;
      isStep2Done = true;
      isStep3Done = true;
      isStep4Done = true;
      isStep5Done = true;
    } else {
      isStep1Done = true;
      isStep2Active = true;
    }

    final formattedDate = _formatDate(mou.tanggalUpload);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardWhite,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "Pelacakan MoU",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              mou.idMou.startsWith('mock') ? "#MOU-2026-08912" : "#${mou.idMou.toUpperCase().substring(0, mou.idMou.length.clamp(0, 10))}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── CONDITIONAL BANNER ──────────────────────────────────
            if (status == 'Revisi') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Tindakan Diperlukan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Anda perlu meninjau revisi dari departemen legal sebelum melanjutkan ke tahap approval.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BrMouAgentUploadScreen(
                                agentName: agentName,
                                company: company,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tinjau Revisi Sekarang",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, color: primaryColor, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── VERTICAL STATUS STEP TRACKER ────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "STATUS PELACAKAN",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildVerticalStep(
                    context: context,
                    title: "Draft",
                    description: "MoU dibuat & diunggah oleh BR",
                    date: isStep1Done ? formattedDate : null,
                    isDone: isStep1Done,
                    isActive: isStep1Active,
                    isLast: false,
                  ),
                  _buildVerticalStep(
                    context: context,
                    title: "Review Legal",
                    description: "Peninjauan draf oleh departemen hukum",
                    date: isStep2Done ? formattedDate : null,
                    isDone: isStep2Done,
                    isActive: isStep2Active,
                    isLast: false,
                  ),
                  _buildVerticalStep(
                    context: context,
                    title: "Revisi",
                    description: "Perbaikan klausul atau berkas",
                    date: isStep3Done ? formattedDate : null,
                    isDone: isStep3Done,
                    isActive: isStep3Active,
                    isLast: false,
                  ),
                  _buildVerticalStep(
                    context: context,
                    title: "Approval",
                    description: "Persetujuan akhir oleh manajemen",
                    date: isStep4Done ? formattedDate : null,
                    isDone: isStep4Done,
                    isActive: isStep4Active,
                    isLast: false,
                  ),
                  _buildVerticalStep(
                    context: context,
                    title: "Aktif",
                    description: "MoU resmi berlaku dalam sistem",
                    date: isStep5Done ? formattedDate : null,
                    isDone: isStep5Done,
                    isActive: isStep5Active,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── GRID DURASI & PRIORITAS ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(18),
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
                        Text(
                          "DURASI PROSES",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "4 Hari",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C2B36),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(18),
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
                        Text(
                          "PRIORITAS",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Tinggi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── LAMPIRAN DOKUMEN ────────────────────────────────────
            Text(
              "LAMPIRAN DOKUMEN",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryColor.withValues(alpha: 0.6),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
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
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mou.fileName.isNotEmpty ? mou.fileName : "MoU_Kemitraan_Agent.pdf",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C2B36),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          mou.fileSize.isNotEmpty ? mou.fileSize : "2.4 MB",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.download_for_offline, color: primaryColor, size: 28),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── LOG AKTIVITAS ───────────────────────────────────────
            const Text(
              "LOG AKTIVITAS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildLogItem(
                    context: context,
                    title: "Revisi diajukan oleh Legal",
                    description: mou.catatanRevisi ?? "Mohon perhatikan pasal 4 ayat 2 mengenai terminasi dini.",
                    time: "Hari ini, 14:20",
                    isFirst: true,
                    isLast: false,
                  ),
                  _buildLogItem(
                    context: context,
                    title: "Review Dokumen",
                    description: "Dokumen dalam peninjauan Legal",
                    time: "Kemarin, 09:15",
                    isFirst: false,
                    isLast: false,
                  ),
                  _buildLogItem(
                    context: context,
                    title: "Draf Diunggah",
                    description: "MoU berhasil diunggah oleh BR",
                    time: "10 Jun 2026, 11:00",
                    isFirst: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── CARD AGEN PENGELOLA ─────────────────────────────────
            const Text(
              "AGEN PENGELOLA",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          agentName.isNotEmpty ? agentName[0] : "A",
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agentName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C2B36),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Senior Property Agent",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: List.generate(5, (index) {
                                return const Icon(Icons.star, color: Colors.amber, size: 14);
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.message_rounded, size: 16),
                            label: const Text("Hubungi Agen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.phone_rounded, size: 16),
                            label: const Text("Telepon Langsung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: secondaryColor,
                              side: BorderSide(color: secondaryColor.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalStep({
    required BuildContext context,
    required String title,
    required String description,
    required String? date,
    required bool isDone,
    required bool isActive,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    Color markerColor = Colors.grey.shade300;
    Widget markerChild = const SizedBox.shrink();

    if (isDone) {
      markerColor = primaryColor;
      markerChild = const Icon(Icons.check, color: Colors.white, size: 14);
    } else if (isActive) {
      markerColor = secondaryColor;
      markerChild = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: markerChild),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? primaryColor : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? secondaryColor
                        : (isDone ? const Color(0xFF1C2B36) : Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 10,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem({
    required BuildContext context,
    required String title,
    required String description,
    required String time,
    required bool isFirst,
    required bool isLast,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: BoxDecoration(
                  color: isFirst ? primaryColor : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isFirst ? const Color(0xFF1C2B36) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: isFirst ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
