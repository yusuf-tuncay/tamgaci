// KULLANILMIYOR - Bu modül aktif değil
// Aktif modül: lib/features/warehouses/
// Bu dosya sadece referans amaçlı tutulmuştur

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/warehouse.dart';
import '../../../products/domain/entities/product.dart';
import '../../../cash_management/domain/entities/cash_account.dart';

/// Ürün Gönderme Sayfası (Bu depodan başka depoya)
/// KULLANILMIYOR - Bu modül aktif değil
class TransferProductFromWarehousePage extends ConsumerStatefulWidget {
  final Warehouse sourceWarehouse;

  const TransferProductFromWarehousePage({
    super.key,
    required this.sourceWarehouse,
  });

  @override
  ConsumerState<TransferProductFromWarehousePage> createState() =>
      _TransferProductFromWarehousePageState();
}

class _TransferProductFromWarehousePageState
    extends ConsumerState<TransferProductFromWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  Warehouse? _selectedToWarehouse;
  Product? _selectedProduct;
  CashAccount? _selectedCashAccount;
  final bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('KULLANILMIYOR - Bu modül aktif değil'),
      ),
    );
  }
}
