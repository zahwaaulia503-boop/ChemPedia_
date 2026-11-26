import '../models/material_model.dart';
import '../models/element_model.dart';
import '../models/glossary_model.dart';
import '../models/quiz_model.dart';
import '../models/extra_models.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';

class AppRepository {
  final LocalStorageService _storage;
  final SupabaseService _supabase = SupabaseService.instance;

  AppRepository(this._storage);

  // --- MATERI (MATERIALS) ---
  Future<List<MaterialModel>> getMaterials({int? grade}) async {
    // 1. Coba ambil dari Supabase jika terhubung
    if (_supabase.isReady) {
      final rawList = await _supabase.fetchMaterials(grade: grade);
      if (rawList.isNotEmpty) {
        await _storage.cacheData(_storage.keyMaterials, rawList);
        return rawList.map((m) => MaterialModel.fromJson(m)).toList();
      }
    }

    // 2. Ambil dari Cache Lokal
    final cached = _storage.getCachedData(_storage.keyMaterials);
    if (cached != null && cached is List && cached.isNotEmpty) {
      final list = cached.map((m) => MaterialModel.fromJson(m)).toList();
      if (grade != null) {
        return list.where((m) => m.grade == grade).toList();
      }
      return list;
    }

    // 3. Fallback Data Awal (Offline Seed)
    final initialList = _initialMaterials();
    if (grade != null) {
      return initialList.where((m) => m.grade == grade).toList();
    }
    return initialList;
  }

  Future<MaterialModel?> getMaterialById(String id) async {
    final all = await getMaterials();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- UNSUR PERIODIK (ELEMENTS) ---
  Future<List<ElementModel>> getElements() async {
    if (_supabase.isReady) {
      final rawList = await _supabase.fetchElements();
      if (rawList.isNotEmpty) {
        await _storage.cacheData(_storage.keyElements, rawList);
        return rawList.map((e) => ElementModel.fromJson(e)).toList();
      }
    }

    final cached = _storage.getCachedData(_storage.keyElements);
    if (cached != null && cached is List && cached.isNotEmpty) {
      return cached.map((e) => ElementModel.fromJson(e)).toList();
    }

    return _initialElements();
  }

  // --- GLOSARIUM A-Z ---
  Future<List<GlossaryModel>> getGlossary() async {
    if (_supabase.isReady) {
      final rawList = await _supabase.fetchGlossary();
      if (rawList.isNotEmpty) {
        await _storage.cacheData(_storage.keyGlossary, rawList);
        return rawList.map((g) => GlossaryModel.fromJson(g)).toList();
      }
    }

    final cached = _storage.getCachedData(_storage.keyGlossary);
    if (cached != null && cached is List && cached.isNotEmpty) {
      return cached.map((g) => GlossaryModel.fromJson(g)).toList();
    }

    return _initialGlossary();
  }

  // --- KUIS & SOAL LATIHAN ---
  Future<List<QuizModel>> getQuizzes() async {
    if (_supabase.isReady) {
      final rawQuizzes = await _supabase.fetchQuizzes();
      if (rawQuizzes.isNotEmpty) {
        final List<QuizModel> fullQuizzes = [];
        for (var q in rawQuizzes) {
          final qId = q['id'].toString();
          final rawQuestions = await _supabase.fetchQuizQuestions(qId);
          final questions = rawQuestions.map((ques) => QuizQuestionModel.fromJson(ques)).toList();
          fullQuizzes.add(QuizModel.fromJson(q, questions: questions));
        }
        return fullQuizzes;
      }
    }

    return _initialQuizzes();
  }

  Future<QuizModel?> getQuizByMaterialId(String materialId) async {
    final quizzes = await getQuizzes();
    try {
      return quizzes.firstWhere((q) => q.materialId == materialId);
    } catch (_) {
      return null;
    }
  }

  // --- FAKTA HARIAN (TAHUKAH KAMU?) ---
  Future<List<DailyFactModel>> getDailyFacts() async {
    if (_supabase.isReady) {
      final rawList = await _supabase.fetchDailyFacts();
      if (rawList.isNotEmpty) {
        await _storage.cacheData(_storage.keyDailyFacts, rawList);
        return rawList.map((f) => DailyFactModel.fromJson(f)).toList();
      }
    }

    final cached = _storage.getCachedData(_storage.keyDailyFacts);
    if (cached != null && cached is List && cached.isNotEmpty) {
      return cached.map((f) => DailyFactModel.fromJson(f)).toList();
    }

    return _initialDailyFacts();
  }

  // --- MISTERI KIMIA MINGGUAN ---
  Future<List<WeeklyMysteryModel>> getWeeklyMysteries() async {
    if (_supabase.isReady) {
      final rawList = await _supabase.fetchWeeklyMysteries();
      if (rawList.isNotEmpty) {
        await _storage.cacheData(_storage.keyMysteries, rawList);
        return rawList.map((w) => WeeklyMysteryModel.fromJson(w)).toList();
      }
    }

    final cached = _storage.getCachedData(_storage.keyMysteries);
    if (cached != null && cached is List && cached.isNotEmpty) {
      return cached.map((w) => WeeklyMysteryModel.fromJson(w)).toList();
    }

    return _initialWeeklyMysteries();
  }

  // ==========================================================================
  // INITIAL OFFLINE SEED DATA (AUTHENTIC & COMPREHENSIVE)
  // ==========================================================================

  List<MaterialModel> _initialMaterials() {
    return [
      const MaterialModel(
        id: 'mat_10_1',
        grade: 10,
        chapterTitle: 'Struktur Atom & Nanoteknologi',
        topicName: 'Perkembangan Model Atom & Partikel Subatom',
        summary: 'Atom tersusun atas proton (+), neutron (netral), dan elektron (-). Perkembangan atom berlanjut dari teori bola pejal Dalton hingga teori mekanika kuantum modern.',
        contentBody: 'Atom merupakan fondasi dasar penyusun segala benda di jagat raya. Inti atom yang tersusun atas proton dan neutron bermuatan positif dilingkupi oleh elektron pada tingkat energi tertentu.\n\nDalam kurikulum merdeka, pemahaman struktur atom dikaitkan erat dengan nanoteknologi (rekayasa materi pada ukuran 1–100 nanometer). Saat ukuran partikel diperkecil menjadi nanometer, rasio luas permukaan meningkat drastis sehingga reaktivitas kimianya berlipat ganda.',
        chemicalReactions: [
          'Nomor Massa (A) = Proton (Z) + Neutron (N)',
          'Konfigurasi Kulit Bohr: 2n²',
        ],
        realWorldApplication: 'Pembuatan krim tabir surya transparan berbasis nanopartikel seng oksida (ZnO) dan titanium dioksida (TiO2) yang melindungi kulit secara optimal dari sinar ultraviolet tanpa rasa lengket.',
        illustrationUrl: 'atom',
        orderIndex: 1,
      ),
      const MaterialModel(
        id: 'mat_10_2',
        grade: 10,
        chapterTitle: 'Hukum Dasar Kimia & Stoikiometri',
        topicName: 'Hukum Kekekalan Massa & Konsep Mol',
        summary: 'Massa zat sebelum dan sesudah reaksi kimia dalam sistem tertutup bernilai konstan (Hukum Lavoisier). Mol adalah jembatan hitungan partikel dan massa.',
        contentBody: 'Antoine Lavoisier membuktikan bahwa tidak ada materi yang hilang dalam reaksi kimia tertutup, melainkan hanya bertransformasi membentuk ikatan baru.\n\nKonsep Mol:\n1 mol zat = 6,022 × 10²³ partikel (Tetapan Avogadro)\nJumlah Mol (n) = Massa (gram) / Massa Molar (Mr atau Ar)',
        chemicalReactions: [
          'Massa Reaktan = Massa Produk',
          '2H2 + O2 → 2H2O',
          'n = m / Mr',
        ],
        realWorldApplication: 'Perhitungan stoikiometri pengembang kantung udara mobil (airbag). Reaksi natrium azida (NaN3) dihitung presisi agar menghasilkan gas nitrogen (N2) dalam volume pas dalam 30 milidetik saat benturan keras.',
        illustrationUrl: 'stoichiometry',
        orderIndex: 2,
      ),
      const MaterialModel(
        id: 'mat_11_1',
        grade: 11,
        chapterTitle: 'Termokimia',
        topicName: 'Perubahan Entalpi & Reaksi Eksoterm/Endoterm',
        summary: 'Termokimia mempelajari pertukaran kalor reaksi kimia. Reaksi eksoterm membebaskan kalor (ΔH < 0), reaksi endoterm menyerap kalor (ΔH > 0).',
        contentBody: 'Entalpi (H) adalah jumlah seluruh energi kimia yang tersimpan dalam suatu sistem. Perubahan entalpi (ΔH) adalah selisih antara entalpi produk dan entalpi reaktan.\n\nReaksi Eksoterm:\nKalor mengalir keluar dari sistem ke lingkungan sehingga suhu sekitar naik. Contoh: Pembakaran gas elpiji dan kapur tohor dengan air.\n\nReaksi Endoterm:\nKalor diserap oleh sistem dari lingkungan, suhu sekitar turun. Contoh: Pelarutan pupuk urea atau amonium nitrat dalam air.',
        chemicalReactions: [
          'q = m × c × ΔT',
          'ΔH = H_produk - H_reaktan',
          'C3H8 + 5O2 → 3CO2 + 4H2O   ΔH = -2220 kJ/mol',
        ],
        realWorldApplication: 'Kantung kompres dingin instan (cold pack) untuk cedera sendi atletik memanfaatkan reaksi endoterm pelarutan NH4NO3 dalam air untuk meredakan nyeri tanpa perlu lemari es.',
        illustrationUrl: 'thermochemistry',
        orderIndex: 3,
      ),
      const MaterialModel(
        id: 'mat_11_2',
        grade: 11,
        chapterTitle: 'Laju Reaksi & Katalis',
        topicName: 'Faktor-Faktor Laju Reaksi & Teori Tumbukan',
        summary: 'Laju reaksi dipengaruhi konsentrasi, luas permukaan, suhu, dan katalis. Katalis mempercepat reaksi dengan menurunkan energi aktivasi.',
        contentBody: 'Teori tumbukan menjelaskan bahwa partikel harus bertumbukan dengan orientasi yang tepat dan energi yang melampaui energi aktivasi (Ea) agar menghasilkan reaksi kimia.\n\nKatalisator adalah zat yang dapat mempercepat jalannya reaksi kimia dengan menyediakan jalur reaksi alternatif berenergi aktivasi lebih rendah, tanpa terkonsumsi secara permanen.',
        chemicalReactions: [
          'v = k [A]ˣ [B]ʸ',
          'Ea(dengan katalis) < Ea(tanpa katalis)',
        ],
        realWorldApplication: 'Konverter katalitik pada knalpot kendaraan bermotor menggunakan platina dan paladium untuk mengubah gas beracun CO dan NOx menjadi gas CO2 dan N2 yang ramah lingkungan.',
        illustrationUrl: 'reaction_rate',
        orderIndex: 4,
      ),
      const MaterialModel(
        id: 'mat_12_1',
        grade: 12,
        chapterTitle: 'Larutan Asam Basa & pH',
        topicName: 'Teori Asam Basa & Derajat Keasaman',
        summary: 'Asam melepas H+ dan basa melepas OH-. Derajat keasaman diukur dalam skala pH (0-14). Larutan penyangga (buffer) menstabilkan pH.',
        contentBody: 'Teori Arrhenius, Bronsted-Lowry, dan Lewis memberikan sudut pandang komprehensif mengenai reaksi asam-basa. pH merupakan logaritma negatif konsentrasi ion hidrogen: pH = -log[H+].\n\nLarutan penyangga (buffer) tersusun atas asam lemah dan basa konjugasinya yang mampu meredam goncangan pH dari penambahan asam atau basa luar.',
        chemicalReactions: [
          'pH = -log[H+]',
          'pH + pOH = 14',
          'HCl + NaOH → NaCl + H2O',
        ],
        realWorldApplication: 'Darah manusia memiliki sistem penyangga bikarbonat (H2CO3 / HCO3-) yang menjaga pH darah selalu aman di angka 7,35 - 7,45 untuk kelangsungan metabolisme tubuh.',
        illustrationUrl: 'acid_base',
        orderIndex: 5,
      ),
      const MaterialModel(
        id: 'mat_12_2',
        grade: 12,
        chapterTitle: 'Reaksi Redoks & Sel Elektrokimia',
        topicName: 'Sel Volta & Baterai Modern',
        summary: 'Reaksi redoks melibatkan perpindahan elektron. Sel Volta mengubah energi kimia menjadi arus listrik spontan (baterai & aki).',
        contentBody: 'Oksidasi adalah pelepasan elektron (kenaikan bilangan oksidasi), sedangkan reduksi adalah pengikatan elektron (penurunan bilangan oksidasi).\n\nPada Sel Volta:\nAnoda (Kutub Negatif) = Tempat oksidasi\nKatoda (Kutub Positif) = Tempat reduksi\nArus listrik mengalir spontan menghasilkan gaya gerak listrik (E°sel).',
        chemicalReactions: [
          'E°sel = E°katoda - E°anoda',
          'Anoda (Oksidasi): Zn → Zn²⁺ + 2e⁻',
          'Katoda (Reduksi): Cu²⁺ + 2e⁻ → Cu',
        ],
        realWorldApplication: 'Baterai Lithium-ion pada smartphone dan mobil listrik bekerja berdasarkan aliran interkalasi ion Li+ antara anoda grafit dan katoda kobalt oksida secara berulang saat diisi ulang.',
        illustrationUrl: 'electrochemistry',
        orderIndex: 6,
      ),
    ];
  }

  List<ElementModel> _initialElements() {
    return [
      const ElementModel(
        atomicNumber: 1,
        symbol: 'H',
        nameId: 'Hidrogen',
        nameLatin: 'Hydrogenium',
        relativeAtomicMass: 1.008,
        groupNumber: 1,
        periodNumber: 1,
        block: 's',
        category: 'Nonlogam',
        electronConfiguration: '1s¹',
        stateAtRoomTemp: 'Gas',
        funFactsAndUses: 'Unsur paling melimpah di jagat raya (75% massa alam semesta). Digunakan sebagai bahan bakar propelan roket dan bahan bakar bersih masa depan.',
        colorHex: '#42A5F5',
      ),
      const ElementModel(
        atomicNumber: 2,
        symbol: 'He',
        nameId: 'Helium',
        nameLatin: 'Helium',
        relativeAtomicMass: 4.003,
        groupNumber: 18,
        periodNumber: 1,
        block: 's',
        category: 'Gas Mulia',
        electronConfiguration: '1s²',
        stateAtRoomTemp: 'Gas',
        funFactsAndUses: 'Gas tidak berwarna dan tidak mudah terbakar. Digunakan untuk pendingin magnet superkonduktor pada pemindai medis MRI rumah sakit.',
        colorHex: '#AB47BC',
      ),
      const ElementModel(
        atomicNumber: 3,
        symbol: 'Li',
        nameId: 'Litium',
        nameLatin: 'Lithium',
        relativeAtomicMass: 6.941,
        groupNumber: 1,
        periodNumber: 2,
        block: 's',
        category: 'Logam Alkali',
        electronConfiguration: '[He] 2s¹',
        stateAtRoomTemp: 'Padat',
        funFactsAndUses: 'Logam paling ringan dengan densitas separuh air. Menjadi jantung revolusi baterai gadget dan kendaraan listrik ramah lingkungan.',
        colorHex: '#EF5350',
      ),
      const ElementModel(
        atomicNumber: 6,
        symbol: 'C',
        nameId: 'Karbon',
        nameLatin: 'Carbonium',
        relativeAtomicMass: 12.011,
        groupNumber: 14,
        periodNumber: 2,
        block: 'p',
        category: 'Nonlogam',
        electronConfiguration: '[He] 2s² 2p²',
        stateAtRoomTemp: 'Padat',
        funFactsAndUses: 'Tulang punggung kimia organik. Memiliki bentuk alotropi ajaib dari arang hitam rapuh hingga intan berkilau yang teramat keras.',
        colorHex: '#78909C',
      ),
      const ElementModel(
        atomicNumber: 7,
        symbol: 'N',
        nameId: 'Nitrogen',
        nameLatin: 'Nitrogenium',
        relativeAtomicMass: 14.007,
        groupNumber: 15,
        periodNumber: 2,
        block: 'p',
        category: 'Nonlogam',
        electronConfiguration: '[He] 2s² 2p³',
        stateAtRoomTemp: 'Gas',
        funFactsAndUses: 'Menyusun 78% atmosfer bumi. Diperlukan untuk sintesis protein tumbuhan melalui industri pupuk urea (Haber-Bosch).',
        colorHex: '#26A69A',
      ),
      const ElementModel(
        atomicNumber: 8,
        symbol: 'O',
        nameId: 'Oksigen',
        nameLatin: 'Oxygenium',
        relativeAtomicMass: 15.999,
        groupNumber: 16,
        periodNumber: 2,
        block: 'p',
        category: 'Nonlogam',
        electronConfiguration: '[He] 2s² 2p⁴',
        stateAtRoomTemp: 'Gas',
        funFactsAndUses: 'Kunci respirasi seluler makhluk hidup dan pembakaran api. Dalam bentuk O3 membentuk lapisan ozon pelindung bumi.',
        colorHex: '#29B6F6',
      ),
      const ElementModel(
        atomicNumber: 11,
        symbol: 'Na',
        nameId: 'Natrium',
        nameLatin: 'Natrium',
        relativeAtomicMass: 22.990,
        groupNumber: 1,
        periodNumber: 3,
        block: 's',
        category: 'Logam Alkali',
        electronConfiguration: '[Ne] 3s¹',
        stateAtRoomTemp: 'Padat',
        funFactsAndUses: 'Logam sangat lunak yang dapat diiris pisau dan meledak jika dimasukkan air. Senyawanya membentuk garam dapur NaCl yang kita konsumsi tiap hari.',
        colorHex: '#FFA726',
      ),
      const ElementModel(
        atomicNumber: 12,
        symbol: 'Mg',
        nameId: 'Magnesium',
        nameLatin: 'Magnesium',
        relativeAtomicMass: 24.305,
        groupNumber: 2,
        periodNumber: 3,
        block: 's',
        category: 'Logam Alkali Tanah',
        electronConfiguration: '[Ne] 3s²',
        stateAtRoomTemp: 'Padat',
        funFactsAndUses: 'Pusat molekul klorofil pada daun hijau yang menyerap energi foton matahari untuk fotosintesis tumbuhan bumi.',
        colorHex: '#66BB6A',
      ),
      const ElementModel(
        atomicNumber: 17,
        symbol: 'Cl',
        nameId: 'Klorin',
        nameLatin: 'Chlorum',
        relativeAtomicMass: 35.453,
        groupNumber: 17,
        periodNumber: 3,
        block: 'p',
        category: 'Halogen',
        electronConfiguration: '[Ne] 3s² 3p⁵',
        stateAtRoomTemp: 'Gas',
        funFactsAndUses: 'Gas halogen berbau tajam. Digunakan dalam kaporit pembersih kolam renang dan bahan baku plastik PVC pipa air.',
        colorHex: '#9CCC65',
      ),
      const ElementModel(
        atomicNumber: 20,
        symbol: 'Ca',
        nameId: 'Kalsium',
        nameLatin: 'Calcium',
        relativeAtomicMass: 40.078,
        groupNumber: 2,
        periodNumber: 4,
        block: 's',
        category: 'Logam Alkali Tanah',
        electronConfiguration: '[Ar] 4s²',
        stateAtRoomTemp: 'Padat',
        funFactsAndUses: 'Penyusun utama struktur tulang dan gigi makhluk hidup. Juga merupakan mineral pembentuk semen cor beton dan batu kapur gunung.',
        colorHex: '#8D6E63',
      ),
      const ElementModel(
        atomicNumber: 26,
        symbol: 'Fe',
        nameId: 'Besi',
        nameLatin: 'Ferrum',
        relativeAtomicMass: 55.845,
        groupNumber: 8,
        periodNumber: 4,
        block: 'd',
        category: 'Logam Transisi',
        electronConfiguration: '[Ar] 3d⁶ 4s²',
        stateAtRoomTemp: 'Padat',
        funFactsAndUses: 'Logam paling banyak dimanfaatkan di dunia untuk baja gedung & jembatan. Mengikat oksigen dalam sel darah merah kita.',
        colorHex: '#7E57C2',
      ),
      const ElementModel(
        atomicNumber: 29,
        symbol: 'Cu',
        nameId: 'Tembaga',
        nameLatin: 'Cuprum',
        relativeAtomicMass: 63.546,
        groupNumber: 11,
        periodNumber: 4,
        block: 'd',
        category: 'Logam Transisi',
        electronConfiguration: '[Ar] 3d¹⁰ 4s¹',
        stateAtRoomTemp: 'Padat',
        funFactsAndUses: 'Konduktor listrik jempolan dengan warna coklat kemerahan khas. Menjadi urat nadi kabel listrik dan komponen mikroprosesor.',
        colorHex: '#FF7043',
      ),
      const ElementModel(
        atomicNumber: 79,
        symbol: 'Au',
        nameId: 'Emas',
        nameLatin: 'Aurum',
        relativeAtomicMass: 196.967,
        groupNumber: 11,
        periodNumber: 6,
        block: 'd',
        category: 'Logam Transisi',
        electronConfiguration: '[Xe] 4f¹⁴ 5d¹⁰ 6s¹',
        stateAtRoomTemp: 'Padat',
        funFactsAndUses: 'Logam mulia yang tidak akan pernah berkarat sepanjang masa. Digunakan sebagai perhiasan abadi dan pelapis konektor satelit angkasa.',
        colorHex: '#FFD54F',
      ),
    ];
  }

  List<GlossaryModel> _initialGlossary() {
    return [
      const GlossaryModel(id: 'g1', term: 'Allotrop', letter: 'A', definition: 'Bentuk modifikasi struktur kristal yang berbeda dari unsur kimia yang sama pada wujud zat yang sama (contoh: intan dan grafit adalah alotrop karbon).', relatedChapter: 'Struktur Atom'),
      const GlossaryModel(id: 'g2', term: 'Asam Konjugasi', letter: 'A', definition: 'Spesi molekul atau ion yang terbentuk ketika suatu basa menerima satu ion hidrogen (proton H+).', relatedChapter: 'Asam Basa'),
      const GlossaryModel(id: 'g3', term: 'Bilangan Avogadro', letter: 'B', definition: 'Konstanta numerik 6,022 × 10²³ yang menyatakan kuantitas partikel di dalam tepat satu mol zat.', relatedChapter: 'Stoikiometri'),
      const GlossaryModel(id: 'g4', term: 'Buffer (Larutan Penyangga)', letter: 'B', definition: 'Campuran larutan yang sanggup menahan fluktuasi nilai pH ketika ditambah sedikit asam atau basa.', relatedChapter: 'Asam Basa'),
      const GlossaryModel(id: 'g5', term: 'Derajat Ionisasi', letter: 'D', definition: 'Perbandingan fraksional antara kuantitas molekul zat yang terurai menjadi ion terhadap kuantitas zat mula-mula.', relatedChapter: 'Larutan Asam Basa'),
      const GlossaryModel(id: 'g6', term: 'Elektrolit', letter: 'E', definition: 'Zat terlarut yang membebaskan ion-ion bermuatan sehingga larutannya sanggup menghantarkan arus listrik.', relatedChapter: 'Elektrokimia'),
      const GlossaryModel(id: 'g7', term: 'Entalpi (H)', letter: 'E', definition: 'Fungsi keadaan termodinamika yang mewakili jumlah total energi potensial dan kinetik suatu zat pada tekanan tetap.', relatedChapter: 'Termokimia'),
      const GlossaryModel(id: 'g8', term: 'Hukum Hess', letter: 'H', definition: 'Kaidah termokimia yang menyatakan perubahan entalpi reaksi kimia murni tergantung titik awal dan akhir, bukan jalannya lintasan tahapan.', relatedChapter: 'Termokimia'),
      const GlossaryModel(id: 'g9', term: 'Isotop', letter: 'I', definition: 'Kelompok atom berunsur sama (nomor atom sama) yang memiliki nomor massa berbeda akibat variasi kuantitas neutron di inti.', relatedChapter: 'Struktur Atom'),
      const GlossaryModel(id: 'g10', term: 'Katalis', letter: 'K', definition: 'Zat penolong yang melipatgandakan laju reaksi kimia dengan memangkas energi aktivasi tanpa terkonsumsi habis.', relatedChapter: 'Laju Reaksi'),
      const GlossaryModel(id: 'g11', term: 'Mol', letter: 'M', definition: 'Satuan standar internasional (SI) untuk mengukur jumlah zat kimiawi berdasarkan jumlah atom dalam 12 gram Karbon-12.', relatedChapter: 'Stoikiometri'),
      const GlossaryModel(id: 'g12', term: 'Oksidator', letter: 'O', definition: 'Spesi zat yang mengalami reaksi reduksi dengan cara menarik elektron dan mengoksidasi spesi lawan reaksinya.', relatedChapter: 'Reaksi Redoks'),
      const GlossaryModel(id: 'g13', term: 'pH', letter: 'P', definition: 'Skala logaritma negatif konsentrasi ion hidrogen [H+] untuk mengukur derajat keasaman larutan dari rentang 0 hingga 14.', relatedChapter: 'Asam Basa'),
      const GlossaryModel(id: 'g14', term: 'Reduktor', letter: 'R', definition: 'Spesi zat yang mendonasikan elektron (teroksidasi) sehingga mereduksi spesi pereaksi pasangannya.', relatedChapter: 'Reaksi Redoks'),
      const GlossaryModel(id: 'g15', term: 'Titrasi', letter: 'T', definition: 'Metode analisis volumetri kuantitatif di laboratorium untuk menetapkan konsentrasi larutan analit menggunakan larutan titran terstandar.', relatedChapter: 'Asam Basa'),
    ];
  }

  List<QuizModel> _initialQuizzes() {
    return [
      const QuizModel(
        id: 'quiz_1',
        materialId: 'mat_10_1',
        title: 'Kuis Evaluasi: Struktur Atom & Nanoteknologi',
        questions: [
          QuizQuestionModel(
            id: 'q1_1',
            quizId: 'quiz_1',
            questionText: 'Partikel subatom yang bermuatan positif dan berdiam di dalam inti atom adalah...',
            optionA: 'Elektron',
            optionB: 'Proton',
            optionC: 'Neutron',
            optionD: 'Foton',
            correctOption: 'B',
            explanation: 'Proton bermuatan positif (+1) dan bertempat tinggal di nukleus bersama neutron yang netral, sedangkan elektron mengelilingi inti.',
            orderIndex: 1,
          ),
          QuizQuestionModel(
            id: 'q1_2',
            quizId: 'quiz_1',
            questionText: 'Rentang ukuran partikel yang diklasifikasikan sebagai skala nanomaterial dalam sains adalah...',
            optionA: '1 - 100 mikrometer',
            optionB: '1 - 100 nanometer',
            optionC: '100 - 1000 nanometer',
            optionD: '1 - 10 milimeter',
            correctOption: 'B',
            explanation: 'Skala nano secara internasional disepakati berada pada rentang 1 hingga 100 nanometer (10⁻⁹ meter).',
            orderIndex: 2,
          ),
          QuizQuestionModel(
            id: 'q1_3',
            quizId: 'quiz_1',
            questionText: 'Atom Natrium (Na) bernomor atom 11 dan nomor massa 23. Berapakah jumlah neutron di dalam intinya?',
            optionA: '11',
            optionB: '12',
            optionC: '23',
            optionD: '34',
            correctOption: 'B',
            explanation: 'Neutron dihitung dengan: Nomor Massa (A) - Nomor Atom (Z) = 23 - 11 = 12.',
            orderIndex: 3,
          ),
        ],
      ),
      const QuizModel(
        id: 'quiz_2',
        materialId: 'mat_11_1',
        title: 'Kuis Evaluasi: Termokimia & Energi Reaksi',
        questions: [
          QuizQuestionModel(
            id: 'q2_1',
            quizId: 'quiz_2',
            questionText: 'Manakah pernyataan yang paling tepat mendeskripsikan reaksi eksoterm?',
            optionA: 'Menyerap kalor dan ΔH bertanda positif',
            optionB: 'Melepas kalor ke lingkungan dan ΔH bertanda negatif',
            optionC: 'Suhu lingkungan mengalami penurunan dingin',
            optionD: 'Tidak melibatkan perpindahan energi kalor',
            correctOption: 'B',
            explanation: 'Reaksi eksoterm mengalirkan kalor ke lingkungan sekitar (suhu lingkungan naik) dan nilai perubahan entalpinya (ΔH) bernilai negatif.',
            orderIndex: 1,
          ),
          QuizQuestionModel(
            id: 'q2_2',
            quizId: 'quiz_2',
            questionText: 'Penerapan konsep reaksi endoterm dalam perlengkapan medis dan olahraga dapat dijumpai pada...',
            optionA: 'Kantung kompres dingin instan (cold pack)',
            optionB: 'Bahan bakar kompor gas berkemah',
            optionC: 'Lilin parafin aromaterapi',
            optionD: 'Korek api kayu saat digesek',
            correctOption: 'A',
            explanation: 'Cold pack menyerap panas dari bagian tubuh yang cedera melalui reaksi pelarutan amonium nitrat dalam air yang bersifat endoterm.',
            orderIndex: 2,
          ),
        ],
      ),
      const QuizModel(
        id: 'quiz_3',
        materialId: 'mat_12_1',
        title: 'Kuis Evaluasi: Asam Basa & Penyangga',
        questions: [
          QuizQuestionModel(
            id: 'q3_1',
            quizId: 'quiz_3',
            questionText: 'Suatu larutan asam kuat memiliki konsentrasi ion H⁺ sebesar 0,001 M (10⁻³ M). Berapakah nilai pH larutan tersebut?',
            optionA: '1',
            optionB: '3',
            optionC: '7',
            optionD: '11',
            correctOption: 'B',
            explanation: 'pH = -log[H⁺] = -log(10⁻³) = 3.',
            orderIndex: 1,
          ),
          QuizQuestionModel(
            id: 'q3_2',
            quizId: 'quiz_3',
            questionText: 'Sistem penyangga biologis utama yang mengontrol agar pH darah manusia tetap aman pada 7,35 - 7,45 adalah...',
            optionA: 'HCl dan NaCl',
            optionB: 'H2CO3 dan HCO3⁻',
            optionC: 'CH3COOH dan CH3COONa',
            optionD: 'NH3 dan NH4Cl',
            correctOption: 'B',
            explanation: 'Sistem penyangga karbonat (H₂CO₃ / HCO₃⁻) merupakan benteng utama tubuh untuk mencegah asidosis atau alkalosis darah.',
            orderIndex: 2,
          ),
        ],
      ),
    ];
  }

  List<DailyFactModel> _initialDailyFacts() {
    return [
      const DailyFactModel(
        id: 'df_1',
        publishDate: '2026-11-24',
        title: 'Mengapa Mengiris Bawang Memicu Air Mata?',
        factDescription: 'Ketika pisau membelah sel bawang, enzim memecah asam amino sulfoksida menghasilkan gas Syn-propanethial-S-oxide. Saat uap gas ini menyentuh cairan bola mata, terbentuk asam sulfat sangat encer yang memicu kelenjar air mata refleks membanjiri mata untuk membilasnya.',
        tag: 'Kimia Dapur',
        iconName: 'water_drop',
      ),
      const DailyFactModel(
        id: 'df_2',
        publishDate: '2026-11-23',
        title: 'Kaca Bukan Benda Padat Biasa!',
        factDescription: 'Kaca diklasifikasikan sebagai cairan superdingin atau zat padat amorf (amorphous solid). Molekul silika di dalamnya tersusun acak tanpa pola kisi kristal teratur seperti halnya garam meja atau logam padat.',
        tag: 'Material Kimia',
        iconName: 'science',
      ),
      const DailyFactModel(
        id: 'df_3',
        publishDate: '2026-11-22',
        title: 'Dari Mana Asal Warna-Warni Kembang Api?',
        factDescription: 'Warna spektakuler kembang api berasal dari emisi atom logam saat dipanaskan suhu tinggi. Stronsium memancarkan cahaya merah rubi, Tembaga memancarkan biru laut, Barium menghasilkan hijau emerald, dan Natrium memancarkan kuning emas cerah!',
        tag: 'Kimia Spektroskopi',
        iconName: 'auto_awesome',
      ),
    ];
  }

  List<WeeklyMysteryModel> _initialWeeklyMysteries() {
    return [
      const WeeklyMysteryModel(
        id: 'wm_1',
        title: 'Misteri Api Biru Kawah Ijen: Fenomena Langka Dunia',
        storyContent: 'Di puncak Gunung Ijen, Jawa Timur, terdapat salah satu dari dua fenomena api biru abadi di planet bumi.\n\nSecara kimiawi, nyala biru elektrik ini bukan lava gunung berapi, melainkan semburan gas belerang murni (elemental sulfur) bertekanan luar biasa tinggi yang menyelinap dari celah rekahan bumi pada suhu 600°C.\n\nSaat gas belerang bertemu oksigen di udara terbuka, terjadi pembakaran spontan dengan energi radiasi gelombang cahaya biru khas pembakaran sulfur murni.',
        imageUrl: 'blue_fire',
        coinCost: 50,
        weekDate: '2026-11-24',
      ),
      const WeeklyMysteryModel(
        id: 'wm_2',
        title: 'Kaca Gurun Libya: Ledakan Meteorit Udara 29 Juta Tahun Lalu',
        storyContent: 'Di hamparan luas gurun Sahara terserak kepingan kaca silika kuning kehijauan berkemurnian 98% yang konon menghiasi kalung Firaun Tutankhamun.\n\nPenelitian isotop membuktikan bahwa kaca ini lahir dari ledakan meteorit di atmosfer gurun jutaan tahun lalu, menghasilkan bola api 1600°C yang melelehkan butir pasir kuarsa bumi dalam hitungan detik tanpa meninggalkan kawah galian.',
        imageUrl: 'desert_glass',
        coinCost: 60,
        weekDate: '2026-11-17',
      ),
    ];
  }
}
