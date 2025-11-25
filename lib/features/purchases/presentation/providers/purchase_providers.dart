import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tamgaci/features/purchases/data/datasources/purchase_firebase_datasource.dart';
import 'package:tamgaci/features/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:tamgaci/features/purchases/domain/usecases/create_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/get_purchases_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/get_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/update_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/delete_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/get_purchases_statistics_usecase.dart';
import 'package:tamgaci/features/purchases/domain/usecases/duplicate_purchase_usecase.dart';
import 'package:tamgaci/features/purchases/presentation/notifiers/purchase_notifier.dart';
import 'package:tamgaci/features/purchases/presentation/states/purchase_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Firebase Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Purchase Firebase DataSource provider
final purchaseFirebaseDataSourceProvider =
    Provider<PurchaseFirebaseDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return PurchaseFirebaseDataSource(firestore, firebaseAuth);
});

/// Purchase Repository provider
final purchaseRepositoryProvider = Provider<PurchaseRepositoryImpl>((ref) {
  ref.watch(authProvider);
  final dataSource = ref.watch(purchaseFirebaseDataSourceProvider);
  return PurchaseRepositoryImpl(dataSource: dataSource);
});

/// Create Purchase UseCase provider
final createPurchaseUseCaseProvider = Provider<CreatePurchaseUseCase>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return CreatePurchaseUseCase(repository);
});

/// Get Purchases UseCase provider
final getPurchasesUseCaseProvider = Provider<GetPurchasesUseCase>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return GetPurchasesUseCase(repository);
});

/// Get Purchase UseCase provider
final getPurchaseUseCaseProvider = Provider<GetPurchaseUseCase>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return GetPurchaseUseCase(repository);
});

/// Update Purchase UseCase provider
final updatePurchaseUseCaseProvider = Provider<UpdatePurchaseUseCase>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return UpdatePurchaseUseCase(repository);
});

/// Delete Purchase UseCase provider
final deletePurchaseUseCaseProvider = Provider<DeletePurchaseUseCase>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return DeletePurchaseUseCase(repository);
});

/// Get Purchases Statistics UseCase provider
final getPurchasesStatisticsUseCaseProvider =
    Provider<GetPurchasesStatisticsUseCase>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return GetPurchasesStatisticsUseCase(repository);
});

/// Duplicate Purchase UseCase provider
final duplicatePurchaseUseCaseProvider =
    Provider<DuplicatePurchaseUseCase>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return DuplicatePurchaseUseCase(repository);
});

/// Purchase Notifier provider
final purchaseNotifierProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  final createPurchaseUseCase = ref.watch(createPurchaseUseCaseProvider);
  final getPurchasesUseCase = ref.watch(getPurchasesUseCaseProvider);
  final getPurchaseUseCase = ref.watch(getPurchaseUseCaseProvider);
  final updatePurchaseUseCase = ref.watch(updatePurchaseUseCaseProvider);
  final deletePurchaseUseCase = ref.watch(deletePurchaseUseCaseProvider);
  final getPurchasesStatisticsUseCase =
      ref.watch(getPurchasesStatisticsUseCaseProvider);
  final duplicatePurchaseUseCase = ref.watch(duplicatePurchaseUseCaseProvider);

  return PurchaseNotifier(
    createPurchaseUseCase: createPurchaseUseCase,
    getPurchasesUseCase: getPurchasesUseCase,
    getPurchaseUseCase: getPurchaseUseCase,
    updatePurchaseUseCase: updatePurchaseUseCase,
    deletePurchaseUseCase: deletePurchaseUseCase,
    getPurchasesStatisticsUseCase: getPurchasesStatisticsUseCase,
    duplicatePurchaseUseCase: duplicatePurchaseUseCase,
  );
});

/// Customer purchases stream provider
final customerPurchasesStreamProvider =
    StreamProvider.family<List<dynamic>, String>((ref, customerId) async* {
  ref.watch(authProvider);
  try {
    final firestore = ref.watch(firestoreProvider);
    final auth = ref.watch(firebaseAuthProvider);
    final user = auth.currentUser;

    if (user == null) {
      yield [];
      return;
    }

    // Kullanıcının tenant ID'sini al
    final userDoc = await firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      yield [];
      return;
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final tenantId = userData['tenantId'] as String?;

    if (tenantId == null || tenantId.isEmpty) {
      yield [];
      return;
    }

    // Müşteriye ait alışları getir (satış iadeleri supplierId alanına yazılıyor)
    final snap = await firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('purchases')
        .where('supplierId', isEqualTo: customerId)
        .get();

    final purchases = snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList()
      ..sort((a, b) {
        final aDate = (a['createdAt'] as Timestamp?)?.toDate();
        final bDate = (b['createdAt'] as Timestamp?)?.toDate();
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

    yield purchases;
  } catch (e) {
    debugPrint('Error loading customer purchases: $e');
    yield [];
  }
});
