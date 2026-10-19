import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

const String baseUrl = 'https://jsonplaceholder.typicode.com';

// Mengambil semua postingan
Future<List<Post>> ambilPostingan() async {
  final uri = Uri.parse('$baseUrl/posts');

  final response = await http
      .get(uri)
      .timeout(const Duration(seconds: 10));

  // Memeriksa status respons API
  if (response.statusCode != 200) {
    throw Exception(
      'Gagal mengambil postingan '
          '(kode ${response.statusCode})',
    );
  }

  // Mengubah JSON menjadi List<Post>
  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map(
        (item) => Post.fromJson(
      item as Map<String, dynamic>,
    ),
  )
      .toList();
}

// Mengambil komentar berdasarkan ID postingan
Future<List<Komentar>> ambilKomentar(int postId) async {
  final uri = Uri.parse('$baseUrl/posts/$postId/comments');

  final response = await http
      .get(uri)
      .timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception(
      'Gagal mengambil komentar '
          '(kode ${response.statusCode})',
    );
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map(
        (item) => Komentar.fromJson(
      item as Map<String, dynamic>,
    ),
  )
      .toList();
}