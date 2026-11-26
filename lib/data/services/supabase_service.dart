import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  bool _initialized = false;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  bool get isReady => _initialized && SupabaseConfig.isConfigured;

  Future<void> initialize() async {
    if (_initialized) return;

    if (!SupabaseConfig.isConfigured) {
      // Masih menggunakan kredensial dummy bawaan
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _initialized = true;
    } catch (e) {
      print('Supabase initialization error: $e');
    }
  }

  SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- QUERY METHODS ---

  Future<List<Map<String, dynamic>>> fetchMaterials({int? grade}) async {
    final cli = client;
    if (cli == null) return [];

    try {
      var query = cli.from('materials').select();
      if (grade != null) {
        query = query.eq('grade', grade);
      }
      final response = await query.order('order_index', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching materials: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchElements() async {
    final cli = client;
    if (cli == null) return [];

    try {
      final response = await cli
          .from('elements')
          .select()
          .order('atomic_number', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching elements: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchGlossary() async {
    final cli = client;
    if (cli == null) return [];

    try {
      final response =
          await cli.from('glossary').select().order('term', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching glossary: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    final cli = client;
    if (cli == null) return [];

    try {
      final response = await cli.from('quizzes').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quizzes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuizQuestions(String quizId) async {
    final cli = client;
    if (cli == null) return [];

    try {
      final response = await cli
          .from('quiz_questions')
          .select()
          .eq('quiz_id', quizId)
          .order('order_index', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quiz questions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDailyFacts() async {
    final cli = client;
    if (cli == null) return [];

    try {
      final response = await cli
          .from('daily_facts')
          .select()
          .order('publish_date', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching daily facts: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchWeeklyMysteries() async {
    final cli = client;
    if (cli == null) return [];

    try {
      final response = await cli
          .from('weekly_mysteries')
          .select()
          .order('week_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching weekly mysteries: $e');
      return [];
    }
  }
}
