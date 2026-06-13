import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/mou_service.dart';
import '../../../models/mou_model.dart';
import '../../../widgets/custom_app_bar.dart';
import 'br_mou_bank_upload_screen.dart';

class BrMouBankDetailScreen extends StatelessWidget {
  final MouDocument mou;

  const BrMouBankDetailScreen({super.key, required this.mou});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MouDocument>>(
      initialData: [mou],
      stream: Provider.of<MouService>(context, listen: false).getMousStream(),
      builder: (context, snapshot) {
        final mous = snapshot.data ?? [];
        final currentMou = mous.firstWhere((m) => m.idMou == mou.idMou, orElse: () => mou);
        final status = currentMou.statusMou;
        final bankName = currentMou.idBank ?? "Bank Tanpa Nama";

        // Logic for Dynamic Status
        TimelineStatus drafStatus = TimelineStatus.pending;
        TimelineStatus tinjauanStatus = TimelineStatus.pending;
        TimelineStatus revisiStatus = TimelineStatus.pending;
        TimelineStatus persetujuanStatus = TimelineStatus.pending;
        TimelineStatus aktifStatus = TimelineStatus.pending;

        if (status == 'Draf') {
          drafStatus = TimelineStatus.completed;
          tinjauanStatus = TimelineStatus.active;
        } else if (status == 'Menunggu TTD') {
          drafStatus = TimelineStatus.completed;
          tinjauanStatus = TimelineStatus.completed;
          persetujuanStatus = TimelineStatus.active;
        } else if (status == 'Revisi') {
          drafStatus = TimelineStatus.completed;
          tinjauanStatus = TimelineStatus.completed;
          revisiStatus = TimelineStatus.active;
        } else if (status == 'Aktif') {
          drafStatus = TimelineStatus.completed;
          tinjauanStatus = TimelineStatus.completed;
          revisiStatus = TimelineStatus.completed;
          persetujuanStatus = TimelineStatus.completed;
          aktifStatus = TimelineStatus.completed;
        } else {
          drafStatus = TimelineStatus.completed;
          tinjauanStatus = TimelineStatus.active;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: const CustomAppBar(
            titleText: "",
            backgroundColor: Colors.transparent,
          ),
          extendBodyBehindAppBar: true,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight + 40),
                // Header Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentMou.idMou.startsWith('mock') ? "ID KASUS: #TDR-77421" : "ID KASUS: #${currentMou.idMou.toUpperCase().substring(0, currentMou.idMou.length.clamp(0, 10))}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Kemitraan Bank\n$bankName",
                        style: const TextStyle(
                          fontSize: 32,
                          height: 1.1,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1F658A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Status Saat Ini: $status",
                            style: const TextStyle(
                              color: Color(0xFF1F658A),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── CONDITIONAL BANNER ──────────────────────────────────
                if (status == 'Revisi' || status == 'Menunggu TTD')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: status == 'Revisi' ? const Color(0xFF1F658A) : Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (status == 'Revisi' ? const Color(0xFF1F658A) : Colors.orange).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(status == 'Revisi' ? Icons.warning_amber_rounded : Icons.edit_document, color: Colors.white, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                status == 'Revisi' ? "Tindakan Diperlukan" : "Menunggu TTD Basah",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            status == 'Revisi'
                                ? "Anda perlu meninjau revisi dari departemen legal."
                                : "MoU telah disetujui. Silakan unggah dokumen dengan Tanda Tangan Basah.",
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
                                    builder: (_) => BrMouBankUploadScreen(
                                      bankName: bankName,
                                      existingMou: currentMou,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: status == 'Revisi' ? const Color(0xFF1F658A) : Colors.orange.shade700,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    status == 'Revisi' ? "Tinjau Revisi Sekarang" : "Unggah TTD Basah",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(status == 'Revisi' ? Icons.arrow_forward_rounded : Icons.upload_file, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

            // Timeline Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Siklus Hidup Perjanjian",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTimelineStep(
                    title: "Draf",
                    date: "12 Okt 2023",
                    description: "Lingkup perjanjian awal dan ketentuan ditetapkan oleh pimpinan proyek.",
                    status: drafStatus,
                    icon: Icons.check,
                  ),
                  _buildTimelineStep(
                    title: "Menunggu Tinjauan Tim Legal",
                    description: "Tim legal sedang melakukan peninjauan draf",
                    status: tinjauanStatus,
                    icon: Icons.gavel,
                  ),
                  _buildTimelineStep(
                    title: "Revisi",
                    description: "Implementasi umpan balik hukum dan penawaran balik mitra.",
                    status: revisiStatus,
                    icon: Icons.history,
                  ),
                  _buildTimelineStep(
                    title: "Persetujuan",
                    description: "Persetujuan akhir dari Dewan Eksekutif dan Direktur Bank.",
                    status: persetujuanStatus,
                    icon: Icons.assignment_turned_in_outlined,
                  ),
                  _buildTimelineStep(
                    title: "Aktif",
                    description: "Perjanjian berlaku di semua cabang regional.",
                    status: aktifStatus,
                    icon: Icons.rocket_launch_outlined,
                    isLast: true,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  },
);
  }

  Widget _buildTimelineStep({
    required String title,
    required String description,
    required TimelineStatus status,
    required IconData icon,
    String? date,
    String? badgeText,
    Widget? subtitleWidget,
    bool isLast = false,
  }) {
    Color iconBgColor;
    Color iconColor;
    Color titleColor;
    bool showLine = !isLast;

    switch (status) {
      case TimelineStatus.completed:
        iconBgColor = const Color(0xFF1F658A);
        iconColor = Colors.white;
        titleColor = const Color(0xFF1E293B);
        break;
      case TimelineStatus.active:
        iconBgColor = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF1F658A);
        titleColor = const Color(0xFF1F658A);
        break;
      case TimelineStatus.pending:
      default:
        iconBgColor = const Color(0xFFF1F5F9);
        iconColor = Colors.grey.shade400;
        titleColor = Colors.grey.shade500;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator & line
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  border: status == TimelineStatus.active
                      ? Border.all(color: const Color(0xFF1F658A).withOpacity(0.5), width: 2)
                      : null,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: status == TimelineStatus.completed
                        ? const Color(0xFF1F658A)
                        : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: titleColor,
                          ),
                        ),
                      ),
                      if (date != null)
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      if (badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF96D3FD).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Color(0xFF1F658A),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: status == TimelineStatus.pending ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  if (subtitleWidget != null) subtitleWidget,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

enum TimelineStatus {
  completed,
  active,
  pending,
}
