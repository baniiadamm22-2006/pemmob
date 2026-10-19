import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Penjelasan: Menjalankan aplikasi Flutter.
  runApp(const MyApp());
}

// =====================================================
// 1. MODEL DATA PENGELUARAN
// =====================================================

class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  // Penjelasan: Constructor untuk membuat objek pengeluaran.
  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  // Penjelasan: Mengubah objek menjadi Map agar bisa disimpan di SQLite.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'kategori': kategori,
      'tanggal': tanggal,
    };
  }

  // Penjelasan: Mengubah hasil query SQLite menjadi objek Pengeluaran.
  factory Pengeluaran.fromMap(Map<String, Object?> map) {
    return Pengeluaran(
      id: map['id'] as int,
      nama: map['nama'] as String,
      jumlah: map['jumlah'] as int,
      kategori: map['kategori'] as String,
      tanggal: map['tanggal'] as String,
    );
  }
}

// =====================================================
// 2. DATABASE SQLITE
// =====================================================

class DbHelper {
  static Database? _db;

  // Penjelasan: Membuka database atau menggunakan koneksi yang sudah ada.
  static Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }

    // Penjelasan: Database disimpan pada direktori lokal aplikasi.
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'pengeluaran.db');

    _db = await openDatabase(
      path,
      version: 1,

      // Penjelasan: Tabel dibuat saat database pertama kali dibuka.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pengeluaran (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            jumlah INTEGER NOT NULL,
            kategori TEXT NOT NULL,
            tanggal TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  // CREATE: Menambahkan pengeluaran baru.
  static Future<int> tambah(Pengeluaran data) async {
    final db = await database;

    return db.insert(
      'pengeluaran',
      data.toMap(),
    );
  }

  // READ: Mengambil seluruh pengeluaran berdasarkan tanggal terbaru.
  static Future<List<Pengeluaran>> semua() async {
    final db = await database;

    final hasil = await db.query(
      'pengeluaran',
      orderBy: 'tanggal DESC, id DESC',
    );

    return hasil.map((baris) => Pengeluaran.fromMap(baris)).toList();
  }

  // READ: Menghitung total pengeluaran menggunakan SQL SUM.
  static Future<int> total() async {
    final db = await database;

    final hasil = await db.rawQuery(
      'SELECT SUM(jumlah) AS total FROM pengeluaran',
    );

    // Penjelasan: Jika tabel kosong, total pengeluaran adalah 0.
    return (hasil.first['total'] as int?) ?? 0;
  }

  // UPDATE: Memperbarui data berdasarkan ID.
  static Future<int> ubah(Pengeluaran data) async {
    final db = await database;

    return db.update(
      'pengeluaran',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // DELETE: Menghapus data berdasarkan ID.
  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// =====================================================
// 3. APLIKASI DAN PENGATURAN MODE GELAP
// =====================================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Penjelasan: Menyimpan kondisi tema yang sedang digunakan.
  ThemeMode _tema = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _muatTema();
  }

  // Penjelasan: Membaca pengaturan mode gelap dari SharedPreferences.
  Future<void> _muatTema() async {
    final prefs = await SharedPreferences.getInstance();
    final gelap = prefs.getBool('mode_gelap') ?? false;

    if (!mounted) return;

    setState(() {
      _tema = gelap ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Penjelasan: Menyimpan pilihan mode gelap agar tetap ada setelah restart.
  Future<void> _ubahTema(bool gelap) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('mode_gelap', gelap);

    if (!mounted) return;

    setState(() {
      _tema = gelap ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Pengeluaran',
      debugShowCheckedModeBanner: false,

      // Penjelasan: Mengatur tema terang dan gelap aplikasi.
      themeMode: _tema,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),

      home: HalamanUtama(
        modeGelap: _tema == ThemeMode.dark,
        onTemaBerubah: _ubahTema,
      ),
    );
  }
}

// =====================================================
// 4. HALAMAN UTAMA DAN DAFTAR PENGELUARAN
// =====================================================

class HalamanUtama extends StatefulWidget {
  final bool modeGelap;
  final ValueChanged<bool> onTemaBerubah;

  const HalamanUtama({
    super.key,
    required this.modeGelap,
    required this.onTemaBerubah,
  });

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late Future<List<Pengeluaran>> _future;

  @override
  void initState() {
    super.initState();

    // Penjelasan: Mengambil daftar pengeluaran saat halaman dibuka.
    _future = DbHelper.semua();
  }

  // Penjelasan: Memuat ulang daftar setelah data berubah.
  void _muat() {
    setState(() {
      _future = DbHelper.semua();
    });
  }

  // Penjelasan: Membuka form tambah atau edit pengeluaran.
  Future<void> _bukaForm([Pengeluaran? data]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengeluaran(data: data),
      ),
    );

    if (!mounted) return;

    // Penjelasan: Memperbarui daftar dan total setelah kembali dari form.
    _muat();
  }

  // Penjelasan: Menampilkan dialog sebelum data benar-benar dihapus.
  Future<void> _konfirmasiHapus(Pengeluaran data) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus pengeluaran "${data.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // Penjelasan: Penghapusan hanya dilakukan jika pengguna menyetujui.
    if (setuju != true) return;

    await DbHelper.hapus(data.id!);

    if (!mounted) return;

    _muat();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengeluaran berhasil dihapus')),
    );
  }

  // Penjelasan: Mengubah angka menjadi format Rupiah.
  String _rupiah(int angka) {
    final teks = angka.toString();
    final hasil = StringBuffer();

    for (int i = 0; i < teks.length; i++) {
      hasil.write(teks[i]);

      final sisa = teks.length - i - 1;

      if (sisa > 0 && sisa % 3 == 0) {
        hasil.write('.');
      }
    }

    return 'Rp$hasil';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatat Pengeluaran'),

        // Penjelasan: Switch untuk mengaktifkan atau mematikan mode gelap.
        actions: [
          const Icon(Icons.light_mode_outlined),
          Switch(
            value: widget.modeGelap,
            onChanged: widget.onTemaBerubah,
          ),
          const Icon(Icons.dark_mode_outlined),
          const SizedBox(width: 8),
        ],
      ),

      // Penjelasan: FutureBuilder menampilkan data dari database secara asinkron.
      body: FutureBuilder<List<Pengeluaran>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Penjelasan: Menampilkan pesan jika proses membaca database gagal.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Terjadi kesalahan: ${snapshot.error}'),
              ),
            );
          }

          final data = snapshot.data ?? [];

          // Penjelasan: Future untuk menghitung total seluruh pengeluaran.
          return FutureBuilder<int>(
            future: DbHelper.total(),
            builder: (context, totalSnapshot) {
              if (totalSnapshot.hasError) {
                return Center(
                  child: Text('Gagal menghitung total: ${totalSnapshot.error}'),
                );
              }

              final total = totalSnapshot.data ?? 0;

              return Column(
                children: [
                  // Penjelasan: Kartu ringkasan total pengeluaran.
                  Card(
                    margin: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Pengeluaran',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _rupiah(total),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Penjelasan: Pesan jika belum ada pengeluaran.
                  if (data.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('Belum ada pengeluaran'),
                      ),
                    )
                  else
                  // Penjelasan: Menampilkan seluruh data menggunakan ListView.
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  item.kategori == 'Makanan'
                                      ? Icons.restaurant
                                      : item.kategori == 'Transportasi'
                                      ? Icons.directions_car
                                      : item.kategori == 'Belanja'
                                      ? Icons.shopping_bag
                                      : Icons.receipt_long,
                                ),
                              ),

                              // Penjelasan: Menampilkan nama dan kategori.
                              title: Text(
                                item.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${item.kategori} • ${item.tanggal}',
                              ),

                              // Penjelasan: Menampilkan jumlah pengeluaran.
                              trailing: SizedBox(
                                width: 130,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _rupiah(item.jumlah),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (pilihan) {
                                        if (pilihan == 'edit') {
                                          _bukaForm(item);
                                        } else if (pilihan == 'hapus') {
                                          _konfirmasiHapus(item);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Ubah'),
                                        ),
                                        PopupMenuItem(
                                          value: 'hapus',
                                          child: Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Penjelasan: Mengetuk item juga membuka form edit.
                              onTap: () => _bukaForm(item),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),

      // Penjelasan: Tombol tambah membuka form pengeluaran baru.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

// =====================================================
// 5. FORM TAMBAH DAN UBAH PENGELUARAN
// =====================================================

class FormPengeluaran extends StatefulWidget {
  final Pengeluaran? data;

  const FormPengeluaran({super.key, this.data});

  @override
  State<FormPengeluaran> createState() => _FormPengeluaranState();
}

class _FormPengeluaranState extends State<FormPengeluaran> {
  // Penjelasan: Key untuk memeriksa validasi seluruh form.
  final _formKey = GlobalKey<FormState>();

  // Penjelasan: Controller untuk membaca input pengguna.
  late final TextEditingController _nama;
  late final TextEditingController _jumlah;

  // Penjelasan: Daftar kategori yang tersedia dalam dropdown.
  final List<String> _kategoriList = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Kesehatan',
    'Lainnya',
  ];

  late String? _kategori;
  late DateTime _tanggal;

  @override
  void initState() {
    super.initState();

    // Penjelasan: Jika edit, isi form dengan data sebelumnya.
    _nama = TextEditingController(
      text: widget.data?.nama ?? '',
    );

    _jumlah = TextEditingController(
      text: widget.data == null ? '' : widget.data!.jumlah.toString(),
    );

    _kategori = widget.data?.kategori;

    // Penjelasan: Mempertahankan tanggal lama saat edit.
    // Jika tambah baru, tanggal otomatis menggunakan hari ini.
    _tanggal = widget.data == null
        ? DateTime.now()
        : DateTime.tryParse(widget.data!.tanggal) ?? DateTime.now();
  }

  @override
  void dispose() {
    // Penjelasan: Membersihkan controller saat form ditutup.
    _nama.dispose();
    _jumlah.dispose();
    super.dispose();
  }

  // Penjelasan: Mengubah tanggal menjadi format YYYY-MM-DD.
  String _formatTanggal(DateTime tanggal) {
    final tahun = tanggal.year.toString().padLeft(4, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final hari = tanggal.day.toString().padLeft(2, '0');

    return '$tahun-$bulan-$hari';
  }

  // Penjelasan: Membuka date picker untuk memilih tanggal pengeluaran.
  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dipilih == null || !mounted) return;

    setState(() {
      _tanggal = dipilih;
    });
  }

  // Penjelasan: Memvalidasi input lalu menyimpan data ke SQLite.
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori')),
      );
      return;
    }

    final angka = int.tryParse(_jumlah.text.trim());

    // Penjelasan: Mencegah jumlah kosong, bukan angka, atau kurang dari 1.
    if (angka == null || angka <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah harus berupa angka lebih dari 0'),
        ),
      );
      return;
    }

    // Penjelasan: Membentuk objek dari data form.
    final data = Pengeluaran(
      id: widget.data?.id,
      nama: _nama.text.trim(),
      jumlah: angka,
      kategori: _kategori!,
      tanggal: _formatTanggal(_tanggal),
    );

    // Penjelasan: Jika ID belum ada, data baru ditambahkan.
    // Jika ID sudah ada, data lama diperbarui.
    if (widget.data == null) {
      await DbHelper.tambah(data);
    } else {
      await DbHelper.ubah(data);
    }

    if (!mounted) return;

    // Penjelasan: Kembali ke halaman utama setelah penyimpanan selesai.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.data != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran',
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Penjelasan: Input nama wajib diisi.
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama pengeluaran',
                hintText: 'Contoh: Makan siang',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (nilai) {
                if (nilai == null || nilai.trim().isEmpty) {
                  return 'Nama pengeluaran wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Penjelasan: Input jumlah hanya menerima angka bulat positif.
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rupiah)',
                hintText: 'Contoh: 15000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments),
              ),
              validator: (nilai) {
                if (nilai == null || nilai.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }

                final angka = int.tryParse(nilai.trim());

                if (angka == null) {
                  return 'Jumlah harus berupa angka bulat';
                }

                if (angka <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // Penjelasan: Dropdown membatasi pilihan kategori.
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (nilai) {
                setState(() {
                  _kategori = nilai;
                });
              },
              validator: (nilai) {
                if (nilai == null || nilai.isEmpty) {
                  return 'Kategori wajib dipilih';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Penjelasan: Tombol untuk memilih tanggal pengeluaran.
            OutlinedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.calendar_month),
              label: Text('Tanggal: ${_formatTanggal(_tanggal)}'),
            ),

            const SizedBox(height: 24),

            // Penjelasan: Tombol menyimpan atau memperbarui pengeluaran.
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: Text(
                isEdit ? 'Simpan Perubahan' : 'Simpan Pengeluaran',
              ),
            ),
          ],
        ),
      ),
    );
  }
}