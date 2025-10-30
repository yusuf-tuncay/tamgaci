import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/shared/widgets/custom_app_bar.dart';
import 'package:tamgaci/shared/widgets/responsive_scaffold.dart';
import 'package:tamgaci/shared/widgets/drawer_menu.dart';

class EmployeesListPage extends StatefulWidget {
  const EmployeesListPage({super.key});

  @override
  State<EmployeesListPage> createState() => _EmployeesListPageState();
}

class _EmployeesListPageState extends State<EmployeesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filters
  final List<String> _departments = const [
    'Tümü',
    'Muhasebe',
    'Operasyon',
    'İK'
  ];
  final List<String> _categories = const [
    'Tümü',
    'Full-Time',
    'Yarı-Zamanlı',
    'Stajyer'
  ];
  String _selectedDepartment = 'Tümü';
  String _selectedCategory = 'Tümü';

  // Sorting
  final List<String> _sortOptions = const [
    'Ad Soyad',
    'Departman',
    'Kategori',
    'Bakiye'
  ];
  String _sortBy = 'Ad Soyad';
  bool _sortAscending = true;

  // Date range kaldırıldı (bu modülde kullanılmıyor)

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel Olarak İndir'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Excel export implementation
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Olarak İndir'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: PDF export implementation
              },
            ),
          ],
        ),
      ),
    );
  }

  // Tarih aralığı kaldırıldı

  Widget _buildSearchAndFilters() {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isNarrow = width < 900;

    if (isNarrow) {
      return Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Personel ara...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: 'Departman',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: _departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDepartment = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'Sırala',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: _sortOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sortBy = v!),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    setState(() => _sortAscending = !_sortAscending),
                icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                tooltip: _sortAscending ? 'Artan' : 'Azalan',
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _showExportOptions,
                icon: const Icon(Icons.file_download),
                tooltip: 'Dışa Aktar',
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Personel ara...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: 'Departman',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDepartment = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: InputDecoration(
                  labelText: 'Sırala',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _sortOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sortBy = v!),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => setState(() => _sortAscending = !_sortAscending),
              icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
              tooltip: _sortAscending ? 'Artan' : 'Azalan',
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _showExportOptions,
              icon: const Icon(Icons.file_download),
              tooltip: 'Dışa Aktar',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Personeller',
        showDrawer: true,
      ),
      drawerContent: const TamgaciDrawerMenu(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _EmployeesHeader(),
            ),
            // FİLTRE/ARAMA/SIRALAMA/EXPORT BLOĞU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSearchAndFilters(),
            ),
            const SizedBox(height: 6),
            const Expanded(
              child: _EmployeeList(),
            ),
          ],
        ),
      ),
      persistentOnLarge: false,
      sidePanelWidth: 280,
    );
  }
}

class _EmployeesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3897F0), Color(0xFF4C6EF5), Color(0xFF1A56D9)],
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personeller',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Şirket personellerinizi yönetin.',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
          const Spacer(),
          const _HeaderStatCard('8', 'Toplam'),
          const SizedBox(width: 8),
          const _HeaderStatCard('₺12.500', 'Açık Bakiye'),
        ],
      ),
    );
  }
}

class _HeaderStatCard extends StatelessWidget {
  final String value;
  final String title;
  const _HeaderStatCard(this.value, this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

// Eski basit filtre bileşeni kaldırıldı; Expenses modülüne uygun
// gelişmiş filtre yapısı _buildSearchAndFilters içerisinde uygulanıyor.

class _EmployeeList extends StatelessWidget {
  final List<Map<String, dynamic>> _employees = const [
    {
      'photo': null,
      'name': 'Ahmet Yılmaz',
      'department': 'Muhasebe',
      'category': 'Full-Time',
      'balance': 3750,
    },
    {
      'photo': null,
      'name': 'Mehmet Can',
      'department': 'Operasyon',
      'category': 'Yarı-Zamanlı',
      'balance': -450,
    },
    {
      'photo': null,
      'name': 'Ayşe Güneş',
      'department': 'İK',
      'category': 'Stajyer',
      'balance': 200,
    },
  ];
  const _EmployeeList();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _employees.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, idx) {
        final e = _employees[idx];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(e['name']),
          subtitle: Text('${e['department']} • ${e['category']}'),
          trailing: Text(
            '₺${e['balance']}',
            style: TextStyle(
                color: e['balance'] < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

// FAB bileşeni şu an kullanılmıyor; ihtiyaç halinde tekrar eklenebilir.
