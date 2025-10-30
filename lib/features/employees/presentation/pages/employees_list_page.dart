import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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

  // Filters (dinamik)
  List<String> _departments = const [];
  List<String> _categories = const [];
  List<String> _positions = const [];
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
    // Firestore'dan departman ve kategori dinle
    _listenToMetaCollections();
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

  void _openManageCategoriesPage() {
    final TextEditingController catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kategoriler'),
          content: SizedBox(
            width: 480,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: catCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Yeni kategori adı',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final name = catCtrl.text.trim();
                          if (name.isEmpty) return;
                          final exists = await FirebaseFirestore.instance
                              .collection('employee_categories')
                              .where('name', isEqualTo: name)
                              .limit(1)
                              .get();
                          if (exists.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bu kategori zaten var')),
                            );
                            return;
                          }
                          await FirebaseFirestore.instance
                              .collection('employee_categories')
                              .add({
                            'name': name,
                            'createdAt': FieldValue.serverTimestamp()
                          });
                          catCtrl.clear();
                        },
                        child: const Text('Ekle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('employee_categories')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Kategori Düzenle'),
                                        content: TextField(
                                            controller: editCtrl,
                                            decoration: const InputDecoration(
                                                labelText: 'Ad')),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('İptal')),
                                          FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Kaydet')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Kategori Sil'),
                                        content: Text('"$name" silinsin mi?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('Vazgeç')),
                                          FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Sil')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) await d.reference.delete();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'))
          ],
        );
      },
    );
  }

  void _listenToMetaCollections() {
    FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      final names = snapshot.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _departments = ['Tümü', ...names];
        if (!_departments.contains(_selectedDepartment)) {
          _selectedDepartment = 'Tümü';
        }
      });
    });

    FirebaseFirestore.instance
        .collection('employee_categories')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      final names = snapshot.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _categories = ['Tümü', ...names];
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'Tümü';
        }
      });
    });

    FirebaseFirestore.instance
        .collection('positions')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
      final names = snapshot.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _positions = names;
      });
    });
  }

  void _openManagePositions() {
    final controller = TextEditingController();
    final categoryCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pozisyonlar ve Kategoriler'),
          content: SizedBox(
            width: 520,
            height: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pozisyonlar',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Yeni pozisyon adı',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final name = controller.text.trim();
                          if (name.isEmpty) return;
                          final exists = await FirebaseFirestore.instance
                              .collection('positions')
                              .where('name', isEqualTo: name)
                              .limit(1)
                              .get();
                          if (exists.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bu pozisyon zaten var')),
                            );
                            return;
                          }
                          await FirebaseFirestore.instance
                              .collection('positions')
                              .add({
                            'name': name,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          controller.clear();
                        },
                        child: const Text('Ekle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('positions')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Pozisyon Düzenle'),
                                        content: TextField(
                                          controller: editCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Ad'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('İptal'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Kaydet'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Pozisyon Sil'),
                                        content: Text('"$name" silinsin mi?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Vazgeç'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Sil'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      await d.reference.delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Kategoriler',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: categoryCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Yeni kategori adı',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final name = categoryCtrl.text.trim();
                          if (name.isEmpty) return;
                          final exists = await FirebaseFirestore.instance
                              .collection('employee_categories')
                              .where('name', isEqualTo: name)
                              .limit(1)
                              .get();
                          if (exists.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bu kategori zaten var')),
                            );
                            return;
                          }
                          await FirebaseFirestore.instance
                              .collection('employee_categories')
                              .add({
                            'name': name,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          categoryCtrl.clear();
                        },
                        child: const Text('Ekle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('employee_categories')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Kategori Düzenle'),
                                        content: TextField(
                                          controller: editCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Ad'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('İptal'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Kaydet'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Kategori Sil'),
                                        content: Text('"$name" silinsin mi?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Vazgeç'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Sil'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      await d.reference.delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _openManageDepartments() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Departmanlar'),
          content: SizedBox(
            width: 420,
            height: 420,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Yeni departman adı',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        try {
                          await FirebaseFirestore.instance
                              .collection('departments')
                              .add({
                            'name': name,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          controller.clear();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ekleme hatası: $e')),
                          );
                        }
                      },
                      child: const Text('Ekle'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('departments')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title:
                                              const Text('Departman Düzenle'),
                                          content: TextField(
                                            controller: editCtrl,
                                            decoration: const InputDecoration(
                                                labelText: 'Ad'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('İptal'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Kaydet'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Departman Sil'),
                                        content: Text('"$name" silinsin mi?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Vazgeç'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text('Sil'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      await d.reference.delete();
                                      if (_selectedDepartment == name) {
                                        setState(
                                            () => _selectedDepartment = 'Tümü');
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
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

  void _onAddEmployee() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.6,
          maxChildSize: 0.98,
          expand: false,
          builder: (context, scrollController) {
            return _AddEmployeeForm(
              departments: _departments,
              categories: _categories,
              positions: _positions,
              onManagePositions: _openManagePositions,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  // _onAddDepartment kaldırıldı; departman yönetimi form içinden açılan diyalogda yapılır

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
                  initialValue: _selectedDepartment,
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
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Departman Ekle',
                onPressed: _openManageDepartments,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
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
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Kategori Ekle',
                onPressed: _openManageCategoriesPage,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
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
                initialValue: _selectedDepartment,
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
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Departman Ekle',
              onPressed: _openManageDepartments,
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
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
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Kategori Ekle',
              onPressed: _openManageCategoriesPage,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _sortBy,
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
      body: Stack(
        children: [
          SafeArea(
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
                Expanded(
                  child: _EmployeeList(
                    searchQuery: _searchQuery,
                    selectedDepartment: _selectedDepartment == 'Tümü'
                        ? null
                        : _selectedDepartment,
                    selectedCategory:
                        _selectedCategory == 'Tümü' ? null : _selectedCategory,
                    sortBy: _sortBy,
                    ascending: _sortAscending,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'fab_add_employee',
                  onPressed: _onAddEmployee,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Yeni Personel Ekle'),
                ),
              ],
            ),
          ),
        ],
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
  final String searchQuery;
  final String? selectedDepartment;
  final String? selectedCategory;
  final String sortBy;
  final bool ascending;
  const _EmployeeList({
    this.searchQuery = '',
    this.selectedDepartment,
    this.selectedCategory,
    this.sortBy = 'Ad Soyad',
    this.ascending = true,
  });
  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('employees');

    if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
      query = query.where('department', isEqualTo: selectedDepartment);
    }
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    String orderField;
    switch (sortBy) {
      case 'Ad Soyad':
        orderField = 'name';
        break;
      case 'Departman':
        orderField = 'department';
        break;
      case 'Kategori':
        orderField = 'category';
        break;
      case 'Bakiye':
        orderField = 'name'; // placeholder
        break;
      default:
        orderField = 'createdAt';
    }
    // Tek bir orderBy kullanarak kompozit index ihtiyacını azalt
    query = query.orderBy(orderField, descending: !ascending);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Hata: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snap.data!.docs;
        final q = searchQuery.trim().toLowerCase();
        if (q.isNotEmpty) {
          docs = docs.where((d) {
            final data = d.data();
            final name = (data['name'] as String?)?.toLowerCase() ?? '';
            final department =
                (data['department'] as String?)?.toLowerCase() ?? '';
            final category = (data['category'] as String?)?.toLowerCase() ?? '';
            return name.contains(q) ||
                department.contains(q) ||
                category.contains(q);
          }).toList();
        }
        if (docs.isEmpty) {
          return const Center(child: Text('Henüz personel bulunmuyor'));
        }
        // Bölümlere ayır: Departmana göre grupla ve başlıklarla listele
        final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
            grouped = {};
        for (final d in docs) {
          final dep = (d.data()['department'] as String?)?.trim();
          final key = (dep == null || dep.isEmpty) ? '-' : dep;
          (grouped[key] ??= []).add(d);
        }
        final departments = grouped.keys.toList()..sort();

        final List<_SectionEntry> entries = [];
        for (final dep in departments) {
          final items = grouped[dep]!;
          // İstikrarlı görünüm için departman içini ada göre sırala (yerel sıralama)
          items.sort((a, b) {
            final an = (a.data()['name'] as String? ?? '').toLowerCase();
            final bn = (b.data()['name'] as String? ?? '').toLowerCase();
            return an.compareTo(bn);
          });
          entries.add(_SectionEntry.header(dep));
          for (final doc in items) {
            entries.add(_SectionEntry.item(doc));
          }
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final e = entries[idx];
            if (e.isHeader) {
              return Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  e.headerTitle ?? '-',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              );
            }
            final snap = e.doc!;
            final data = snap.data();
            final name = data['name'] as String? ?? '-';
            final department = data['department'] as String? ?? '-';
            final category = data['category'] as String? ?? '-';
            final photoUrl = data['photoUrl'] as String?;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(name),
              subtitle: Text('$department • $category'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (ctx) =>
                    _EmployeeDetailSheet(docId: snap.id, data: data),
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionEntry {
  final bool isHeader;
  final String? headerTitle;
  final QueryDocumentSnapshot<Map<String, dynamic>>? doc;
  _SectionEntry.header(this.headerTitle)
      : isHeader = true,
        doc = null;
  _SectionEntry.item(this.doc)
      : isHeader = false,
        headerTitle = null;
}

class _EmployeeDetailSheet extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _EmployeeDetailSheet({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '-';
    final department = data['department'] as String? ?? '-';
    final category = data['category'] as String? ?? '-';
    final position = data['position'] as String? ?? '-';
    final salary = (data['salary'] as Map?) ?? {};
    final salaryAmount = salary['amount']?.toString() ?? '-';
    final salaryCurrency = salary['currency']?.toString() ?? '';
    final entitlement = (data['entitlement'] as Map?) ?? {};
    final entitlementType = entitlement['type']?.toString() ?? '-';
    final startTs = data['startDate'];
    final birthTs = data['birthDate'];
    String? fmtTs(dynamic ts) {
      try {
        if (ts is Timestamp) {
          final d = ts.toDate();
          return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
        }
      } catch (_) {}
      return null;
    }

    final startDate = fmtTs(startTs) ?? '-';
    final birthDate = fmtTs(birthTs) ?? '-';
    final photoUrl = data['photoUrl'] as String?;
    final docs = (data['documents'] as List?) ?? const [];

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text('$department • $category'),
                        ],
                      ),
                    ),
                    Row(children: [
                      OutlinedButton.icon(
                        onPressed: () => _openEdit(context),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Düzenle'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Kapat',
                      )
                    ])
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _InfoTile(label: 'Pozisyon', value: position),
                        _InfoTile(
                            label: 'Maaş',
                            value: '$salaryAmount $salaryCurrency'),
                        _InfoTile(label: 'Hak Ediş', value: entitlementType),
                        _InfoTile(label: 'İşe Başlama', value: startDate),
                        _InfoTile(label: 'Doğum Tarihi', value: birthDate),
                      ],
                    ),
                  ),
                ),
                if (docs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dökümanlar',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final raw = docs[i];
                              final m = raw is Map ? raw : <String, dynamic>{};
                              final fileName = m['name']?.toString() ?? 'dosya';
                              final url = m['url']?.toString();
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.download),
                                title: Text(fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                trailing: const Icon(Icons.chevron_right),
                                onTap:
                                    url == null ? null : () => _launchUrl(url),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Hareketler',
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            _EmployeeBalance(docId: docId),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _EmployeeTransactionsList(docId: docId),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // ignore: use_build_context_synchronously
        // silently fail or show a snackbar if needed
      }
    } catch (_) {}
  }

  void _openEdit(BuildContext context) {
    final nameCtrl = TextEditingController(text: data['name'] as String? ?? '');
    final posCtrl =
        TextEditingController(text: data['position'] as String? ?? '');
    final deptCtrl =
        TextEditingController(text: data['department'] as String? ?? '');
    final catCtrl =
        TextEditingController(text: data['category'] as String? ?? '');
    final salary = (data['salary'] as Map?) ?? {};
    final salAmtCtrl =
        TextEditingController(text: (salary['amount']?.toString()) ?? '');
    final salCurCtrl =
        TextEditingController(text: (salary['currency']?.toString()) ?? 'TRY');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Personel Düzenle'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ad Soyad')),
              TextField(
                  controller: posCtrl,
                  decoration: const InputDecoration(labelText: 'Pozisyon')),
              TextField(
                  controller: deptCtrl,
                  decoration: const InputDecoration(labelText: 'Departman')),
              TextField(
                  controller: catCtrl,
                  decoration: const InputDecoration(labelText: 'Kategori')),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: salAmtCtrl,
                        decoration: const InputDecoration(labelText: 'Maaş'))),
                const SizedBox(width: 8),
                SizedBox(
                    width: 90,
                    child: TextField(
                        controller: salCurCtrl,
                        decoration: const InputDecoration(labelText: 'PB'))),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('employees')
                    .doc(docId)
                    .update({
                  'name': nameCtrl.text.trim(),
                  'position': posCtrl.text.trim(),
                  'department': deptCtrl.text.trim(),
                  'category': catCtrl.text.trim(),
                  'salary': {
                    'amount':
                        double.tryParse(salAmtCtrl.text.replaceAll(',', '.')) ??
                            0,
                    'currency': salCurCtrl.text.trim(),
                  },
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                // ignore: use_build_context_synchronously
                Navigator.of(ctx).pop();
              } catch (_) {}
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Colors.grey[700]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(999),
        color: Colors.grey[50],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: labelStyle),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmployeeBalance extends StatelessWidget {
  final String docId;
  const _EmployeeBalance({required this.docId});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('employee_transactions')
        .where('employeeId', isEqualTo: docId);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Hata: ${snapshot.error}',
              style: const TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData) {
          return const SizedBox(
              width: 100, child: LinearProgressIndicator(minHeight: 4));
        }
        double balance = 0;
        for (final doc in snapshot.data!.docs) {
          final m = doc.data();
          final amount = (m['amount'] as num?)?.toDouble() ?? 0;
          final dir = (m['direction'] as String?) ?? 'out';
          balance += dir == 'in' ? amount : -amount;
        }
        final text = balance.toStringAsFixed(2);
        final color = balance >= 0 ? Colors.green : Colors.red;
        return Row(children: [
          Text('Bakiye: ', style: Theme.of(context).textTheme.bodyMedium),
          Text(text,
              style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        ]);
      },
    );
  }
}

class _EmployeeTransactionsList extends StatelessWidget {
  final String docId;
  const _EmployeeTransactionsList({required this.docId});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('employee_transactions')
        .where('employeeId', isEqualTo: docId)
        .limit(10);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Text('Hata: ${snap.error}',
              style: const TextStyle(color: Colors.red));
        }
        if (!snap.hasData) {
          return const LinearProgressIndicator(minHeight: 2);
        }
        final docs = [...snap.data!.docs];
        docs.sort((a, b) {
          final ad = a.data()['date'];
          final bd = b.data()['date'];
          DateTime adt;
          DateTime bdt;
          try {
            adt = ad is Timestamp
                ? ad.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
          } catch (_) {
            adt = DateTime.fromMillisecondsSinceEpoch(0);
          }
          try {
            bdt = bd is Timestamp
                ? bd.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
          } catch (_) {
            bdt = DateTime.fromMillisecondsSinceEpoch(0);
          }

          return bdt.compareTo(adt); // desc
        });
        if (docs.isEmpty) {
          return const Text('Henüz hareket yok');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final m = docs[i].data();
            final amount = (m['amount'] as num?)?.toDouble() ?? 0;
            final dir = (m['direction'] as String?) ?? 'out';
            final sign = dir == 'in' ? '+' : '-';
            final color = dir == 'in' ? Colors.green : Colors.red;
            final note = m['note']?.toString() ?? '';
            final ts = m['date'];
            String dt = '';
            try {
              if (ts is Timestamp) {
                final d = ts.toDate();
                dt =
                    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
              }
            } catch (_) {}
            return ListTile(
              dense: true,
              leading: Icon(dir == 'in' ? Icons.call_received : Icons.call_made,
                  color: color),
              title: Text(note.isEmpty
                  ? (dir == 'in' ? 'Ödeme' : 'Avans/Çıkış')
                  : note),
              subtitle: Text(dt),
              trailing: Text('$sign${amount.toStringAsFixed(2)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            );
          },
        );
      },
    );
  }
}

class _AddEmployeeForm extends StatefulWidget {
  final List<String> departments;
  final List<String> categories;
  final List<String> positions;
  final VoidCallback onManagePositions;
  final ScrollController scrollController;
  const _AddEmployeeForm({
    required this.departments,
    required this.categories,
    required this.positions,
    required this.onManagePositions,
    required this.scrollController,
  });

  @override
  State<_AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<_AddEmployeeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _salaryAmountController = TextEditingController();
  final TextEditingController _customPeriodNoteController =
      TextEditingController();

  // Selections
  DateTime? _birthDate;
  DateTime? _startDate;
  String? _selectedDepartment;
  String? _selectedCategory;
  String? _selectedPosition;
  String _salaryCurrency = 'TRY';
  String _entitlementType = 'Aylık';
  int? _monthlyDayOfMonth; // 1-31
  int? _semiMonthlyDay1;
  int? _semiMonthlyDay2;
  String? _weeklyWeekday; // Pazartesi, ...
  int _daysPerWeek = 5;
  final List<String> _weeklySelectedDays = [];

  // Uploads
  Uint8List? _photoBytes;
  String? _photoName;
  final List<_PickedDoc> _pickedDocs = [];

  bool _isSaving = false;

  // Live option lists
  List<String> _positionsLive = [];
  List<String> _categoriesLive = [];
  List<String> _departmentsLive = [];
  StreamSubscription? _posSub;
  StreamSubscription? _catSub;
  StreamSubscription? _deptSub;

  @override
  void initState() {
    super.initState();
    // Seed from parent
    _positionsLive = List<String>.from(widget.positions);
    _categoriesLive = List<String>.from(widget.categories);
    _departmentsLive = List<String>.from(widget.departments);
    // Listen to Firestore for runtime updates
    _posSub = FirebaseFirestore.instance
        .collection('positions')
        .orderBy('name')
        .snapshots()
        .listen((s) {
      final names = s.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _positionsLive = names;
        if (_selectedPosition != null &&
            !_positionsLive.contains(_selectedPosition)) {
          _selectedPosition = null;
        }
      });
    });
    _catSub = FirebaseFirestore.instance
        .collection('employee_categories')
        .orderBy('name')
        .snapshots()
        .listen((s) {
      final names = s.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _categoriesLive = names;
        if (_selectedCategory != null &&
            !_categoriesLive.contains(_selectedCategory)) {
          _selectedCategory = null;
        }
      });
    });

    _deptSub = FirebaseFirestore.instance
        .collection('departments')
        .orderBy('name')
        .snapshots()
        .listen((s) {
      final names = s.docs
          .map((d) => (d.data())['name'] as String)
          .where((e) => e.trim().isNotEmpty)
          .toSet()
          .toList();
      setState(() {
        _departmentsLive = names;
        if (_selectedDepartment != null &&
            !_departmentsLive.contains(_selectedDepartment)) {
          _selectedDepartment = null;
        }
      });
    });
  }

  // Çalışma takvimi (saatlik/günlük)
  final List<String> _weekdays = const [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];
  late final Map<String, bool> _dayEnabled = {
    'Pazartesi': true,
    'Salı': true,
    'Çarşamba': true,
    'Perşembe': true,
    'Cuma': true,
    'Cumartesi': false,
    'Pazar': false,
  };
  late final Map<String, TimeOfDay> _startTimes = {
    for (final d in _weekdays) d: const TimeOfDay(hour: 9, minute: 0)
  };
  late final Map<String, TimeOfDay> _endTimes = {
    for (final d in _weekdays) d: const TimeOfDay(hour: 18, minute: 0)
  };

  // Fazla mesai
  bool _overtimeEnabled = false;
  // Saatlik için takvim opsiyonel
  bool _hourlyScheduleEnabled = false;
  final TextEditingController _overtimeThresholdHoursController =
      TextEditingController(text: '8');
  final TextEditingController _overtimeMultiplierController =
      TextEditingController(text: '1.5');

  @override
  void dispose() {
    _nameController.dispose();
    _tcController.dispose();
    _positionController.dispose();
    _salaryAmountController.dispose();
    _customPeriodNoteController.dispose();
    _overtimeThresholdHoursController.dispose();
    _overtimeMultiplierController.dispose();
    _posSub?.cancel();
    _catSub?.cancel();
    _deptSub?.cancel();
    super.dispose();
  }

  // Eski birleşik diyalog kaldırıldı (departman+kategori). Ayrı diyaloglar kullanılıyor.

  void _openManageCategories() {
    final catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kategoriler'),
          content: SizedBox(
            width: 520,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: catCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Yeni kategori adı'))),
                    const SizedBox(width: 8),
                    FilledButton(
                        onPressed: () async {
                          final name = catCtrl.text.trim();
                          if (name.isEmpty) return;
                          final exists = await FirebaseFirestore.instance
                              .collection('employee_categories')
                              .where('name', isEqualTo: name)
                              .limit(1)
                              .get();
                          if (exists.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Bu kategori zaten var')));
                            return;
                          }
                          await FirebaseFirestore.instance
                              .collection('employee_categories')
                              .add({
                            'name': name,
                            'createdAt': FieldValue.serverTimestamp()
                          });
                          catCtrl.clear();
                        },
                        child: const Text('Ekle')),
                  ]),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('employee_categories')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Hata: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Kayıt yok'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final name = d.data()['name'] as String? ?? '-';
                          return ListTile(
                            title: Text(name),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  tooltip: 'Düzenle',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final editCtrl =
                                        TextEditingController(text: name);
                                    final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                    'Kategori Düzenle'),
                                                content: TextField(
                                                    controller: editCtrl,
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText: 'Ad')),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(false),
                                                      child:
                                                          const Text('İptal')),
                                                  FilledButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(true),
                                                      child:
                                                          const Text('Kaydet'))
                                                ]));
                                    if (ok == true) {
                                      final newName = editCtrl.text.trim();
                                      if (newName.isNotEmpty) {
                                        await d.reference
                                            .update({'name': newName});
                                      }
                                    }
                                  }),
                              IconButton(
                                  tooltip: 'Sil',
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                                title:
                                                    const Text('Kategori Sil'),
                                                content: Text(
                                                    '"$name" silinsin mi?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(false),
                                                      child:
                                                          const Text('Vazgeç')),
                                                  FilledButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(true),
                                                      child: const Text('Sil'))
                                                ]));
                                    if (ok == true) await d.reference.delete();
                                  }),
                            ]),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'))
          ],
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoName = file.name;
      });
    } catch (_) {}
  }

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );
      if (result == null) return;
      for (final f in result.files) {
        if (f.bytes == null) continue;
        _pickedDocs.add(_PickedDoc(name: f.name, bytes: f.bytes!));
      }
      setState(() {});
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Doğum tarihi seçin')));
      return;
    }
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Departman seçin')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kategori seçin')));
      return;
    }
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşe başlama tarihi seçin')));
      return;
    }

    // Entitlement validations
    if (_entitlementType == 'Aylık') {
      if (_monthlyDayOfMonth == null ||
          _monthlyDayOfMonth! < 1 ||
          _monthlyDayOfMonth! > 31) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ayın gününü 1-31 arasında seçin')));
        return;
      }
    } else if (_entitlementType == 'Aylık (İki Kere)') {
      if (_semiMonthlyDay1 == null || _semiMonthlyDay2 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Her iki ödeme gününü de seçin')));
        return;
      }
      if (_semiMonthlyDay1 == _semiMonthlyDay2) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Günler farklı olmalı')));
        return;
      }
    } else if (_entitlementType == 'Haftalık') {
      if (_weeklyWeekday == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Haftanın gününü seçin')));
        return;
      }
    } else if (_entitlementType == 'Günlük') {
      if (_daysPerWeek < 1 || _daysPerWeek > 7) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Haftada 1-7 gün arasında çalışabilir')));
        return;
      }
      if (_weeklySelectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Çalışılan günleri seçin')));
        return;
      }
      for (final d in _weekdays) {
        if (_dayEnabled[d] == true) {
          final s = _startTimes[d]!;
          final e = _endTimes[d]!;
          final sMin = s.hour * 60 + s.minute;
          final eMin = e.hour * 60 + e.minute;
          if (eMin <= sMin) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Çalışma saatleri geçersiz: $d')),
            );
            return;
          }
        }
      }
    } else if (_entitlementType == 'Saatlik' && _hourlyScheduleEnabled) {
      // Saatlik + takvim aktif ise saat kontrolleri
      for (final d in _weekdays) {
        if (_dayEnabled[d] == true) {
          final s = _startTimes[d]!;
          final e = _endTimes[d]!;
          final sMin = s.hour * 60 + s.minute;
          final eMin = e.hour * 60 + e.minute;
          if (eMin <= sMin) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Çalışma saatleri geçersiz: $d')),
            );
            return;
          }
        }
      }
    }

    setState(() => _isSaving = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;

      // Create doc first to get ID
      final entitlement = <String, dynamic>{
        'type': _entitlementType,
      };
      if (_entitlementType == 'Aylık') {
        entitlement['monthlyDayOfMonth'] = _monthlyDayOfMonth;
      } else if (_entitlementType == 'Aylık (İki Kere)') {
        final days = [_semiMonthlyDay1, _semiMonthlyDay2]..sort();
        entitlement['semiMonthlyDays'] = days;
      } else if (_entitlementType == 'Haftalık') {
        entitlement['weeklyWeekday'] = _weeklyWeekday;
      } else if (_entitlementType == 'Günlük') {
        entitlement['daysPerWeek'] = _daysPerWeek;
        entitlement['weeklyDays'] = List<String>.from(_weeklySelectedDays);
      }

      // Çalışma takvimi ve fazla mesai
      final Map<String, dynamic> schedule = {};
      // Work hours (only if daily or hourly with schedule enabled)
      if (_entitlementType == 'Günlük' ||
          (_entitlementType == 'Saatlik' && _hourlyScheduleEnabled)) {
        final workHours = <String, Map<String, String>>{};
        for (final d in _weekdays) {
          if (_dayEnabled[d] == true) {
            workHours[d] = {
              'start': _formatTimeOfDay(_startTimes[d]!),
              'end': _formatTimeOfDay(_endTimes[d]!),
            };
          }
        }
        schedule['workHours'] = workHours;

        if (_overtimeEnabled) {
          final threshold = double.tryParse(_overtimeThresholdHoursController
                  .text
                  .replaceAll(',', '.')) ??
              0;
          final multiplier = double.tryParse(
                  _overtimeMultiplierController.text.replaceAll(',', '.')) ??
              1.0;
          schedule['overtime'] = {
            'enabled': true,
            'thresholdHoursPerDay': threshold,
            'multiplier': multiplier,
          };
        } else {
          schedule['overtime'] = {'enabled': false};
        }
      }

      final docRef = await firestore.collection('employees').add({
        'name': _nameController.text.trim(),
        'tc': _tcController.text.trim(),
        'birthDate': Timestamp.fromDate(_birthDate!),
        'startDate': Timestamp.fromDate(_startDate!),
        'department': _selectedDepartment,
        'position': (_selectedPosition ?? _positionController.text.trim()),
        'category': _selectedCategory,
        'salary': {
          'amount': double.tryParse(
                  _salaryAmountController.text.replaceAll(',', '.')) ??
              0,
          'currency': _salaryCurrency,
        },
        'entitlement': entitlement,
        if (schedule.isNotEmpty) 'schedule': schedule,
        'photoUrl': null,
        'documents': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final String employeeId = docRef.id;
      String? photoUrl;
      final List<Map<String, dynamic>> docUrls = [];

      // Upload photo
      if (_photoBytes != null && _photoName != null) {
        final ref =
            storage.ref().child('employees/$employeeId/photo/$_photoName');
        final snap = await ref.putData(
          _photoBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        photoUrl = await snap.ref.getDownloadURL();
      }

      // Upload documents
      for (final d in _pickedDocs) {
        final ref = storage.ref().child('employees/$employeeId/docs/${d.name}');
        final contentType = d.name.toLowerCase().endsWith('.pdf')
            ? 'application/pdf'
            : 'image/jpeg';
        final snap = await ref.putData(
          d.bytes,
          SettableMetadata(contentType: contentType),
        );
        final url = await snap.ref.getDownloadURL();
        docUrls.add({'name': d.name, 'url': url});
      }

      // Update document with URLs
      await docRef.update({
        'photoUrl': photoUrl,
        'documents': docUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Personel başarıyla eklendi'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt sırasında hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Yeni Personel Ekle',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Kapat',
                    )
                  ],
                ),
                const SizedBox(height: 8),

                // Photo picker
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: _photoBytes != null
                          ? MemoryImage(_photoBytes!)
                          : null,
                      child: _photoBytes == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _pickPhoto,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Fotoğraf Seç'),
                    ),
                    const SizedBox(width: 12),
                    if (_photoBytes != null)
                      Expanded(
                        child: Tooltip(
                          message: _photoName ?? '',
                          child: Text(
                            _photoName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Saatlik: takvim bölümünü opsiyonel yap
                if (_entitlementType == 'Saatlik') ...[
                  SwitchListTile(
                    title: const Text('Çalışma Takvimi (opsiyonel)'),
                    value: _hourlyScheduleEnabled,
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _hourlyScheduleEnabled = v),
                  ),
                  if (_hourlyScheduleEnabled) ...[
                    const SizedBox(height: 6),
                    Text('Çalışma Saatleri',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Column(
                      children: _weekdays.map((d) {
                        final enabled = _dayEnabled[d] ?? false;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 140,
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: Text(d),
                                  value: enabled,
                                  onChanged: _isSaving
                                      ? null
                                      : (v) => setState(
                                          () => _dayEnabled[d] = v ?? false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _isSaving || !enabled
                                          ? null
                                          : () async {
                                              final picked =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: _startTimes[d]!,
                                              );
                                              if (picked != null) {
                                                setState(() =>
                                                    _startTimes[d] = picked);
                                              }
                                            },
                                      icon: const Icon(Icons.access_time),
                                      label: Text(
                                          _formatTimeOfDay(_startTimes[d]!)),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('—'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _isSaving || !enabled
                                          ? null
                                          : () async {
                                              final picked =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: _endTimes[d]!,
                                              );
                                              if (picked != null) {
                                                setState(() =>
                                                    _endTimes[d] = picked);
                                              }
                                            },
                                      icon:
                                          const Icon(Icons.access_time_filled),
                                      label:
                                          Text(_formatTimeOfDay(_endTimes[d]!)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Fazla Mesai Kuralları'),
                      value: _overtimeEnabled,
                      onChanged: _isSaving
                          ? null
                          : (v) => setState(() => _overtimeEnabled = v),
                    ),
                    if (_overtimeEnabled)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _overtimeThresholdHoursController,
                              decoration: const InputDecoration(
                                  labelText: 'Günlük Eşik (saat)'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _overtimeMultiplierController,
                              decoration: const InputDecoration(
                                  labelText: 'Çarpan (örn. 1.5)'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        ],
                      ),
                  ],
                ],

                // Name, TC
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'İsim Soyisim'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Zorunlu alan'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _tcController,
                        decoration: const InputDecoration(
                          labelText: 'TC',
                          counterText: '',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Zorunlu alan';
                          if (t.length != 11) return '11 haneli olmalı';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Birth date, Department
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _isSaving
                            ? null
                            : () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(
                                      now.year - 25, now.month, now.day),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime(now.year - 10),
                                );
                                if (picked != null) {
                                  setState(() => _birthDate = picked);
                                }
                              },
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'Doğum Tarihi'),
                          child: Text(
                            _birthDate == null
                                ? 'Seçiniz'
                                : '${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDepartment,
                        decoration:
                            const InputDecoration(labelText: 'Departman'),
                        items: _departmentsLive
                            .map((d) =>
                                DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (v) => setState(() => _selectedDepartment = v),
                        validator: (v) => v == null ? 'Zorunlu alan' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Kategori Ekle',
                      onPressed: _isSaving ? null : _openManageCategories,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Start date
                InkWell(
                  onTap: _isSaving
                      ? null
                      : () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(now.year + 1),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                  child: InputDecorator(
                    decoration:
                        const InputDecoration(labelText: 'İşe Başlama Tarihi'),
                    child: Text(
                      _startDate == null
                          ? 'Seçiniz'
                          : '${_startDate!.day.toString().padLeft(2, '0')}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.year}',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Position, Category
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPosition,
                        decoration:
                            const InputDecoration(labelText: 'Pozisyon'),
                        items: _positionsLive
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (v) => setState(() => _selectedPosition = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Pozisyon Ekle',
                      onPressed: _isSaving ? null : widget.onManagePositions,
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration:
                            const InputDecoration(labelText: 'Kategori'),
                        items: _categoriesLive
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (v) => setState(() => _selectedCategory = v),
                        validator: (v) => v == null ? 'Zorunlu alan' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Salary
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _salaryAmountController,
                        decoration:
                            const InputDecoration(labelText: 'Maaş Miktarı'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _salaryCurrency,
                        decoration:
                            const InputDecoration(labelText: 'Para Birimi'),
                        items: const ['TRY', 'USD', 'EUR']
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (v) =>
                                setState(() => _salaryCurrency = v ?? 'TRY'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Entitlement
                DropdownButtonFormField<String>(
                  initialValue: _entitlementType,
                  decoration: const InputDecoration(labelText: 'Hak Ediş'),
                  items: const [
                    'Saatlik',
                    'Günlük',
                    'Haftalık',
                    'Aylık',
                    'Aylık (İki Kere)'
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (v) => setState(() => _entitlementType = v ?? 'Aylık'),
                ),

                const SizedBox(height: 8),

                if (_entitlementType == 'Aylık')
                  DropdownButtonFormField<int>(
                    initialValue: _monthlyDayOfMonth,
                    decoration:
                        const InputDecoration(labelText: 'Ayın Günü (1-31)'),
                    items: List.generate(31, (i) => i + 1)
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text('$d')))
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _monthlyDayOfMonth = v),
                  ),

                if (_entitlementType == 'Aylık (İki Kere)')
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _semiMonthlyDay1,
                          decoration:
                              const InputDecoration(labelText: '1. Gün (1-31)'),
                          items: List.generate(31, (i) => i + 1)
                              .map((d) =>
                                  DropdownMenuItem(value: d, child: Text('$d')))
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) => setState(() => _semiMonthlyDay1 = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _semiMonthlyDay2,
                          decoration:
                              const InputDecoration(labelText: '2. Gün (1-31)'),
                          items: List.generate(31, (i) => i + 1)
                              .map((d) =>
                                  DropdownMenuItem(value: d, child: Text('$d')))
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (v) => setState(() => _semiMonthlyDay2 = v),
                        ),
                      ),
                    ],
                  ),

                if (_entitlementType == 'Haftalık')
                  DropdownButtonFormField<String>(
                    initialValue: _weeklyWeekday,
                    decoration:
                        const InputDecoration(labelText: 'Haftanın Günü'),
                    items: const [
                      'Pazartesi',
                      'Salı',
                      'Çarşamba',
                      'Perşembe',
                      'Cuma',
                      'Cumartesi',
                      'Pazar'
                    ]
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _weeklyWeekday = v),
                  ),

                if (_entitlementType == 'Günlük') ...[
                  DropdownButtonFormField<int>(
                    initialValue: _daysPerWeek,
                    decoration: const InputDecoration(
                        labelText: 'Haftada Kaç Gün Çalışır?'),
                    items: List.generate(7, (i) => i + 1)
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text('$d')))
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _daysPerWeek = v ?? 5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      'Pazartesi',
                      'Salı',
                      'Çarşamba',
                      'Perşembe',
                      'Cuma',
                      'Cumartesi',
                      'Pazar'
                    ]
                        .map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: FilterChip(
                                label: Text(d),
                                selected: _weeklySelectedDays.contains(d),
                                onSelected: _isSaving
                                    ? null
                                    : (sel) {
                                        setState(() {
                                          if (sel) {
                                            _weeklySelectedDays.add(d);
                                          } else {
                                            _weeklySelectedDays.remove(d);
                                          }
                                        });
                                      },
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  // Haftalık çalışma saatleri
                  Text('Çalışma Saatleri',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Column(
                    children: _weekdays.map((d) {
                      final enabled = _dayEnabled[d] ?? false;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(d),
                                value: enabled,
                                onChanged: _isSaving
                                    ? null
                                    : (v) => setState(
                                        () => _dayEnabled[d] = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _isSaving || !enabled
                                        ? null
                                        : () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _startTimes[d]!,
                                            );
                                            if (picked != null) {
                                              setState(() =>
                                                  _startTimes[d] = picked);
                                            }
                                          },
                                    icon: const Icon(Icons.access_time),
                                    label:
                                        Text(_formatTimeOfDay(_startTimes[d]!)),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('—'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _isSaving || !enabled
                                        ? null
                                        : () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: _endTimes[d]!,
                                            );
                                            if (picked != null) {
                                              setState(
                                                  () => _endTimes[d] = picked);
                                            }
                                          },
                                    icon: const Icon(Icons.access_time_filled),
                                    label:
                                        Text(_formatTimeOfDay(_endTimes[d]!)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Fazla mesai ayarları
                  SwitchListTile(
                    title: const Text('Fazla Mesai Kuralları'),
                    value: _overtimeEnabled,
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => _overtimeEnabled = v),
                  ),
                  if (_overtimeEnabled)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeThresholdHoursController,
                            decoration: const InputDecoration(
                                labelText: 'Günlük Eşik (saat)'),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _overtimeMultiplierController,
                            decoration: const InputDecoration(
                                labelText: 'Çarpan (örn. 1.5)'),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                ],

                const SizedBox(height: 16),

                // Documents
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _pickDocuments,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Döküman Ekle (PDF/PNG/JPG)'),
                    ),
                    const SizedBox(width: 12),
                    Text('${_pickedDocs.length} dosya seçildi'),
                  ],
                ),

                const SizedBox(height: 8),
                if (_pickedDocs.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _pickedDocs
                        .map((d) => Chip(
                              label: Text(d.name),
                              onDeleted: _isSaving
                                  ? null
                                  : () {
                                      setState(() => _pickedDocs.remove(d));
                                    },
                            ))
                        .toList(),
                  ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Vazgeç'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: const Text('Kaydet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedDoc {
  final String name;
  final Uint8List bytes;
  _PickedDoc({required this.name, required this.bytes});
}

// Removed helper chip; using inline FilterChip with parent setState
