import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_providers.dart';
import 'account_detail_page.dart';

/// Account Detail Page Wrapper - ID'den Account yükler
class AccountDetailPageWrapper extends ConsumerWidget {
  final String accountId;

  const AccountDetailPageWrapper({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(accountByIdProvider(accountId));

    return accountAsync.when(
      data: (account) {
        if (account == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Hesap Bulunamadı'),
            ),
            body: const Center(
              child: Text('Hesap bulunamadı'),
            ),
          );
        }
        return AccountDetailPage(account: account);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Hata'),
        ),
        body: Center(
          child: Text('Hesap yüklenirken hata oluştu: $error'),
        ),
      ),
    );
  }
}
