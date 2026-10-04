import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TugasModel(),
      child: const MyApp(),
    ),
  );
}

// =========================
// MODEL TUGAS
// =========================

class Tugas {
  String judul;
  bool selesai;

  Tugas(
      this.judul, {
        this.selesai = false,
      });
}

// =========================
// TUGAS MODEL
// =========================

class TugasModel extends ChangeNotifier {
  final List<Tugas> _items = [];

  List<Tugas> get items => List.unmodifiable(_items);

  int get jumlahSelesai =>
      _items.where((t) => t.selesai).length;

  // Menambahkan tugas
  void tambah(String judul) {
    _items.add(Tugas(judul));
    notifyListeners();
  }

  // Mengubah status tugas
  void toggle(int index) {
    _items[index].selesai = !_items[index].selesai;
    notifyListeners();
  }

  // Menghapus satu tugas
  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  // Latihan Mandiri 2
  // Menghapus semua tugas yang sudah selesai
  void hapusSelesai() {
    _items.removeWhere((t) => t.selesai);
    notifyListeners();
  }
}

// =========================
// MY APP
// =========================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 3',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// =========================
// HOME PAGE
// =========================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 3'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =========================
          // BAGIAN A
          // =========================
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Bagian A - Input Nama'),
              subtitle: const Text(
                'TextField dan TextEditingController',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InputPage(),
                  ),
                );
              },
            ),
          ),

          // =========================
          // BAGIAN B
          // =========================
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text(
                'Bagian B - Form Pendaftaran',
              ),
              subtitle: const Text(
                'Form, validasi, dropdown, dan checkbox',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FormPage(),
                  ),
                );
              },
            ),
          ),

          // =========================
          // BAGIAN D
          // =========================
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text(
                'Bagian D - Daftar Tugas',
              ),
              subtitle: const Text(
                'Provider dan ChangeNotifier',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TugasPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// BAGIAN A
// INPUT PAGE
// =========================

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _controller = TextEditingController();

  String _salam = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sapa() {
    setState(() {
      _salam = 'Halo, ${_controller.text}!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _sapa,
              child: const Text('Sapa'),
            ),

            const SizedBox(height: 12),

            Text(
              _salam,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// BAGIAN B
// FORM PAGE
// =========================

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nama = TextEditingController();
  final _email = TextEditingController();

  String? _jurusan;
  bool _setuju = false;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    super.dispose();
  }

  void _kirim() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Terdaftar: ${_nama.text} ($_jurusan)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pendaftaran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nama
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }

                  if (!value.contains('@')) {
                    return 'Email harus mengandung @';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Jurusan
              DropdownButtonFormField<String>(
                value: _jurusan,
                decoration: const InputDecoration(
                  labelText: 'Jurusan',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'TI',
                    child: Text('Teknik Informatika'),
                  ),
                  DropdownMenuItem(
                    value: 'SI',
                    child: Text('Sistem Informasi'),
                  ),
                  DropdownMenuItem(
                    value: 'TE',
                    child: Text('Teknik Elektro'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _jurusan = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih jurusan';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Checkbox
              CheckboxListTile(
                title: const Text(
                  'Saya menyetujui data yang dimasukkan',
                ),
                value: _setuju,
                onChanged: (value) {
                  setState(() {
                    _setuju = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Tombol Daftar
              ElevatedButton(
                onPressed: _setuju ? _kirim : null,
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// BAGIAN D
// TUGAS PAGE
// =========================

class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TugasModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tugas (${model.jumlahSelesai}/${model.items.length})',
        ),

        // =========================
        // LATIHAN MANDIRI 2
        // =========================
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus tugas selesai',
            onPressed: () {
              context.read<TugasModel>().hapusSelesai();
            },
          ),
        ],
      ),

      // =========================
      // LATIHAN MANDIRI 4
      // =========================
      body: model.items.isEmpty
          ? const Center(
        child: Text(
          'Belum ada tugas',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      )
          : ListView.builder(
        itemCount: model.items.length,
        itemBuilder: (context, i) {
          final t = model.items[i];

          return ListTile(
            leading: Checkbox(
              value: t.selesai,
              onChanged: (_) {
                context
                    .read<TugasModel>()
                    .toggle(i);
              },
            ),

            title: Text(
              t.judul,
              style: TextStyle(
                decoration: t.selesai
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),

            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context
                    .read<TugasModel>()
                    .hapus(i);
              },
            ),
          );
        },
      ),

      // =========================
      // TOMBOL TAMBAH
      // =========================
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final berhasil = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahPage(),
            ),
          );

          // =========================
          // LATIHAN MANDIRI 3
          // =========================
          if (berhasil == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tugas ditambahkan'),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =========================
// TAMBAH TUGAS
// =========================
// LATIHAN MANDIRI 1
// LATIHAN MANDIRI 3
// =========================

class TambahPage extends StatefulWidget {
  const TambahPage({super.key});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final _formKey = GlobalKey<FormState>();

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _simpan() {
    // Validasi Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final judul = _controller.text.trim();

    // Menambahkan tugas
    context.read<TugasModel>().tambah(judul);

    // Kembali ke halaman daftar
    // dengan mengirim nilai true
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                autofocus: true,

                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  border: OutlineInputBorder(),
                ),

                // =========================
                // LATIHAN MANDIRI 1
                // =========================
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Judul tugas wajib diisi';
                  }

                  if (value.trim().length < 3) {
                    return 'Judul tugas minimal 3 karakter';
                  }

                  return null;
                },

                onFieldSubmitted: (_) {
                  _simpan();
                },
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _simpan,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}