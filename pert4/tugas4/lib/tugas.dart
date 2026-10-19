import 'package:flutter/material.dart';
import 'models.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Postingan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const DaftarPostinganPage(),
    );
  }
}

// ==================================================
// HALAMAN 1: DAFTAR POSTINGAN
// ==================================================

class DaftarPostinganPage extends StatefulWidget {
  const DaftarPostinganPage({super.key});

  @override
  State<DaftarPostinganPage> createState() =>
      _DaftarPostinganPageState();
}

class _DaftarPostinganPageState
    extends State<DaftarPostinganPage> {
  late Future<List<Post>> _futurePostingan;

  @override
  void initState() {
    super.initState();

    // Request pertama saat halaman dibuka
    _futurePostingan = ambilPostingan();
  }

  // Memuat ulang daftar postingan
  Future<void> _cobaLagi() async {
    final future = ambilPostingan();

    setState(() {
      _futurePostingan = future;
    });

    try {
      await future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _cobaLagi,
          ),
        ],
      ),

      // FutureBuilder pertama: mengambil daftar postingan
      body: FutureBuilder<List<Post>>(
        future: _futurePostingan,
        builder: (context, snapshot) {
          // Status loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Status error
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
                    const Text(
                      'Gagal memuat postingan.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _cobaLagi,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final postingan =
              snapshot.data ?? <Post>[];

          // Jika tidak ada postingan
          if (postingan.isEmpty) {
            return RefreshIndicator(
              onRefresh: _cobaLagi,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Text('Tidak ada postingan'),
                    ),
                  ),
                ],
              ),
            );
          }

          // Menampilkan daftar postingan
          return RefreshIndicator(
            onRefresh: _cobaLagi,
            child: ListView.builder(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: postingan.length,
              itemBuilder: (context, index) {
                final post = postingan[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      child: Text('${post.id}'),
                    ),
                    title: Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        post.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing:
                    const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailPostinganPage(post: post),
                        ),
                      );
                    },
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

// ==================================================
// HALAMAN 2: DETAIL POSTINGAN DAN KOMENTAR
// ==================================================

class DetailPostinganPage extends StatefulWidget {
  final Post post;

  const DetailPostinganPage({
    super.key,
    required this.post,
  });

  @override
  State<DetailPostinganPage> createState() =>
      _DetailPostinganPageState();
}

class _DetailPostinganPageState
    extends State<DetailPostinganPage> {
  late Future<List<Komentar>> _futureKomentar;

  @override
  void initState() {
    super.initState();

    // Request kedua: komentar berdasarkan ID postingan
    _futureKomentar =
        ambilKomentar(widget.post.id);
  }

  // Mengambil ulang komentar jika gagal
  Future<void> _cobaLagiKomentar() async {
    final future = ambilKomentar(widget.post.id);

    setState(() {
      _futureKomentar = future;
    });

    try {
      await future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Postingan #${post.id}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Judul postingan
          Text(
            post.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Informasi ID pengguna
          Text(
            'ID Pengguna: ${post.userId}',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const Divider(height: 32),

          // Isi lengkap postingan
          Text(
            post.body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 28),
          const Divider(),

          // Judul bagian komentar
          Text(
            'Komentar',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // FutureBuilder kedua: mengambil komentar
          FutureBuilder<List<Komentar>>(
            future: _futureKomentar,
            builder: (context, snapshot) {
              // Loading komentar
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Error komentar
              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gagal memuat komentar.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _cobaLagiKomentar,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final komentar =
                  snapshot.data ?? <Komentar>[];

              // Jika komentar kosong
              if (komentar.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Belum ada komentar.'),
                );
              }

              // Menampilkan semua komentar
              return Column(
                children: komentar.map((item) {
                  return Card(
                    margin:
                    const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          item.name.isNotEmpty
                              ? item.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                        const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(item.email),
                            const SizedBox(height: 8),
                            Text(item.body),
                          ],
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}