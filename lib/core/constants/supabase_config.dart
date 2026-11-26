/// Konfigurasi Supabase untuk ChemPedia
/// Nilai default dapat diisi langsung di sini atau diteruskan melalui parameter
/// `flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo-chempedia.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo-anon-key',
  );

  /// Cek apakah kredensial sudah dikonfigurasi nyata oleh pengguna
  static bool get isConfigured =>
      supabaseUrl != 'https://demo-chempedia.supabase.co' &&
      supabaseAnonKey != 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo-anon-key';
}
