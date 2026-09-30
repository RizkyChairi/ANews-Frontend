import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'myblog_page.dart';
import 'create_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      return const LoginPage();
    }

    final user = authProvider.user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildMenuItem(
              icon: Icons.article_outlined,
              title: 'My Posts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBlogPage()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.add_circle_outline,
              title: 'Create Post / Category',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePage()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => _showHelpDialog(context),
            ),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () => _showTermsDialog(context),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Yakin mau logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await context.read<AuthProvider>().logout();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            const Text('Help & Support'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Butuh Bantuan?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Jika Anda mengalami kesulitan dalam menggunakan aplikasi A News, '
                'silakan hubungi kami melalui kontak di bawah ini:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Kontak:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 18, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text('support@anews.id'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 18, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text('+62 812-3456-7890'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.web_outlined, size: 18, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text('www.anews.id'),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Jam Operasional:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Senin - Jumat, 09:00 - 17:00 WIB',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'FAQ:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '• Lupa password? Hubungi support untuk reset.\n'
                '• Post tidak muncul? Cek koneksi internet.\n'
                '• Gambar tidak load? Coba refresh halaman.',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description_outlined, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            const Text('Terms & Conditions'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Syarat & Ketentuan Penggunaan A News',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '1. Penerimaan Syarat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Dengan mengakses dan menggunakan aplikasi A News, Anda '
                'dianggap telah membaca, memahami, dan menyetujui seluruh '
                'syarat dan ketentuan yang berlaku.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                '2. Akun Pengguna',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Anda bertanggung jawab penuh atas keamanan akun Anda. '
                'Jangan bagikan password kepada siapapun. Kami tidak '
                'bertanggung jawab atas kerugian akibat kelalaian pengguna.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                '3. Konten yang Dilarang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pengguna dilarang mengunggah konten yang:\n'
                '• Mengandung SARA (Suku, Agama, Ras, Antargolongan)\n'
                '• Menyebarkan berita bohong (hoaks)\n'
                '• Melanggar hak cipta\n'
                '• Mengandung kekerasan atau pornografi\n'
                '• Menyinggung pihak lain',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
              SizedBox(height: 12),
              Text(
                '4. Hak Kekayaan Intelektual',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Seluruh konten yang Anda unggah tetap menjadi milik Anda. '
                'Namun, dengan mengunggah, Anda memberikan lisensi kepada '
                'A News untuk menampilkan konten tersebut di platform kami.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                '5. Penghapusan Akun',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kami berhak menghapus akun yang melanggar syarat dan '
                'ketentuan tanpa pemberitahuan sebelumnya.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                '6. Perubahan Syarat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kami dapat mengubah syarat dan ketentuan ini kapan saja. '
                'Perubahan akan berlaku segera setelah dipublikasikan '
                'di aplikasi.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                '7. Kontak',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Untuk pertanyaan terkait syarat & ketentuan, hubungi:\n'
                'Email: legal@anews.id',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Terakhir diperbarui: 15 September 2026',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}