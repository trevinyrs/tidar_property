import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LegalMouReviewScreen extends StatelessWidget {
  final String documentId;

  const LegalMouReviewScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mou_documents')
          .doc(documentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Dokumen tidak ditemukan")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'Pending';
        final title = data['title'] ?? 'MoU - Global Strategic Bank';
        final documentType = data['documentType'] ?? '';

        final type = (data['type'] ?? '').toString().toLowerCase();

        String entityName = '-';

        if (type == 'agent') {
          entityName = data['company'] ?? data['agentName'] ?? '-';
        } else {
          entityName = data['bankName'] ?? '-';
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F6F8),
            elevation: 0,
            title: const Text("TINJAUAN MoU"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "DOKUMEN  >  TINJAUAN MOU",
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: Color(0xFF7B8085),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E3438),
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCEAF5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "TINJAUAN DRAFT",
                              style: TextStyle(
                                color: Color(0xFF4A708B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "ID: $documentId",
                            style: const TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "● PRIORITAS TINGGI",
                        style: TextStyle(
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Berikan\nRevisi",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF0F5E8E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Setujui &\nTeruskan",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Detail Mitra",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.info_outline, color: Colors.grey.shade600),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCFEAFF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.account_balance,
                              color: Color(0xFF2C5D87),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "NAMA ENTITAS",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  entityName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: const [
                          Expanded(
                            child: _InfoItem(
                              title: "PERWAKILAN",
                              value: "Adrian Prasetya",
                            ),
                          ),
                          Expanded(
                            child: _InfoItem(
                              title: "KATEGORI",
                              value: "Lembaga Keuangan",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Klausul Utama
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Klausul Utama & Catatan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildKlausulItem(
                        "Klausul Kerahasiaan",
                        "Pasal 4.2 - Standar Industri",
                      ),
                      _buildKlausulItem(
                        "Yurisdiksi Arbitrase",
                        "Pasal 12 - Jakarta (BANI)",
                      ),
                      _buildWarningItem(
                        "Batasan Tanggung Jawab",
                        "Perlu Tinjauan Hukum Lebih Lanjut",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningItem(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
      title: Text(title, style: const TextStyle(color: Colors.red)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.redAccent)),
    );
  }

  Widget _buildKlausulItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, color: Color(0xFF0D5A88)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
