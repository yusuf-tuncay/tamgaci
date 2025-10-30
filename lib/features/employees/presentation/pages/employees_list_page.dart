import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/shared/widgets/custom_app_bar.dart';
import 'package:tamgaci/shared/widgets/responsive_scaffold.dart';
import 'package:tamgaci/shared/widgets/drawer_menu.dart';

class EmployeesListPage extends StatelessWidget {
  const EmployeesListPage({super.key});

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
              child: _EmployeeFilterBar(),
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
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withValues(alpha:0.9)),
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
  const _HeaderStatCard(this.value, this.title, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.24),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withValues(alpha:0.8))),
        ],
      ),
    );
  }
}

class _EmployeeFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Personel arayın...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.sort),
            label: const Text('Sırala'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(80, 48)),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('Filtrele'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.file_download),
            label: const Text('İçe/Dışa Aktar'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(120, 48)),
          ),
        ),
      ],
    );
  }
}

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
  const _EmployeeList({super.key});
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
            style: TextStyle(color: e['balance'] < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

class _EmployeeFABs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'addEmployee',
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Yeni Personel Ekle'),
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'addDepartment',
          icon: const Icon(Icons.add_business),
          label: const Text('Departman Ekle'),
          onPressed: () {},
        ),
      ],
    );
  }
}