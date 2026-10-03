import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// MODEL DATA MAKANAN
class Makanan {
  final String nama;
  final int harga;
  final String deskripsi;

  const Makanan(
      this.nama,
      this.harga,
      this.deskripsi,
      );
}

// DATA MENU
// Latihan Mandiri 1:
// Menambahkan 3 menu baru
const daftarMenu = [
  Makanan(
    'Nasi Goreng',
    15000,
    'Nasi goreng dengan bumbu khas.',
  ),
  Makanan(
    'Mie Ayam',
    12000,
    'Mie dengan ayam dan sayuran.',
  ),
  Makanan(
    'Es Teh',
    4000,
    'Minuman teh manis dingin.',
  ),
  Makanan(
    'Ayam Bakar',
    20000,
    'Ayam bakar dengan bumbu kecap.',
  ),
  Makanan(
    'Bakso',
    13000,
    'Bakso dengan kuah hangat.',
  ),
  Makanan(
    'Soto Ayam',
    14000,
    'Soto ayam dengan kuah gurih.',
  ),
  Makanan(
    'Es Jeruk',
    5000,
    'Minuman jeruk segar.',
  ),
];

// Latihan Mandiri 4:
// Fungsi untuk format harga menjadi ribuan
// Contoh: 15000 menjadi 15.000
String formatHarga(int harga) {
  return harga.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
  );
}

// APLIKASI UTAMA
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}

// HALAMAN DAFTAR MENU
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
      ),

      // Bagian B:
      // ListView.builder untuk menampilkan daftar data
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];

          // Latihan Mandiri 3:
          // Card diganti menjadi Container
          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent,
              borderRadius: BorderRadius.circular(12),
            ),

            child: ListTile(
              leading: const Icon(
                Icons.restaurant,
              ),

              title: Text(
                item.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Latihan Mandiri 4:
              // Harga menggunakan format ribuan
              subtitle: Text(
                'Rp ${formatHarga(item.harga)}',
              ),

              trailing: const Icon(
                Icons.chevron_right,
              ),

              // Bagian C:
              // Navigasi ke halaman detail
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(
                      makanan: item,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// HALAMAN DETAIL
class DetailPage extends StatelessWidget {
  final Makanan makanan;

  const DetailPage({
    super.key,
    required this.makanan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          makanan.nama,
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 80,
              ),

              const SizedBox(height: 16),

              // Nama makanan
              Text(
                makanan.nama,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Harga
              Text(
                'Rp ${formatHarga(makanan.harga)}',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 16),

              // Latihan Mandiri 2:
              // Menampilkan deskripsi makanan
              Text(
                makanan.deskripsi,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              // Tombol kembali
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Kembali',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}