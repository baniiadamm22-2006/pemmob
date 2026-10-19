
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ==================================================
// MAIN: TITIK AWAL APLIKASI
// ==================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum Flutter 4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PenggunaPage(),
    );
  }
}

// ==================================================
// BAGIAN A: FUTURE DAN FUTUREBUILDER
// ==================================================

// Simulasi proses mengambil data selama 2 detik.
Future<String> ambilSalam() async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Halo dari masa depan!';
}

// Halaman demo FutureBuilder.
class SalamPage extends StatefulWidget {
  const SalamPage({super.key});

  @override
  State<SalamPage> createState() => _SalamPageState();
}

class _SalamPageState extends State<SalamPage> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilSalam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Future'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: _future,
          builder: (context, snapshot) {
            // Menampilkan loading.
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // Menampilkan error jika terjadi kegagalan.
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // Menampilkan hasil Future.
            return Text(
              snapshot.data ?? '',
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
      ),
    );
  }
}

// ==================================================
// BAGIAN C: MODEL DATA PENGGUNA
// ==================================================

class Pengguna {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String city;

  const Pengguna({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.city,
  });

  // Mengubah JSON dari API menjadi objek Pengguna.
  factory Pengguna.fromJson(Map<String, dynamic> json) {
    final address =
    json['address'] as Map<String, dynamic>;

    return Pengguna(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String,
      city: address['city'] as String,
    );
  }
}

// ==================================================
// BAGIAN C: FUNGSI MENGAMBIL DATA REST API
// ==================================================

Future<List<Pengguna>> ambilPengguna() async {
  final uri = Uri.parse(
    'https://jsonplaceholder.typicode.com/users',
  );

  // Mengirim GET request dengan batas waktu 10 detik.
  final response = await http
      .get(uri)
      .timeout(const Duration(seconds: 10));

  // Memeriksa status HTTP.
  if (response.statusCode != 200) {
    throw Exception(
      'Gagal memuat data. Kode: ${response.statusCode}',
    );
  }

  // Mengubah JSON menjadi daftar objek Pengguna.
  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map(
        (item) => Pengguna.fromJson(
      item as Map<String, dynamic>,
    ),
  )
      .toList();
}

// ==================================================
// BAGIAN D: HALAMAN DAFTAR PENGGUNA
// ==================================================

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  late Future<List<Pengguna>> _future;

  @override
  void initState() {
    super.initState();

    // Memanggil API saat halaman pertama kali dibuka.
    _future = ambilPengguna();
  }

  // Memuat ulang data dari API.
  void _muatUlang() {
    setState(() {
      _future = ambilPengguna();
    });
  }

  // ==================================================
  // LATIHAN MANDIRI: REFRESHINDICATOR
  // ==================================================

  Future<void> _refresh() async {
    _muatUlang();

    try {
      await _future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // LATIHAN MANDIRI: JUMLAH PENGGUNA DI APPBAR
        title: FutureBuilder<List<Pengguna>>(
          future: _future,
          builder: (context, snapshot) {
            final jumlah = snapshot.data?.length;

            return Text(
              jumlah == null
                  ? 'Daftar Pengguna'
                  : 'Daftar Pengguna ($jumlah)',
            );
          },
        ),

        // Tombol refresh manual.
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _muatUlang,
          ),
        ],
      ),

      // FutureBuilder mengatur loading, error, dan data.
      body: FutureBuilder<List<Pengguna>>(
        future: _future,
        builder: (context, snapshot) {
          // STATUS LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // STATUS ERROR
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _muatUlang,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          // LATIHAN MANDIRI: KONDISI DATA KOSONG
          if (data.isEmpty) {
            return const Center(
              child: Text('Tidak ada data pengguna.'),
            );
          }

          // LATIHAN MANDIRI: TARIK KE BAWAH UNTUK REFRESH
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final p = data[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(p.name[0]),
                  ),

                  title: Text(p.name),

                  // LATIHAN MANDIRI:
                  // MENAMPILKAN USERNAME DAN CITY
                  subtitle: Text(
                    '@${p.username}\n'
                        '${p.email}\n'
                        'Kota: ${p.city}',
                  ),
                  isThreeLine: true,

                  trailing: const Icon(
                    Icons.chevron_right,
                  ),

                  // BAGIAN D: NAVIGASI KE DETAIL
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPenggunaPage(pengguna: p),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==================================================
// BAGIAN E: HALAMAN DETAIL PENGGUNA
// ==================================================

class DetailPenggunaPage extends StatelessWidget {
  final Pengguna pengguna;

  const DetailPenggunaPage({
    super.key,
    required this.pengguna,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pengguna.name),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Nama'),
            subtitle: Text(pengguna.name),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Username'),
            subtitle: Text(pengguna.username),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(pengguna.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Telepon'),
            subtitle: Text(pengguna.phone),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Website'),
            subtitle: Text(pengguna.website),
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Kota'),
            subtitle: Text(pengguna.city),
          ),
        ],
      ),
    );
  }
}
