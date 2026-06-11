import 'package:flutter/material.dart';

class LegalMouFinalConfirmationScreen extends StatelessWidget {
  const LegalMouFinalConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Konfirmasi Tinjauan Akhir"),
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
                "DOKUMEN > PROSES TINJAUAN > PERSETUJUAN AKHIR",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              const Text(
                "Konfirmasi Tinjauan Akhir",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pastikan semua klausul dan persyaratan hukum terpenuhi sebelum meneruskan dokumen ini ke Kejaran Direktur.",
                style: TextStyle(fontSize: 15, height: 1.5),
              ),

              const SizedBox(height: 20),

              // Referensi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text("REFERENSI MOU: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("K124-AB-002", style: TextStyle(color: Color(0xFF1E88E5))),
                    Spacer(),
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Kemitraan Strategis:", style: TextStyle(fontSize: 16)),
                    const Text(
                      "TechGlobal Solutions",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("NILAI KONTRAK", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("\$450,000.00", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("STATUS TINJAUAN", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("Lolos Verifikasi Hukum", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("KEDALUARSA", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("Dec 31, 2025", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("PENILAIAN RISIKO", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("Rendah (Tingkat 1)", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Observasi Hukum Utama
              const Text(
                "Observasi Hukum Utama",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildObservationItem("Ketentuan perjanjian kerahasiaan (NDA) standar telah ditandatangani."),
              _buildObservationItem("Batasan tanggung jawab telah sesuai dengan kerangka risiko 2024."),

              const SizedBox(height: 24),

              // Direktur Penerima
              const Text(
                "DIREKTUR PENERIMA",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Adrian Thorne", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Direktur Solutions", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Protokol Kepercayaan Tinggi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Protokol Kepercayaan Tinggi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Dengan memilih melanjutkan, Anda telah memastikan dokumen ini telah lolos semua internal control dan memorandum standar hukum.",
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Lampiran Terlampir (3 file)",
                      style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Checkbox
              Row(
                children: [
                  Checkbox(value: true, onChanged: (val) {}),
                  const Expanded(
                    child: Text(
                      "Saya telah meninjau ke-12 klausul dan memastikan keabsahan seluruh isi dokumen ini.",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batalkan dan kembali ke draft"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Lanjutkan ke KBR"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObservationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}