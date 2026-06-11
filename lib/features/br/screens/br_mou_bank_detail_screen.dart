import 'package:flutter/material.dart';
import '../../../widgets/custom_app_bar.dart';

class BrMouBankDetailScreen extends StatelessWidget {
  final String bankName;

  const BrMouBankDetailScreen({super.key, required this.bankName});

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    "ID KASUS: #TDR-77421",
                    style: TextStyle(
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
                      const Text(
                        "Saat ini dalam Tinjauan Hukum",
                        style: TextStyle(
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
                    status: TimelineStatus.completed,
                    icon: Icons.check,
                  ),
                  _buildTimelineStep(
                    title: "Tinjauan Hukum",
                    description: "Tim hukum internal sedang meninjau klausul 4.2 dan 5.7 terkait kewajiban.",
                    status: TimelineStatus.active,
                    icon: Icons.gavel,
                    badgeText: "SEDANG BERJALAN",
                    subtitleWidget: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 10,
                            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Ditugaskan ke Sarah Jenkins (Penasihat Hukum)",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTimelineStep(
                    title: "Revisi",
                    description: "Implementasi umpan balik hukum dan penawaran balik mitra.",
                    status: TimelineStatus.pending,
                    icon: Icons.history,
                  ),
                  _buildTimelineStep(
                    title: "Persetujuan",
                    description: "Persetujuan akhir dari Dewan Eksekutif dan Direktur Bank.",
                    status: TimelineStatus.pending,
                    icon: Icons.assignment_turned_in_outlined,
                  ),
                  _buildTimelineStep(
                    title: "Aktif",
                    description: "Perjanjian berlaku di semua cabang regional.",
                    status: TimelineStatus.pending,
                    icon: Icons.rocket_launch_outlined,
                  ),
                  _buildTimelineStep(
                    title: "Kadaluarsa",
                    description: "Dijadwalkan untuk evaluasi perpanjangan pada Okt 2025.",
                    status: TimelineStatus.pending,
                    icon: Icons.update_disabled_outlined,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ringkasan Status Saat Ini
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F658A), Color(0xFF154863)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1F658A).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ringkasan Status Saat Ini",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.account_balance,
                        color: Colors.white.withOpacity(0.3),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "INSTITUSI MITRA",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$bankName (Persero) Tbk.",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem("EST. DURASI", "24 Bulan"),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          "PRIORITAS",
                          "Kritis",
                          color: const Color(0xFFFF8A80),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
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
