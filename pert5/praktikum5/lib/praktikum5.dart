
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// ============================================================
// MAIN APP
// ============================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _muatTema();
  }

  // BAGIAN A: Mengambil pengaturan tema dari SharedPreferences
  Future<void> _muatTema() async {
    final prefs = await SharedPreferences.getInstance();
    final gelap = prefs.getBool('gelap') ?? false;

    if (!mounted) return;

    setState(() {
      _themeMode = gelap ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // BAGIAN A: Mengubah tema aplikasi
  void _ubahTema(bool gelap) {
    setState(() {
      _themeMode = gelap ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Praktikum Pertemuan 5',
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: PengaturanPage(onThemeChanged: _ubahTema),
    );
  }
}

// ============================================================
// BAGIAN A: SHAREDPREFERENCES
// Menyimpan nama, mode gelap, dan jumlah aplikasi dibuka
// ============================================================

class PengaturanPage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const PengaturanPage({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final TextEditingController _controller = TextEditingController();

  bool _gelap = false;
  int _bukaKe = 0;

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  // Membaca data dari SharedPreferences
  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();

    // Menghitung jumlah aplikasi dibuka
    int jumlahBuka = prefs.getInt('bukaKe') ?? 0;
    jumlahBuka++;

    await prefs.setInt('bukaKe', jumlahBuka);

    if (!mounted) return;

    setState(() {
      _controller.text = prefs.getString('nama') ?? '';
      _gelap = prefs.getBool('gelap') ?? false;
      _bukaKe = jumlahBuka;
    });

    widget.onThemeChanged(_gelap);
  }

  // Menyimpan nama dan mode gelap
  Future<void> _simpanPengaturan() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nama', _controller.text);
    await prefs.setBool('gelap', _gelap);

    widget.onThemeChanged(_gelap);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan'),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // BAGIAN A: Menyimpan nama pengguna
            const Text(
              'Nama Pengguna',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan nama',
              ),
            ),

            const SizedBox(height: 20),

            // BAGIAN A: Pengaturan mode gelap
            SwitchListTile(
              title: const Text('Mode Gelap'),
              value: _gelap,
              onChanged: (value) {
                setState(() {
                  _gelap = value;
                });

                widget.onThemeChanged(value);
              },
            ),

            // BAGIAN A: Menampilkan jumlah aplikasi dibuka
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Aplikasi telah dibuka'),
              subtitle: Text('$_bukaKe kali'),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _simpanPengaturan,
              child: const Text('Simpan Pengaturan'),
            ),

            const Divider(height: 35),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TesDatabasePage(),
                  ),
                );
              },
              icon: const Icon(Icons.storage),
              label: const Text('Buka Database Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BAGIAN B: SQLITE
// MODEL DATA CATATAN
// ============================================================

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String? dibuat;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    this.dibuat,
  });

  // Mengubah objek Catatan menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'dibuat': dibuat ?? DateTime.now().toIso8601String(),
    };
  }

  // Mengubah data Map menjadi objek Catatan
  factory Catatan.fromMap(Map<String, dynamic> map) {
    return Catatan(
      id: map['id'],
      judul: map['judul'],
      isi: map['isi'],
      dibuat: map['dibuat'],
    );
  }
}

// ============================================================
// BAGIAN B: SQLITE
// DATABASE HELPER
// ============================================================

class DbHelper {
  static Database? _db;

  // Membuka database catatan.db
  static Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'catatan.db');

    _db = await openDatabase(
      path,

      // LATIHAN MANDIRI 3:
      // Versi database dinaikkan menjadi 2
      version: 2,

      // BAGIAN B:
      // Membuat tabel ketika database pertama kali dibuat
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE catatan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            isi TEXT NOT NULL,
            dibuat TEXT
          )
        ''');
      },

      // LATIHAN MANDIRI 3:
      // Menambahkan kolom dibuat pada database versi lama
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE catatan ADD COLUMN dibuat TEXT',
          );
        }
      },
    );

    return _db!;
  }

  // BAGIAN D: CREATE
  // Menambahkan catatan baru
  static Future<int> tambah(Catatan catatan) async {
    final db = await database;

    return await db.insert('catatan', {
      'judul': catatan.judul,
      'isi': catatan.isi,
      'dibuat': DateTime.now().toIso8601String(),
    });
  }

  // BAGIAN C:
  // Mengambil seluruh catatan dari database
  //
  // LATIHAN MANDIRI 2:
  // Mencari catatan berdasarkan judul menggunakan LIKE
  //
  // LATIHAN MANDIRI 4:
  // Mengurutkan catatan berdasarkan tanggal dibuat
  static Future<List<Catatan>> semua({
    String kata = '',
    String urutan = 'terbaru',
  }) async {
    final db = await database;

    // Menentukan urutan data
    final arah = urutan == 'terbaru' ? 'DESC' : 'ASC';

    final hasil = await db.query(
      'catatan',
      where: kata.isEmpty ? null : 'judul LIKE ?',
      whereArgs: kata.isEmpty ? null : ['%$kata%'],
      orderBy: 'dibuat $arah',
    );

    return hasil.map((data) => Catatan.fromMap(data)).toList();
  }

  // BAGIAN D: UPDATE
  // Mengubah judul dan isi catatan
  // Tanggal dibuat tidak ikut berubah
  static Future<int> ubah(Catatan catatan) async {
    final db = await database;

    return await db.update(
      'catatan',
      {
        'judul': catatan.judul,
        'isi': catatan.isi,
      },
      where: 'id = ?',
      whereArgs: [catatan.id],
    );
  }

  // BAGIAN D: DELETE
  // Menghapus catatan berdasarkan ID
  static Future<int> hapus(int id) async {
    final db = await database;

    return await db.delete(
      'catatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ============================================================
// BAGIAN C DAN D: HALAMAN DATABASE CATATAN
// ============================================================

class TesDatabasePage extends StatefulWidget {
  const TesDatabasePage({super.key});

  @override
  State<TesDatabasePage> createState() => _TesDatabasePageState();
}

class _TesDatabasePageState extends State<TesDatabasePage> {
  final TextEditingController _judulController =
  TextEditingController();

  final TextEditingController _isiController =
  TextEditingController();

  // LATIHAN MANDIRI 2: Controller pencarian
  final TextEditingController _cariController =
  TextEditingController();

  List<Catatan> _catatan = [];

  // LATIHAN MANDIRI 4:
  // Menyimpan pilihan pengurutan
  String _urutan = 'terbaru';

  @override
  void initState() {
    super.initState();
    _muatPengaturanUrutan();
  }

  // LATIHAN MANDIRI 4:
  // Mengambil pilihan urutan dari SharedPreferences
  Future<void> _muatPengaturanUrutan() async {
    final prefs = await SharedPreferences.getInstance();

    final urutanTersimpan =
        prefs.getString('urutan') ?? 'terbaru';

    if (!mounted) return;

    setState(() {
      _urutan = urutanTersimpan;
    });

    await _muatCatatan();
  }

  // LATIHAN MANDIRI 4:
  // Menyimpan pilihan urutan ke SharedPreferences
  Future<void> _simpanPengaturanUrutan(String? nilai) async {
    if (nilai == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('urutan', nilai);

    if (!mounted) return;

    setState(() {
      _urutan = nilai;
    });

    await _muatCatatan();
  }

  // BAGIAN C:
  // Mengambil data dari database dan memperbarui tampilan
  Future<void> _muatCatatan() async {
    final data = await DbHelper.semua(
      kata: _cariController.text,
      urutan: _urutan,
    );

    if (!mounted) return;

    setState(() {
      _catatan = data;
    });
  }

  // LATIHAN MANDIRI 3:
  // Mengubah format tanggal agar mudah dibaca
  String _formatTanggal(String? nilai) {
    if (nilai == null) {
      return 'Tanggal belum tersedia';
    }

    final tanggal = DateTime.tryParse(nilai);

    if (tanggal == null) return nilai;

    final d = tanggal.toLocal();

    return '${d.day}/${d.month}/${d.year} '
        '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  // BAGIAN D: CREATE
  // Menyimpan catatan baru
  Future<void> _simpanCatatan() async {
    if (_judulController.text.trim().isEmpty ||
        _isiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan isi catatan wajib diisi'),
        ),
      );
      return;
    }

    final catatan = Catatan(
      judul: _judulController.text.trim(),
      isi: _isiController.text.trim(),
    );

    await DbHelper.tambah(catatan);

    _judulController.clear();
    _isiController.clear();

    await _muatCatatan();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan berhasil ditambahkan'),
      ),
    );
  }

  // BAGIAN D: UPDATE
  // Mengedit catatan yang sudah tersimpan
  Future<void> _editCatatan(Catatan catatan) async {
    _judulController.text = catatan.judul;
    _isiController.text = catatan.isi;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Catatan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _isiController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _judulController.clear();
                _isiController.clear();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_judulController.text.trim().isEmpty ||
                    _isiController.text.trim().isEmpty) {
                  return;
                }

                final hasil = Catatan(
                  id: catatan.id,
                  judul: _judulController.text.trim(),
                  isi: _isiController.text.trim(),
                );

                await DbHelper.ubah(hasil);

                if (!context.mounted) return;

                Navigator.pop(context);

                _judulController.clear();
                _isiController.clear();

                await _muatCatatan();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // LATIHAN MANDIRI 1:
  // Menampilkan dialog konfirmasi sebelum menghapus
  Future<void> _konfirmasiHapus(Catatan catatan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Hapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      await DbHelper.hapus(catatan.id!);
      await _muatCatatan();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil dihapus'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _cariController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Catatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BAGIAN D: FORM TAMBAH CATATAN
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tambah Catatan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Catatan',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _isiController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simpanCatatan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Catatan'),
              ),
            ),

            const Divider(height: 30),

            // LATIHAN MANDIRI 2:
            // Pencarian catatan berdasarkan judul
            TextField(
              controller: _cariController,
              onChanged: (value) {
                _muatCatatan();
              },
              decoration: InputDecoration(
                labelText: 'Cari catatan berdasarkan judul',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _cariController.clear();
                    _muatCatatan();
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // LATIHAN MANDIRI 4:
            // Pilihan pengurutan terbaru dan terlama
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Urutkan Catatan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _urutan,
                  items: const [
                    DropdownMenuItem(
                      value: 'terbaru',
                      child: Text('Terbaru'),
                    ),
                    DropdownMenuItem(
                      value: 'terlama',
                      child: Text('Terlama'),
                    ),
                  ],
                  onChanged: _simpanPengaturanUrutan,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // BAGIAN C: DAFTAR CATATAN
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Catatan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _catatan.isEmpty
                  ? const Center(
                child: Text('Belum ada catatan'),
              )
                  : ListView.builder(
                itemCount: _catatan.length,
                itemBuilder: (context, index) {
                  final catatan = _catatan[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.note),
                      title: Text(catatan.judul),

                      // LATIHAN MANDIRI 3:
                      // Menampilkan tanggal pembuatan catatan
                      subtitle: Text(
                        'Isi: ${catatan.isi}\n'
                            'Dibuat: ${_formatTanggal(catatan.dibuat)}',
                      ),

                      isThreeLine: true,

                      // BAGIAN D: Tombol edit dan hapus
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              _editCatatan(catatan);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _konfirmasiHapus(catatan);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
