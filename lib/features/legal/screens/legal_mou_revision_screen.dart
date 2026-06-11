import 'package:flutter/material.dart';

class LegalMouRevisionScreen extends StatelessWidget {
  const LegalMouRevisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Tinjauan Dokumen & Revisi"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb
              const Text(
                "Dokumen > SPH-2024-0812 > Draft Revisi",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),

              // Main Title
              const Text(
                "Tinjauan Dokumen & Revisi",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              const Text(
                "Berikan catatan revisi mendalam untuk dokumen Perjanjian Sewa-Menyewa Unit B-12. Pastikan semua poin hukum terpenuhi sebelum dikirimkan ke Business Representative.",
                style: TextStyle(fontSize: 15, height: 1.5),
              ),

              const SizedBox(height: 24),

              // Draft Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.description, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Draft Perjanjian Utama", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Terakhir: 24 Okt 2023 • Bagus Ramadhan", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility),
                        label: const Text("Pratinjau Dokumen"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info Grid
              Row(
                children: [
                  Expanded(child: _buildInfoBox("TIPE", "Legal Lease")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoBox("PRIORITAS", "High Priority", color: Colors.red)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInfoBox("KATEGORI", "Commercial")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoBox("LAMPIRAN", "3 Files")),
                ],
              ),

              const SizedBox(height: 24),

              // Catatan Revisi
              const Text(
                "CATATAN REVISI & KOMENTAR HUKUM",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Tuliskan poin-poin revisi secara mendetail di sini...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.list), onPressed: () {}),
                ],
              ),

              const SizedBox(height: 12),

              // Info Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Business Representative (BR) akan menerima notifikasi otomatis setelah Anda mengirimkan revisi ini.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Simpan Draft"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Kirim Revisi"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Riwayat Komunikasi
              const Text(
                "Riwayat Komunikasi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              _buildCommentItem(
                name: "Bagus Ramadhan",
                role: "Business Representative",
                time: "2 Jam lalu",
                message: "Dokumen ini mendesak untuk diselesaikan sore ini karena klien akan berangkat ke luar negeri besok. Mohon diprioritaskan bagian klausul asuransi.",
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem({
    required String name,
    required String role,
    required String time,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("$role • $time", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}