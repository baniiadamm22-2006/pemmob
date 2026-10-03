import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 1',
      home: const CounterPage(),       //BAGIAN F
    );
  }
}
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}
class _CounterPageState extends State<CounterPage> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Hello Bani',
            style: TextStyle(
            fontSize: 24,
            color: Colors.white
        ),
      ),
        backgroundColor: Colors.green,       //1. Ubah warna AppBar
      ),
      body: Center( //BAGIAN E
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flutter_dash, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Halo, nama saya BANI ADAM!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.green //1. Ubah warna teks
              ),
            ),
            const Text(
                'NIM: 20240801100',
              style: TextStyle(
              fontSize: 24,
              color: Colors.green //1. Ubah warna teks
            ),
            ),
            const SizedBox(height: 16),
            Text('$_count', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (_count > 0) { //4. Cegah angka menjadi negatif
                        _count--;
                      }
                    });
                  },
                  child: const Icon(Icons.remove),//2. Tombol mengurangi angka
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _count = 0;//3. Tombol reset
                    });
                  },
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () => setState(() => _count++),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}