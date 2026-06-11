import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../models/user_model.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Agent"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, size: 60, color: Colors.blue),
            ),

            const SizedBox(height: 16),

            Text(
              user?.name ?? "Nama Agent",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text("Agent"),
              backgroundColor: Colors.blue[50],
            ),

            const SizedBox(height: 40),

            // Menu Profil
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Edit Profil"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fitur Edit Profil akan dibuat nanti")),
                );
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Riwayat Aktivitas"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Pengaturan"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
            const Divider(),

            // Tombol Logout
            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Keluar",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Keluar?"),
                    content: const Text("Apakah Anda yakin ingin keluar?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Keluar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await userProvider.logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}