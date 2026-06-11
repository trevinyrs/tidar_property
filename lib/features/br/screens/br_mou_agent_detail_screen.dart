import 'package:flutter/material.dart';

class BrMouAgentDetailScreen extends StatelessWidget {
  final String agentName;
  final String company;

  const BrMouAgentDetailScreen({
    super.key,
    required this.agentName,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Image.asset("assets/images/logo_tidar.png", height: 35),
                    ],
                  ),

                  const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF374151),
                  ),
                ],
              ),
            ),
            // Header Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ID KASUS : #TOR-77421",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Pelacakan MOU",
                    style: const TextStyle(
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0284C7),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        "Saat ini dalam Tinjauan Hukum",
                        style: TextStyle(
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Siklus Hidup Perjanjian",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Column(
                      children: [
                        _timelineNode("Draft", Icons.edit_document, true),
                        _timelineLine(),

                        _timelineNode("Review Legal", Icons.gavel, true),
                        _timelineLine(),

                        _timelineNode("Revisi", Icons.sync, true, active: true),
                        _timelineLine(),

                        _timelineNode("Approval", Icons.verified_user, false),
                        _timelineLine(),

                        _timelineNode("Aktif", Icons.check_circle, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _timelineLine() {
    return Container(width: 2, height: 45, color: Colors.grey.shade300);
  }

  Widget _timelineNode(
    String title,
    IconData icon,
    bool completed, {
    bool active = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? const Color(0xFF1E88E5)
                : completed
                ? const Color(0xFF1565C0)
                : Colors.grey.shade300,
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF1565C0) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep(
    String title,
    String date,
    String description,
    bool isCompleted, {
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : (isActive ? Colors.blue : Colors.grey[300]),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
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
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
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
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

Widget _buildModernTimeline({
  required String title,
  required String description,
  required bool completed,
  bool active = false,
}) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed
                    ? const Color(0xFF0F766E)
                    : active
                    ? const Color(0xFF0284C7)
                    : Colors.grey.shade300,
              ),
              child: Icon(
                completed ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 14,
              ),
            ),

            Container(width: 2, height: 80, color: Colors.grey.shade300),
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
                  fontWeight: FontWeight.bold,
                  color: active ? const Color(0xFF0284C7) : Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: TextStyle(color: Colors.grey.shade600, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
