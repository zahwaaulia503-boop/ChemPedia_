-- ==============================================================================
-- ChemPedia (Ensiklopedia Kimia SMA) - Supabase Database Schema & Seed Data
-- Kurikulum Merdeka (Fase E & Fase F: Kelas X, XI, XII)
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. DROP TABLES IF EXIST (Clean Slate)
DROP TABLE IF EXISTS quiz_questions CASCADE;
DROP TABLE IF EXISTS quizzes CASCADE;
DROP TABLE IF EXISTS materials CASCADE;
DROP TABLE IF EXISTS elements CASCADE;
DROP TABLE IF EXISTS glossary CASCADE;
DROP TABLE IF EXISTS daily_facts CASCADE;
DROP TABLE IF EXISTS weekly_mysteries CASCADE;

-- ==============================================================================
-- 3. TABLE DEFINITIONS
-- ==============================================================================

-- A. Table: materials (Ensiklopedia Materi Kimia)
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grade INT NOT NULL CHECK (grade IN (10, 11, 12)),
    chapter_title VARCHAR(150) NOT NULL,
    topic_name VARCHAR(150) NOT NULL,
    summary TEXT NOT NULL,
    content_body TEXT NOT NULL,
    chemical_reactions TEXT[] DEFAULT '{}',
    real_world_application TEXT NOT NULL,
    illustration_url TEXT DEFAULT '',
    order_index INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- B. Table: elements (Tabel Periodik & Unsur Kimia 118)
CREATE TABLE elements (
    atomic_number INT PRIMARY KEY,
    symbol VARCHAR(5) NOT NULL,
    name_id VARCHAR(50) NOT NULL,
    name_latin VARCHAR(50) NOT NULL,
    relative_atomic_mass NUMERIC(7,3) NOT NULL,
    group_number INT NOT NULL,
    period_number INT NOT NULL,
    block VARCHAR(2) NOT NULL CHECK (block IN ('s', 'p', 'd', 'f')),
    category VARCHAR(50) NOT NULL,
    electron_configuration VARCHAR(100) NOT NULL,
    state_at_room_temp VARCHAR(20) NOT NULL CHECK (state_at_room_temp IN ('Padat', 'Cair', 'Gas')),
    fun_facts_and_uses TEXT NOT NULL,
    color_hex VARCHAR(10) DEFAULT '#9575CD'
);

-- C. Table: glossary (Kamus Istilah Kimia A-Z)
CREATE TABLE glossary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    term VARCHAR(100) NOT NULL,
    letter CHAR(1) NOT NULL,
    definition TEXT NOT NULL,
    related_chapter VARCHAR(100) DEFAULT ''
);

-- D. Table: quizzes (Kuis per Bab Materi)
CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_id UUID REFERENCES materials(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- E. Table: quiz_questions (Bank Soal Pilihan Ganda & Pembahasan)
CREATE TABLE quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_image_url TEXT DEFAULT '',
    option_a TEXT NOT NULL,
    option_b TEXT NOT NULL,
    option_c TEXT NOT NULL,
    option_d TEXT NOT NULL,
    correct_option CHAR(1) NOT NULL CHECK (correct_option IN ('A', 'B', 'C', 'D')),
    explanation TEXT NOT NULL,
    order_index INT DEFAULT 1
);

-- F. Table: daily_facts (Fakta Menarik Harian / Tahukah Kamu?)
CREATE TABLE daily_facts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    publish_date DATE NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    fact_description TEXT NOT NULL,
    tag VARCHAR(50) NOT NULL,
    icon_name VARCHAR(50) DEFAULT 'science'
);

-- G. Table: weekly_mysteries (Misteri Kimia Mingguan Terkunci Koin)
CREATE TABLE weekly_mysteries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(150) NOT NULL,
    story_content TEXT NOT NULL,
    image_url TEXT DEFAULT '',
    coin_cost INT DEFAULT 50,
    week_date DATE NOT NULL
);

-- ==============================================================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE elements ENABLE ROW LEVEL SECURITY;
ALTER TABLE glossary ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_facts ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_mysteries ENABLE ROW LEVEL SECURITY;

-- Izinkan akses BACA (SELECT) publik/anonim untuk siswa di seluruh tabel
CREATE POLICY "Public read materials" ON materials FOR SELECT USING (true);
CREATE POLICY "Public read elements" ON elements FOR SELECT USING (true);
CREATE POLICY "Public read glossary" ON glossary FOR SELECT USING (true);
CREATE POLICY "Public read quizzes" ON quizzes FOR SELECT USING (true);
CREATE POLICY "Public read quiz_questions" ON quiz_questions FOR SELECT USING (true);
CREATE POLICY "Public read daily_facts" ON daily_facts FOR SELECT USING (true);
CREATE POLICY "Public read weekly_mysteries" ON weekly_mysteries FOR SELECT USING (true);

-- ==============================================================================
-- 5. SEED DATA (KONTEN ILMIAH KURIKULUM MERDEKA)
-- ==============================================================================

-- --- MATERI KELAS X (FASE E) ---
INSERT INTO materials (id, grade, chapter_title, topic_name, summary, content_body, chemical_reactions, real_world_application, illustration_url, order_index)
VALUES 
('a0000001-0000-0000-0000-000000000001', 10, 'Struktur Atom & Nanoteknologi', 'Perkembangan Model Atom & Partikel Subatom', 
 'Atom tersusun atas proton, neutron, dan elektron. Konsep atom berkembang dari Dalton, Thomson, Rutherford, Bohr, hingga Mekanika Kuantum.',
 'Atom adalah unit terkecil dari materi yang mempertahankan sifat kimiawi suatu unsur. Di pusat atom terdapat inti atom (nukleus) yang bermuatan positif, tersusun atas proton dan neutron, dikelilingi oleh awan elektron bermuatan negatif.\n\nDalam Kurikulum Merdeka, pemahaman struktur atom menjadi dasar pengembangan nanomaterial (material berukuran 1–100 nanometer). Pada skala nano, sifat fisika dan kimia material berubah drastis karena luas permukaan per volume yang sangat besar.',
 ARRAY['Nomor Massa (A) = Proton (Z) + Neutron (N)', 'Konfigurasi Elektron Bohr: 2n^2'],
 'Nanoteknologi digunakan dalam pembuatan tabir surya transparan berbasis nanopartikel Seng Oksida (ZnO) dan Titanium Dioksida (TiO2) yang melindungi kulit dari sinar UV tanpa meninggalkan bekas putih kental.',
 'atom_model', 1),

('a0000001-0000-0000-0000-000000000002', 10, 'Hukum Dasar Kimia & Stoikiometri', 'Hukum Lavoisier & Konsep Mol', 
 'Massa zat sebelum dan sesudah reaksi dalam sistem tertutup adalah sama (Hukum Kekekalan Massa). Konsep mol menghubungkan massa dengan jumlah partikel.',
 'Hukum Lavoisier menyatakan bahwa dalam ruang tertutup, total massa zat reaktan sama dengan total massa zat produk reaksi. Antoine Lavoisier membuktikannya lewat pembakaran timbal dan timah dalam wadah tertutup.\n\nKonsep Mol merupakan jembatan dalam stoikiometri:\n1 mol = 6,02 x 10^23 partikel (Bilangan Avogadro)\nJumlah Mol (n) = Massa (g) / Massa Molar (g/mol)',
 ARRAY['Massa Reaktan = Massa Produk', '2H2 + O2 -> 2H2O', 'n = m / Mr'],
 'Perhitungan stoikiometri sangat krusial dalam pembuatan kantung udara mobil (airbag). Reaksi natrium azida (NaN3) harus menghasilkan gas nitrogen (N2) dalam volume yang tepat dalam hitungan milidetik saat terjadi benturan.',
 'stoichiometry', 2);

-- --- MATERI KELAS XI (FASE F) ---
INSERT INTO materials (id, grade, chapter_title, topic_name, summary, content_body, chemical_reactions, real_world_application, illustration_url, order_index)
VALUES 
('a0000001-0000-0000-0000-000000000003', 11, 'Termokimia', 'Perubahan Entalpi & Kalorimetri', 
 'Termokimia mempelajari perubahan energi (kalor) yang menyertai reaksi kimia. Reaksi eksoterm melepaskan kalor (delta H < 0), sedangkan endoterm menyerap kalor (delta H > 0).',
 'Entalpi (H) adalah total energi potensial dan kinetik yang tersimpan dalam suatu sistem. Perubahan entalpi (delta H) diukur pada tekanan tetap.\n\nReaksi Eksoterm:\nKalor mengalir dari sistem ke lingkungan, suhu lingkungan naik. Contoh: Pembakaran gas elpiji.\n\nReaksi Endoterm:\nKalor diserap oleh sistem dari lingkungan, suhu lingkungan turun. Contoh: Pelarutan ammonium nitrat dalam air.',
 ARRAY['q = m x c x delta T', 'delta H = H_produk - H_reaktan', 'C3H8 + 5O2 -> 3CO2 + 4H2O   delta H = -2220 kJ/mol'],
 'Penerapan nyata termokimia adalah kantung kompres dingin instan (cold pack) untuk cedera olahraga (memanfaatkan reaksi endoterm pelarutan NH4NO3) dan kaleng minuman berpemanas otomatis (reaksi eksoterm CaO dengan air).',
 'thermochemistry', 3),

('a0000001-0000-0000-0000-000000000004', 11, 'Laju Reaksi & Katalis', 'Faktor Laju Reaksi & Teori Tumbukan', 
 'Laju reaksi dipengaruhi oleh konsentrasi, luas permukaan, suhu, dan katalis. Teori tumbukan menjelaskan bahwa reaksi hanya terjadi jika tumbukan efektif menghasilkan energi aktivasi yang cukup.',
 'Laju reaksi menyatakan laju berkurangnya reaktan atau bertambahnya produk per satuan waktu.\n\nFaktor-faktor yang mempercepat laju reaksi:\n1. Konsentrasi: Semakin pekat larutan, partikel semakin padat dan peluang tumbukan efektif meningkat.\n2. Luas Permukaan: Bentuk serbuk bereaksi lebih cepat dibanding bongkahan padat.\n3. Suhu: Kenaikan suhu meningkatkan energi kinetik partikel sehingga lebih banyak partikel melampaui energi aktivasi (Ea).\n4. Katalis: Menurunkan energi aktivasi reaksi tanpa ikut terkonsumsi secara permanen.',
 ARRAY['v = k [A]^x [B]^y', 'Ea(katalis) < Ea(tanpa katalis)'],
 'Konverter katalitik pada knalpot kendaraan bermotor menggunakan katalis platinum dan paladium untuk mengubah gas beracun karbon monoksida (CO) dan nitrogen oksida (NOx) menjadi karbon dioksida (CO2) dan nitrogen (N2) yang tidak beracun.',
 'reaction_rate', 4);

-- --- MATERI KELAS XII (FASE F) ---
INSERT INTO materials (id, grade, chapter_title, topic_name, summary, content_body, chemical_reactions, real_world_application, illustration_url, order_index)
VALUES 
('a0000001-0000-0000-0000-000000000005', 12, 'Larutan Asam Basa & pH', 'Teori Asam Basa & Penentuan Derajat Keasaman', 
 'Asam menghasilkan ion H+ dan basa menghasilkan ion OH- menurut Arrhenius. Nilai pH mengukur derajat keasaman larutan (pH < 7 asam, pH = 7 netral, pH > 7 basa).',
 'Konsep Asam Basa dijelaskan oleh 3 teori utama:\n1. Arrhenius: Asam melepas H+, Basa melepas OH- dalam air.\n2. Bronsted-Lowry: Asam adalah donor proton (H+), Basa adalah akseptor proton.\n3. Lewis: Asam adalah akseptor pasangan elektron, Basa adalah donor pasangan elektron.\n\npH didefinisikan sebagai logaritma negatif dari konsentrasi ion hidrogen: pH = -log[H+]. Larutan penyangga (buffer) mampu mempertahankan nilai pH dari penambahan sedikit asam atau basa.',
 ARRAY['pH = -log[H+]', 'pOH = -log[OH-]', 'pH + pOH = 14', 'HCl + NaOH -> NaCl + H2O'],
 'Darah manusia memiliki sistem penyangga alami berbasis asam karbonat dan bikarbonat (H2CO3 / HCO3-) yang menjaga pH darah tetap stabil pada rentang 7,35 - 7,45. Perubahan kecil pada pH darah dapat berakibat fatal.',
 'acid_base', 5),

('a0000001-0000-0000-0000-000000000006', 12, 'Reaksi Redoks & Elektrokimia', 'Sel Volta & Baterai Masa Depan', 
 'Redoks melibatkan transfer elektron. Sel Volta mengubah energi kimia menjadi listrik secara spontan, sedangkan Sel Elektrolisis menggunakan listrik untuk memicu reaksi kimia nonspontan.',
 'Oksidasi adalah pelepasan elektron atau kenaikan bilangan oksidasi (biloks). Reduksi adalah penangkapan elektron atau penurunan bilangan oksidasi.\n\nSel Volta tersusun dari anoda (tempat terjadinya oksidasi / kutub negatif) dan katoda (tempat terjadinya reduksi / kutub positif). Potensial sel standar dihitung dengan E sel = E katoda - E anoda.',
 ARRAY['E_sel = E_katoda - E_anoda', 'Anoda (Oksidasi): Zn -> Zn2+ + 2e-', 'Katoda (Reduksi): Cu2+ + 2e- -> Cu'],
 'Baterai Lithium-ion (Li-ion) pada ponsel pintar dan kendaraan listrik bekerja berdasarkan prinsip elektrokimia aliran ion litium antara anoda grafit dan katoda oksida logam, merevolusi penyimpanan energi bersih dunia.',
 'electrochemistry', 6);

-- ==============================================================================
-- SEED DATA: ELEMENTS (UNSUR KIMIA PILIHAN SMA)
-- ==============================================================================
INSERT INTO elements (atomic_number, symbol, name_id, name_latin, relative_atomic_mass, group_number, period_number, block, category, electron_configuration, state_at_room_temp, fun_facts_and_uses, color_hex)
VALUES
(1, 'H', 'Hidrogen', 'Hydrogenium', 1.008, 1, 1, 's', 'Nonlogam', '1s1', 'Gas', 
 'Unsur paling melimpah di alam semesta. Digunakan sebagai bahan bakar roket cair dan calon bahan bakar ramah lingkungan masa depan.', '#42A5F5'),

(2, 'He', 'Helium', 'Helium', 4.003, 18, 1, 's', 'Gas Mulia', '1s2', 'Gas', 
 'Gas mulia yang sangat ringan dan tidak mudah terbakar. Digunakan untuk mengisi balon udara dan mendinginkan magnet superkonduktor pada mesin MRI.', '#AB47BC'),

(3, 'Li', 'Litium', 'Lithium', 6.941, 1, 2, 's', 'Logam Alkali', '[He] 2s1', 'Padat', 
 'Logam paling ringan dan sangat reaktif. Menjadi komponen utama baterai ponsel pintar, laptop, dan mobil listrik modern.', '#EF5350'),

(6, 'C', 'Karbon', 'Carbonium', 12.011, 14, 2, 'p', 'Nonlogam', '[He] 2s2 2p2', 'Padat', 
 'Dasar seluruh kehidupan organik. Memiliki bentuk alotrop beragam, mulai dari grafit pensil yang rapuh hingga intan yang merupakan zat alami terkeras di bumi.', '#78909C'),

(7, 'N', 'Nitrogen', 'Nitrogenium', 14.007, 15, 2, 'p', 'Nonlogam', '[He] 2s2 2p3', 'Gas', 
 'Menyusun 78% volume udara di atmosfer bumi. Digunakan dalam industri pupuk tanaman (urea) dan nitrogen cair untuk pengawet biologis.', '#26A69A'),

(8, 'O', 'Oksigen', 'Oxygenium', 15.999, 16, 2, 'p', 'Nonlogam', '[He] 2s2 2p4', 'Gas', 
 'Sangat esensial bagi pernapasan makhluk hidup dan proses pembakaran. Menyusun sekitar 21% atmosfer bumi.', '#29B6F6'),

(11, 'Na', 'Natrium', 'Natrium', 22.990, 1, 3, 's', 'Logam Alkali', '[Ne] 3s1', 'Padat', 
 'Logam alkali lunak yang bereaksi hebat dengan air menghasilkan gas hidrogen. Berikatan dengan klorin membentuk garam dapur (NaCl).', '#FFA726'),

(12, 'Mg', 'Magnesium', 'Magnesium', 24.305, 2, 3, 's', 'Logam Alkali Tanah', '[Ne] 3s2', 'Padat', 
 'Logam penyusun pusat molekul klorofil pada tumbuhan hijau, memungkinkan fotosintesis terjadi.', '#66BB6A'),

(17, 'Cl', 'Klorin', 'Chlorum', 35.453, 17, 3, 'p', 'Halogen', '[Ne] 3s2 3p5', 'Gas', 
 'Gas halogen berwarna kuning kehijauan dengan bau menyengat. Senyawanya digunakan sebagai disinfektan penjernih air dan pemutih pakaian.', '#9CCC65'),

(20, 'Ca', 'Kalsium', 'Calcium', 40.078, 2, 4, 's', 'Logam Alkali Tanah', '[Ar] 4s2', 'Padat', 
 'Komponen utama penyusun tulang dan gigi manusia, serta penyusun batuan kapur (CaCO3) dan semen bangunan.', '#8D6E63'),

(26, 'Fe', 'Besi', 'Ferrum', 55.845, 8, 4, 'd', 'Logam Transisi', '[Ar] 3d6 4s2', 'Padat', 
 'Logam paling banyak digunakan dalam peradaban manusia (konstruksi jembatan & gedung). Pusat protein hemoglobin pengikat oksigen dalam darah.', '#7E57C2'),

(29, 'Cu', 'Tembaga', 'Cuprum', 63.546, 11, 4, 'd', 'Logam Transisi', '[Ar] 3d10 4s1', 'Padat', 
 'Konduktor listrik dan panas yang sangat baik. Digunakan sebagai kabel listrik di seluruh dunia dan pembuatan perunggu.', '#FF7043'),

(79, 'Au', 'Emas', 'Aurum', 196.967, 11, 6, 'd', 'Logam Transisi', '[Xe] 4f14 5d10 6s1', 'Padat', 
 'Logam mulia berkilau kuning yang tidak mengalami korosi. Digunakan sebagai perhiasan berharga dan pelapis konektor elektronik canggih.', '#FFD54F');

-- ==============================================================================
-- SEED DATA: GLOSSARY (KAMUS ISTILAH KIMIA A-Z)
-- ==============================================================================
INSERT INTO glossary (term, letter, definition, related_chapter)
VALUES
('Allotrop', 'A', 'Bentuk modifikasi struktur yang berbeda dari suatu unsur yang sama pada wujud yang sama (misal: intan dan grafit adalah alotrop karbon).', 'Struktur Atom'),
('Asam Konjugasi', 'A', 'Spesi yang terbentuk ketika suatu basa menerima sebuah proton (ion H+) menurut teori Bronsted-Lowry.', 'Asam Basa'),
('Buffer (Larutan Penyangga)', 'B', 'Larutan yang mampu mempertahankan derajat keasaman (pH) saat ditambahkan sedikit asam, sedikit basa, atau diencerkan.', 'Asam Basa'),
('Bilangan Avogadro', 'B', 'Konstanta bernilai 6,022 x 10^23 yang menyatakan jumlah partikel (atom, molekul, ion) dalam satu mol zat.', 'Hukum Dasar Kimia'),
('Derajat Disosiasi', 'D', 'Fraksi atau persentase dari zat yang terurai menjadi ion-ion atau molekul yang lebih sederhana dalam larutan.', 'Kesetimbangan Kimia'),
('Elektrolit', 'E', 'Zat yang ketika dilarutkan dalam air dapat terurai menjadi ion-ion bebas sehingga larutannya dapat menghantarkan arus listrik.', 'Larutan & Redoks'),
('Entalpi', 'E', 'Besaran termodinamika yang menyatakan kandungan kalor atau total energi suatu sistem pada tekanan konstan.', 'Termokimia'),
('Garam', 'G', 'Senyawa ionik yang terbentuk dari hasil reaksi netralisasi antara asam dan basa.', 'Asam Basa'),
('Hukum Hess', 'H', 'Hukum yang menyatakan bahwa perubahan entalpi reaksi hanya bergantung pada keadaan awal dan akhir, tidak bergantung pada jalannya reaksi.', 'Termokimia'),
('Isotop', 'I', 'Atom-atom dari unsur yang sama (memiliki nomor atom sama), tetapi memiliki nomor massa yang berbeda karena perbedaan jumlah neutron.', 'Struktur Atom'),
('Katalis', 'K', 'Zat yang mempercepat laju reaksi kimia dengan cara menurunkan energi aktivasi, tanpa terkonsumsi secara permanen di akhir reaksi.', 'Laju Reaksi'),
('Mol', 'M', 'Satuan internasional untuk jumlah zat yang mengandung partikel sebanyak jumlah atom dalam 12 gram Karbon-12.', 'Hukum Dasar Kimia'),
('Oksidator', 'O', 'Zat yang mengalami reduksi (mengikat elektron) dan menyebabkan zat lain mengalami reaksi oksidasi.', 'Redoks & Elektrokimia'),
('pH', 'P', 'Skala logaritma negatif dari konsentrasi ion hidrogen [H+] yang digunakan untuk menyatakan derajat keasaman suatu larutan.', 'Asam Basa'),
('Reduktor', 'R', 'Zat yang mengalami oksidasi (melepas elektron) dan menyebabkan zat lain mengalami reaksi reduksi.', 'Redoks & Elektrokimia'),
('Stoikiometri', 'S', 'Cabang ilmu kimia yang mempelajari hubungan kuantitatif antara massa dan jumlah mol zat-zat yang terlibat dalam reaksi kimia.', 'Hukum Dasar Kimia'),
('Titrasi', 'T', 'Metode analisis kuantitatif untuk menentukan konsentrasi larutan analit dengan menambahkan larutan standar yang diketahui konsentrasinya secara presisi.', 'Asam Basa');

-- ==============================================================================
-- SEED DATA: QUIZZES & QUIZ QUESTIONS
-- ==============================================================================

-- Kuis 1: Struktur Atom & Nanomaterial (Kelas X)
INSERT INTO quizzes (id, material_id, title)
VALUES ('b0000001-0000-0000-0000-000000000001', 'a0000001-0000-0000-0000-000000000001', 'Kuis Latihan: Struktur Atom & Nanoteknologi');

INSERT INTO quiz_questions (id, quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, order_index)
VALUES
('c0000001-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001',
 'Partikel subatom yang terletak di dalam inti atom dan bermuatan positif adalah...',
 'Elektron', 'Proton', 'Neutron', 'Positron',
 'B',
 'Proton bermuatan positif (+1) dan neutron (netral) terletak di inti atom, sedangkan elektron (-1) mengelilingi inti pada kulit atom.', 1),

('c0000001-0000-0000-0000-000000000002', 'b0000001-0000-0000-0000-000000000001',
 'Berapa rentang ukuran skala partikel yang dikategorikan sebagai nanomaterial dalam sains modern?',
 '1 - 100 mikrometer', '1 - 100 nanometer', '100 - 1000 nanometer', '1 - 10 milimeter',
 'B',
 'Berdasarkan kesepakatan sains, skala nano merujuk pada rentang ukuran 1 hingga 100 nanometer (1 nm = 10^-9 meter).', 2),

('c0000001-0000-0000-0000-000000000003', 'b0000001-0000-0000-0000-000000000001',
 'Atom Natrium memiliki nomor atom 11 dan nomor massa 23. Jumlah neutron dalam atom tersebut adalah...',
 '11', '12', '23', '34',
 'B',
 'Jumlah neutron dihitung dengan rumus: Neutron = Nomor Massa (A) - Nomor Atom (Z) = 23 - 11 = 12.', 3);

-- Kuis 2: Termokimia (Kelas XI)
INSERT INTO quizzes (id, material_id, title)
VALUES ('b0000001-0000-0000-0000-000000000002', 'a0000001-0000-0000-0000-000000000003', 'Kuis Latihan: Termokimia & Energi Reaksi');

INSERT INTO quiz_questions (id, quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, order_index)
VALUES
('c0000001-0000-0000-0000-000000000004', 'b0000001-0000-0000-0000-000000000002',
 'Ciri khas dari reaksi eksoterm adalah...',
 'Menyerap kalor dari lingkungan dan delta H bernilai positif',
 'Melepaskan kalor ke lingkungan dan delta H bernilai negatif',
 'Suhu lingkungan mengalami penurunan drastis',
 'Tidak terjadi perpindahan energi antara sistem dan lingkungan',
 'B',
 'Reaksi eksoterm melepaskan kalor ke lingkungan, menyebabkan suhu lingkungan naik dan perubahan entalpi (delta H) bertanda negatif.', 1),

('c0000001-0000-0000-0000-000000000005', 'b0000001-0000-0000-0000-000000000002',
 'Pemanfaatan reaksi kimia endoterm dalam kehidupan sehari-hari dapat ditemukan pada...',
 'Pembakaran bensin pada mesin motor',
 'Kantung kompres dingin instan (cold pack) untuk cedera atlet',
 'Lilin yang menyala di ruangan',
 'Pengelasan rel kereta api dengan reaksi termit',
 'B',
 'Cold pack instan menggunakan pelarutan amonium nitrat (NH4NO3) dalam air yang menyerap kalor dari lingkungan sekitarnya (endoterm).', 2);

-- Kuis 3: Asam Basa (Kelas XII)
INSERT INTO quizzes (id, material_id, title)
VALUES ('b0000001-0000-0000-0000-000000000003', 'a0000001-0000-0000-0000-000000000005', 'Kuis Latihan: Asam Basa & Larutan Buffer');

INSERT INTO quiz_questions (id, quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation, order_index)
VALUES
('c0000001-0000-0000-0000-000000000006', 'b0000001-0000-0000-0000-000000000003',
 'Larutan HCl memiliki konsentrasi ion H+ sebesar 0,001 M (10^-3 M). Nilai pH larutan tersebut adalah...',
 '1', '3', '7', '11',
 'B',
 'pH = -log[H+] = -log(10^-3) = 3.', 1),

('c0000001-0000-0000-0000-000000000007', 'b0000001-0000-0000-0000-000000000003',
 'Sistem penyangga utama yang menjaga agar pH darah manusia tetap stabil pada rentang 7,35 - 7,45 tersusun dari pasangan...',
 'HCl dan NaCl',
 'H2CO3 dan HCO3-',
 'CH3COOH dan CH3COONa',
 'NH3 dan NH4Cl',
 'B',
 'Sistem buffer karbonat (H2CO3 / HCO3-) adalah benteng utama homeostasis pH dalam plasma darah manusia.', 2);

-- ==============================================================================
-- SEED DATA: DAILY FACTS (TAHUKAH KAMU?)
-- ==============================================================================
INSERT INTO daily_facts (publish_date, title, fact_description, tag, icon_name)
VALUES
(CURRENT_DATE, 'Mengapa Bawang Membuat Kita Menangis?', 
 'Saat bawang diiris, enzim seluler memecah asam amino sulfoksida menghasilkan gas Syn-propanethial-S-oxide. Saat mengenai uap air di bola mata, gas ini bereaksi membentuk asam sulfat encer yang memicu kelenjar air mata.', 
 'Kimia Dapur', 'water_drop'),

(CURRENT_DATE - 1, 'Kaca Adalah Zat Padat Semu (Amorf)', 
 'Secara ilmiah, kaca bukan zat padat kristal biasa melainkan cairan superdingin (amorphous solid). Molekul silika di dalamnya tersusun acak tanpa pola kisi kristal teratur seperti es atau logam.', 
 'Material Kimia', 'science'),

(CURRENT_DATE - 2, 'Kembang Api & Spektrum Emisi Logam', 
 'Warna-warni kembang api berasal dari emisi foton logam saat dipanaskan. Stronsium memancarkan warna merah menyala, Tembaga menghasilkan warna biru, Barium hijau cerah, dan Natrium menghasilkan kuning keemasan.', 
 'Kimia Spektroskopi', 'auto_awesome');

-- ==============================================================================
-- SEED DATA: WEEKLY MYSTERIES (TERKUNCI KOIN)
-- ==============================================================================
INSERT INTO weekly_mysteries (title, story_content, image_url, coin_cost, week_date)
VALUES
('Misteri Api Biru Kawah Ijen: Fenomena Langka Dunia',
 'Di Kawah Ijen, Banyuwangi, Jawa Timur, terdapat fenomena alam spektakuler yang hanya ada dua di dunia: Api Biru (Blue Fire).\n\nSecara kimiawi, cahaya biru elektrik ini bukan nyala lahar panas, melainkan gas belerang murni (sulfur elemental) bertekanan tinggi yang menyembur keluar dari celah batuan pada suhu mencapai 600 derajat Celsius. Ketika gas belerang bersuhu tinggi ini bertemu dengan oksigen di udara atmosfer, terjadi reaksi pembakaran eksoterm yang memancarkan spektrum cahaya biru terang khas radiasi nyala sulfur.\n\nPembakaran gas sulfur menghasilkan gas belerang dioksida (SO2) yang sangat menyengat dan berbahaya jika terhirup, sehingga penambang belerang tradisional harus mengenakan masker khusus saat bekerja di kawah.',
 'blue_fire_ijen', 50, CURRENT_DATE),

('Kaca Misterius Gurun Libya: Ledakan Kosmik Kuno',
 'Di hamparan gurun pasir Libya dan Mesir, berserakan pecahan kaca silika kuning kehijauan yang sangat murni (Libyan Desert Glass). Selama ribuan tahun, asal-usulnya menjadi misteri peradaban kuno hingga dijadikan perhiasan dada Firaun Tutankhamun.\n\nAnalisis kimia modern mengungkap bahwa kaca gurun ini terbentuk sekitar 29 juta tahun lalu akibat ledakan meteorit raksasa di udara (airburst). Gelombang panas ekstrem melebihi 1.600 derajat Celsius melelehkan butir pasir kuarsa (SiO2) di daratan dalam sekejap tanpa meninggalkan kawah tubrukan besar, membeku menjadi kaca silika alami berkemurnian 98%.',
 'desert_glass', 60, CURRENT_DATE - 7);
