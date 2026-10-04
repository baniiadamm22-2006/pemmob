import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BelanjaModel(),
      child: const MyApp(),
    ),
  );
}

// ===============================
// MODEL DATA BARANG
// ===============================

class Barang {
  String nama;
  int jumlah;
  String kategori;
  bool sudahDibeli;

  Barang({
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.sudahDibeli = false,
  });
}

// ===============================
// CHANGE NOTIFIER
// ===============================

class BelanjaModel extends ChangeNotifier {
  final List<Barang> _items = [];

  List<Barang> get items => List.unmodifiable(_items);

  int get jumlahBelumDibeli =>
      _items.where((barang) => !barang.sudahDibeli).length;

  void tambahBarang(
      String nama,
      int jumlah,
      String kategori,
      ) {
    _items.add(
      Barang(
        nama: nama,
        jumlah: jumlah,
        kategori: kategori,
      ),
    );

    notifyListeners();
  }

  void toggleDibeli(int index) {
    _items[index].sudahDibeli =
    !_items[index].sudahDibeli;

    notifyListeners();
  }

  void hapusBarang(int index) {
    _items.removeAt(index);

    notifyListeners();
  }
}

// ===============================
// MY APP
// ===============================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const BelanjaPage(),
    );
  }
}

// ===============================
// HALAMAN DAFTAR BELANJA
// ===============================

class BelanjaPage extends StatelessWidget {
  const BelanjaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BelanjaModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Belanja (${model.jumlahBelumDibeli} belum dibeli)',
        ),
      ),
      body: model.items.isEmpty
          ? const Center(
        child: Text(
          'Belum ada barang',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      )
          : ListView.builder(
        itemCount: model.items.length,
        itemBuilder: (context, index) {
          final barang = model.items[index];

          return ListTile(
            leading: Checkbox(
              value: barang.sudahDibeli,
              onChanged: (_) {
                context
                    .read<BelanjaModel>()
                    .toggleDibeli(index);
              },
            ),
            title: Text(
              barang.nama,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: barang.sudahDibeli
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(
              'Jumlah: ${barang.jumlah} • Kategori: ${barang.kategori}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context
                    .read<BelanjaModel>()
                    .hapusBarang(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final berhasil = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahBarangPage(),
            ),
          );

          if (berhasil == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Barang berhasil ditambahkan'),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===============================
// HALAMAN TAMBAH BARANG
// ===============================

class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() =>
      _TambahBarangPageState();
}

class _TambahBarangPageState
    extends State<TambahBarangPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController =
  TextEditingController();

  final _jumlahController =
  TextEditingController();

  String? _kategori;

  final List<String> _kategoriList = [
    'Makanan',
    'Minuman',
    'Kebutuhan Rumah',
    'Kebutuhan Pribadi',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nama =
    _namaController.text.trim();

    final jumlah =
    int.parse(_jumlahController.text.trim());

    context.read<BelanjaModel>().tambahBarang(
      nama,
      jumlah,
      _kategori!,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Barang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===============================
              // NAMA BARANG
              // ===============================

              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  hintText: 'Contoh: Beras',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama barang wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ===============================
              // JUMLAH BARANG
              // ===============================

              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  hintText: 'Contoh: 2',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Jumlah wajib diisi';
                  }

                  final jumlah =
                  int.tryParse(value.trim());

                  if (jumlah == null) {
                    return 'Jumlah harus berupa angka';
                  }

                  if (jumlah <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ===============================
              // KATEGORI
              // ===============================

              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriList.map(
                      (kategori) {
                    return DropdownMenuItem(
                      value: kategori,
                      child: Text(kategori),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _kategori = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Kategori wajib dipilih';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ===============================
              // TOMBOL SIMPAN
              // ===============================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}