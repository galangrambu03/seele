
import 'package:http/http.dart' as http;

/// Port dari fetch_latest_build_number() di Velocity X.
/// Mengambil client_build_number terbaru dari discord.com/app.
/// Fallback ke 504649 kalau gagal.
class BuildNumberFetcher {
  static const int fallback = 504649;

  static Future<int> fetchLatest({http.Client? client}) async {
    final c = client ?? http.Client();
    try {
      const ua =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36';
      final page = await c.get(
        Uri.parse('https://discord.com/app'),
        headers: {'User-Agent': ua},
      );
      if (page.statusCode != 200) return fallback;

      final scripts =
          RegExp(r'/assets/([a-f0-9]+)\.js').allMatches(page.body).map(
                (m) => m.group(1)!,
              );
      final hashes = scripts.toList();
      if (hashes.isEmpty) return fallback;

      for (final hash in hashes.reversed.take(5)) {
        try {
          final asset = await c.get(
            Uri.parse('https://discord.com/assets/$hash.js'),
            headers: {'User-Agent': ua},
          );
          final match = RegExp(r'buildNumber["\s:]+["\s]*(\d{5,7})')
              .firstMatch(asset.body);
          if (match != null) {
            return int.parse(match.group(1)!);
          }
        } catch (_) {
          // coba hash berikutnya
        }
      }
      return fallback;
    } catch (_) {
      return fallback;
    } finally {
      if (client == null) c.close();
    }
  }
}