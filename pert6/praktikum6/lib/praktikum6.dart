
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================================================
// BAGIAN A + LATIHAN 1
// TEMA LIGHT, DARK, WARNA, DAN PENYIMPANAN
// =====================================================

final ValueNotifier<ThemeMode> themeMode =
ValueNotifier(ThemeMode.light);

final ValueNotifier<Color> seedColor =
ValueNotifier(Colors.blue);

final Map<String, Color> pilihanWarna = {
  'Biru': Colors.blue,
  'Merah': Colors.red,
  'Hijau': Colors.green,
  'Ungu': Colors.purple,
  'Oranye': Colors.orange,
};

// Menyimpan pengaturan tema
Future<void> simpanPengaturan() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'themeMode',
    themeMode.value == ThemeMode.dark ? 'dark' : 'light',
  );

  await prefs.setInt(
    'seedColor',
    seedColor.value.toARGB32(),
  );
}

// Memuat pengaturan tema
Future<void> muatPengaturan() async {
  final prefs = await SharedPreferences.getInstance();

  final mode = prefs.getString('themeMode') ?? 'light';

  final warna =
      prefs.getInt('seedColor') ?? Colors.blue.toARGB32();

  themeMode.value =
  mode == 'dark' ? ThemeMode.dark : ThemeMode.light;

  seedColor.value = Color(warna);
}

// Membuat tema aplikasi
ThemeData buatTema(Color warna, Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: warna,
      brightness: brightness,
    ),
    useMaterial3: true,
  );
}

// =====================================================
// MAIN APP
// =====================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await muatPengaturan();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        themeMode,
        seedColor,
      ]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Praktikum Flutter 6',

          theme: buatTema(
            seedColor.value,
            Brightness.light,
          ),

          darkTheme: buatTema(
            seedColor.value,
            Brightness.dark,
          ),

          themeMode: themeMode.value,

          home: const ShellPage(),

          // BAGIAN B + LATIHAN 3
          // ROUTING DETAIL DENGAN FADE TRANSITION
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final argument = settings.arguments;

              if (argument is Item) {
                return PageRouteBuilder(
                  settings: settings,

                  pageBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      ) {
                    return DetailPage(item: argument);
                  },

                  transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                      ) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },

                  transitionDuration:
                  const Duration(milliseconds: 500),
                );
              }

              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text('Data item tidak ditemukan'),
                  ),
                ),
              );
            }

            return null;
          },

          // LATIHAN 4
          // HALAMAN 404
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) {
                return const Halaman404();
              },
            );
          },
        );
      },
    );
  }
}

// =====================================================
// BAGIAN D + LATIHAN 2
// SHELL PAGE DAN DRAWER
// =====================================================

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int selectedIndex = 0;

  static const List<Widget> halaman = [
    BerandaTab(),
    AnimasiTab(),
    PengaturanTab(),
  ];

  static const List<String> judul = [
    'Beranda',
    'Animasi',
    'Pengaturan',
  ];

  void pindahTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(judul[selectedIndex]),
        centerTitle: true,
      ),

      // LATIHAN 2: DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.flutter_dash,
                    size: 45,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Praktikum Flutter 6',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              selected: selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                pindahTab(0);
              },
            ),

            ListTile(
              leading: const Icon(Icons.animation),
              title: const Text('Animasi'),
              selected: selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                pindahTab(1);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              selected: selectedIndex == 2,
              onTap: () {
                Navigator.pop(context);
                pindahTab(2);
              },
            ),
          ],
        ),
      ),

      // BAGIAN D: INDEXED STACK
      body: IndexedStack(
        index: selectedIndex,
        children: halaman,
      ),

      // BAGIAN D: NAVIGATION BAR
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: pindahTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.animation_outlined),
            selectedIcon: Icon(Icons.animation),
            label: 'Animasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// BAGIAN A
// PENGATURAN TEMA
// =====================================================

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pengaturan Tema',
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 16),

        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeMode,
          builder: (context, mode, child) {
            return SwitchListTile(
              title: const Text('Mode Gelap'),
              subtitle: const Text(
                'Aktifkan atau matikan tema gelap',
              ),
              value: mode == ThemeMode.dark,

              // LATIHAN 1: SIMPAN MODE TEMA
              onChanged: (value) async {
                themeMode.value = value
                    ? ThemeMode.dark
                    : ThemeMode.light;

                await simpanPengaturan();
              },
            );
          },
        ),

        const Divider(),

        Text(
          'Pilih Warna Tema',
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 10),

        ...pilihanWarna.entries.map((warna) {
          return ValueListenableBuilder<Color>(
            valueListenable: seedColor,
            builder: (context, selectedColor, child) {
              return RadioListTile<Color>(
                title: Text(warna.key),
                value: warna.value,
                groupValue: selectedColor,
                activeColor: warna.value,

                // LATIHAN 1: SIMPAN WARNA
                onChanged: (value) async {
                  if (value != null) {
                    seedColor.value = value;
                    await simpanPengaturan();
                  }
                },
              );
            },
          );
        }),
      ],
    );
  }
}

// =====================================================
// BAGIAN B
// MODEL ITEM
// =====================================================

class Item {
  final String nama;
  final String deskripsi;
  final IconData ikon;
  final Color warna;

  const Item({
    required this.nama,
    required this.deskripsi,
    required this.ikon,
    required this.warna,
  });
}

final List<Item> daftarItem = [
  Item(
    nama: 'Flutter',
    deskripsi:
    'Framework untuk membangun aplikasi multiplatform.',
    ikon: Icons.flutter_dash,
    warna: Colors.blue,
  ),
  Item(
    nama: 'Musik',
    deskripsi:
    'Aplikasi untuk mendengarkan musik favorit.',
    ikon: Icons.music_note,
    warna: Colors.purple,
  ),
  Item(
    nama: 'Kamera',
    deskripsi:
    'Aplikasi untuk mengambil dan menyimpan foto.',
    ikon: Icons.camera_alt,
    warna: Colors.orange,
  ),
  Item(
    nama: 'Peta',
    deskripsi:
    'Aplikasi untuk melihat lokasi dan navigasi.',
    ikon: Icons.map,
    warna: Colors.green,
  ),
];

// =====================================================
// BAGIAN B
// BERANDA TAB
// =====================================================

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daftarItem.length,
      itemBuilder: (context, index) {
        final item = daftarItem[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Hero(
              tag: item.nama,
              child: CircleAvatar(
                backgroundColor: item.warna,
                child: Icon(
                  item.ikon,
                  color: Colors.white,
                ),
              ),
            ),

            title: Text(item.nama),
            subtitle: Text(item.deskripsi),
            trailing: const Icon(Icons.arrow_forward_ios),

            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: item,
              );
            },
          ),
        );
      },
    );
  }
}

// =====================================================
// BAGIAN B
// DETAIL PAGE DENGAN HERO
// =====================================================

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${item.nama}'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: item.nama,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: item.warna,
                  child: Icon(
                    item.ikon,
                    size: 55,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                item.nama,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 12),

              Text(
                item.deskripsi,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// LATIHAN 4
// HALAMAN 404
// =====================================================

class Halaman404 extends StatelessWidget {
  const Halaman404({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tidak Ditemukan'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 90,
              color: Theme.of(context).colorScheme.error,
            ),

            const SizedBox(height: 16),

            Text(
              '404',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge,
            ),

            const SizedBox(height: 8),

            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShellPage(),
                  ),
                      (route) => false,
                );
              },
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// BAGIAN C + LATIHAN 5
// ANIMASI TAB
// =====================================================

class AnimasiTab extends StatefulWidget {
  const AnimasiTab({super.key});

  @override
  State<AnimasiTab> createState() => _AnimasiTabState();
}

class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  // AnimatedContainer
  double ukuran = 100;
  bool berubah = false;

  // AnimatedSwitcher
  bool tampilAngka = true;

  // RotationTransition
  bool sedangBerputar = false;

  late AnimationController controller;
  late Animation<double> animasiPutar;

  // LATIHAN 5: AnimatedOpacity
  bool kartuTerlihat = true;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    animasiPutar = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ===========================================
          // 1. ANIMATED CONTAINER
          // ===========================================

          Text(
            'AnimatedContainer',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: ukuran,
            height: ukuran,
            decoration: BoxDecoration(
              color: berubah
                  ? Colors.orange
                  : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(
                berubah ? 50 : 10,
              ),
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              setState(() {
                berubah = !berubah;
                ukuran = berubah ? 150 : 100;
              });
            },
            child: const Text('Ubah Animasi'),
          ),

          const Divider(height: 40),

          // ===========================================
          // 2. ANIMATED SWITCHER
          // ===========================================

          Text(
            'AnimatedSwitcher',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: tampilAngka
                ? const Text(
              '1',
              key: ValueKey(1),
              style: TextStyle(fontSize: 50),
            )
                : const Icon(
              Icons.star,
              key: ValueKey(2),
              size: 60,
              color: Colors.orange,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              setState(() {
                tampilAngka = !tampilAngka;
              });
            },
            child: const Text('Ganti Widget'),
          ),

          const Divider(height: 40),

          // ===========================================
          // 3. ROTATION TRANSITION
          // ===========================================

          Text(
            'RotationTransition',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          RotationTransition(
            turns: animasiPutar,
            child: Icon(
              Icons.refresh,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              setState(() {
                if (sedangBerputar) {
                  controller.stop();
                  sedangBerputar = false;
                } else {
                  controller.repeat();
                  sedangBerputar = true;
                }
              });
            },
            child: Text(
              sedangBerputar
                  ? 'Hentikan Animasi'
                  : 'Putar Animasi',
            ),
          ),

          const Divider(height: 40),

          // ===========================================
          // 4. LATIHAN MANDIRI: ANIMATED OPACITY
          // ===========================================

          Text(
            'AnimatedOpacity',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            opacity: kartuTerlihat ? 1.0 : 0.0,

            child: Card(
              elevation: 4,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: SizedBox(
                width: double.infinity,
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flutter_dash,
                      size: 45,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Kartu Animasi Flutter',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              setState(() {
                kartuTerlihat = !kartuTerlihat;
              });
            },
            child: Text(
              kartuTerlihat
                  ? 'Sembunyikan Kartu'
                  : 'Tampilkan Kartu',
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
