
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================================================
// DATA PRODUK
// =====================================================

class Produk {
  final String id;
  final String nama;
  final String kategori;
  final String deskripsi;
  final String harga;
  final IconData ikon;

  const Produk({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.harga,
    required this.ikon,
  });
}

final List<Produk> daftarProduk = [
  Produk(
    id: '1',
    nama: 'Headphone Wireless',
    kategori: 'Elektronik',
    deskripsi:
    'Headphone wireless dengan kualitas suara jernih, nyaman digunakan, dan memiliki koneksi Bluetooth.',
    harga: 'Rp350.000',
    ikon: Icons.headphones,
  ),
  Produk(
    id: '2',
    nama: 'Smart Watch',
    kategori: 'Aksesoris',
    deskripsi:
    'Jam tangan pintar dengan fitur pemantauan aktivitas, notifikasi, dan tampilan modern.',
    harga: 'Rp550.000',
    ikon: Icons.watch,
  ),
  Produk(
    id: '3',
    nama: 'Camera Digital',
    kategori: 'Elektronik',
    deskripsi:
    'Kamera digital untuk mengabadikan berbagai momen dengan hasil foto yang tajam.',
    harga: 'Rp2.500.000',
    ikon: Icons.camera_alt,
  ),
  Produk(
    id: '4',
    nama: 'Laptop Pro',
    kategori: 'Komputer',
    deskripsi:
    'Laptop dengan performa tinggi untuk kebutuhan belajar, pekerjaan, dan hiburan.',
    harga: 'Rp8.500.000',
    ikon: Icons.laptop,
  ),
  Produk(
    id: '5',
    nama: 'Speaker Bluetooth',
    kategori: 'Audio',
    deskripsi:
    'Speaker portabel dengan suara jernih dan desain praktis untuk digunakan di mana saja.',
    harga: 'Rp275.000',
    ikon: Icons.speaker,
  ),
  Produk(
    id: '6',
    nama: 'Keyboard Mechanical',
    kategori: 'Aksesoris',
    deskripsi:
    'Keyboard mechanical dengan desain ergonomis dan nyaman digunakan untuk mengetik.',
    harga: 'Rp450.000',
    ikon: Icons.keyboard,
  ),
];

// =====================================================
// PENGATURAN TEMA
// =====================================================

final ValueNotifier<ThemeMode> themeMode =
ValueNotifier(ThemeMode.light);

final ValueNotifier<Color> seedColor =
ValueNotifier(Colors.blue);

final Map<String, Color> pilihanWarna = {
  'Biru': Colors.blue,
  'Ungu': Colors.purple,
  'Hijau': Colors.green,
  'Oranye': Colors.orange,
};

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

Future<void> muatPengaturan() async {
  final prefs = await SharedPreferences.getInstance();

  final mode = prefs.getString('themeMode') ?? 'light';

  final warna =
      prefs.getInt('seedColor') ?? Colors.blue.toARGB32();

  themeMode.value =
  mode == 'dark' ? ThemeMode.dark : ThemeMode.light;

  seedColor.value = Color(warna);
}

// =====================================================
// FAVORIT
// =====================================================

final ValueNotifier<Set<String>> daftarFavorit =
ValueNotifier<Set<String>>({});

void ubahFavorit(String id) {
  final favoritBaru = Set<String>.from(daftarFavorit.value);

  if (favoritBaru.contains(id)) {
    favoritBaru.remove(id);
  } else {
    favoritBaru.add(id);
  }

  daftarFavorit.value = favoritBaru;
}

// =====================================================
// MAIN
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
          title: 'Katalog Produk',

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor.value,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor.value,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          themeMode: themeMode.value,

          home: const ShellPage(),

          // ROUTING HALAMAN DETAIL
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final argument = settings.arguments;

              if (argument is Produk) {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      ) {
                    return DetailProdukPage(produk: argument);
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
            }

            return null;
          },

          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const Halaman404(),
            );
          },
        );
      },
    );
  }
}

// =====================================================
// SHELL PAGE
// =====================================================

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int selectedIndex = 0;

  final List<String> judul = [
    'Katalog Produk',
    'Produk Favorit',
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
                  Icon(
                    Icons.shopping_bag,
                    size: 45,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Katalog Produk',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: () {
                Navigator.pop(context);
                pindahTab(0);
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorit'),
              onTap: () {
                Navigator.pop(context);
                pindahTab(1);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                pindahTab(2);
              },
            ),
          ],
        ),
      ),

      body: IndexedStack(
        index: selectedIndex,
        children: const [
          BerandaTab(),
          FavoritTab(),
          PengaturanTab(),
        ],
      ),

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
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
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
// BERANDA TAB
// =====================================================

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PromoBanner(),

        const SizedBox(height: 20),

        Text(
          'Katalog Produk',
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 5),

        Text(
          'Temukan berbagai produk pilihan kami.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 16),

        ...daftarProduk.map(
              (produk) => KartuProduk(
            produk: produk,
            gunakanHero: true,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// PROMO BANNER DENGAN ANIMASI EKSPLISIT
// =====================================================

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang!',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Temukan produk favoritmu di katalog kami.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          RotationTransition(
            turns: controller,
            child: Icon(
              Icons.shopping_bag,
              size: 55,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// KARTU PRODUK
// =====================================================

class KartuProduk extends StatelessWidget {
  final Produk produk;
  final bool gunakanHero;

  const KartuProduk({
    super.key,
    required this.produk,
    this.gunakanHero = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: daftarFavorit,
      builder: (context, favorit, child) {
        final disukai = favorit.contains(produk.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: disukai
                ? Theme.of(context)
                .colorScheme
                .secondaryContainer
                : Theme.of(context).colorScheme.surface,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),

              leading: Hero(
                tag: 'produk-${produk.id}',
                child: Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 65,
                    height: 65,
                    child: Icon(
                      produk.ikon,
                      size: 35,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),

              title: Text(
                produk.nama,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(produk.kategori),
                  const SizedBox(height: 4),
                  Text(
                    produk.harga,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),

              trailing: IconButton(
                onPressed: () {
                  ubahFavorit(produk.id);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    disukai ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(disukai),
                    color: disukai
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: produk,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// =====================================================
// FAVORIT TAB
// =====================================================

class FavoritTab extends StatelessWidget {
  const FavoritTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: daftarFavorit,
      builder: (context, favorit, child) {
        final produkFavorit = daftarProduk
            .where((produk) => favorit.contains(produk.id))
            .toList();

        if (produkFavorit.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 75,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada produk favorit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  'Tekan ikon hati pada produk untuk menambah favorit.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Produk Favorit',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            ...produkFavorit.map(
                  (produk) => KartuProduk(
                produk: produk,
                gunakanHero: false,
              ),
            ),
          ],
        );
      },
    );
  }
}

// =====================================================
// DETAIL PRODUK
// =====================================================

class DetailProdukPage extends StatelessWidget {
  final Produk produk;

  const DetailProdukPage({
    super.key,
    required this.produk,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            Hero(
              tag: 'produk-${produk.id}',
              child: Material(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: 190,
                  height: 190,
                  child: Icon(
                    produk.ikon,
                    size: 110,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              produk.nama,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              produk.kategori,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            Text(
              produk.harga,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Deskripsi Produk',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              produk.deskripsi,
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 30),

            ValueListenableBuilder<Set<String>>(
              valueListenable: daftarFavorit,
              builder: (context, favorit, child) {
                final disukai = favorit.contains(produk.id);

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ubahFavorit(produk.id);
                    },
                    icon: Icon(
                      disukai
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    label: Text(
                      disukai
                          ? 'Hapus dari Favorit'
                          : 'Tambah ke Favorit',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Katalog'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PENGATURAN TAB
// =====================================================

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pengaturan Aplikasi',
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 16),

        Card(
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeMode,
            builder: (context, mode, child) {
              return SwitchListTile(
                title: const Text('Mode Gelap'),
                subtitle: const Text(
                  'Mengubah tampilan aplikasi menjadi gelap',
                ),
                secondary: const Icon(Icons.dark_mode),
                value: mode == ThemeMode.dark,
                onChanged: (value) async {
                  themeMode.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;

                  await simpanPengaturan();
                },
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Pilih Warna Tema',
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 8),

        ...pilihanWarna.entries.map((warna) {
          return ValueListenableBuilder<Color>(
            valueListenable: seedColor,
            builder: (context, selectedColor, child) {
              return RadioListTile<Color>(
                title: Text(warna.key),
                value: warna.value,
                groupValue: selectedColor,
                activeColor: warna.value,
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

        const Divider(height: 30),

        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Tentang Aplikasi'),
          subtitle: const Text('Katalog Produk Digital'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Katalog Produk',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Praktikum Flutter Fundamental',
            );
          },
        ),
      ],
    );
  }
}

// =====================================================
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
              style: Theme.of(context).textTheme.displayLarge,
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
