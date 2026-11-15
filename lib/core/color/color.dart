import 'package:material_ui/material_ui.dart';

class AppColor {
  AppColor._();

  // ── Latar & Surface (Nuansa Ungu Gelap / Dark Seele) ────────────────
  static const Color background = Color(0xFF120C1C);
  static const Color surface = Color(0xFF1A1124);
  static const Color surfaceLight = Color(0xFF261A33);
  static const Color surfaceHighlight = Color(0xFF3A2650);
  static const Color cardBorder = Color(0xFF38254A);

  // ── Aksen Utama: Merah Seele Vollerei ───────────────────────────────
  static const Color lime = Color(0xFFE53935);      // Merah menyala
  static const Color limeDark = Color(0xFFB71C1C);  // Merah gelap (untuk tombol 3D)
  static const Color limeSoft = Color(0xFFFFCDD2);  // Merah pudar

  // ── Aksen Sekunder: Ungu Stigmata ───────────────────────────────────
  static const Color cyan = Color(0xFF9C27B0);      // Ungu
  static const Color cyanDark = Color(0xFF6A1B9A);  // Ungu gelap
  static const Color cyanSoft = Color(0xFFE1BEE7);  // Ungu pudar

  // ── Aksen Tersier: Kuning/Amber (untuk variasi) ─────────────────────
  static const Color amber = Color(0xFFFFB300);     
  static const Color amberDark = Color(0xFFFF8F00);
  static const Color amberSoft = Color(0xFFFFECB3);

  // ── Aksen Khusus: Lavender (Nuansa Seele) ───────────────────────────
  static const Color lavender = Color(0xFFB39DDB);
  static const Color lavenderDark = Color(0xFF7E57C2);
  static const Color lavenderSoft = Color(0xFFD1C4E9);

  // ── Teks ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF7F8FC);
  static const Color textSecondary = Color(0xFFB0A8C0); // Abu-abu keunguan
  static const Color textMuted = Color(0xFF7B6F8A);

  // ── Status ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF68C98A);
  static const Color successDark = Color(0xFF439E63);
  static const Color error = Color(0xFFFF5252);     // Merah error

  // ── Warna Spesifik Kategori Quest ───────────────────────────────────
  static const Color questVideo = lime;       // Merah
  static const Color questGame = cyan;        // Ungu
  static const Color questStream = lavender;  // Lavender
  static const Color questActivity = amber;   // Amber
}