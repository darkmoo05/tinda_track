import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../core/database/app_database.dart';
import '../../../../core/di/database_providers.dart';

enum OnboardingStep {
  inactive,
  welcome,
  setupCapitalPrompt,
  addCapitalForm,
  tapFabPrompt,
  addTxForm,
  explainDeltas,
  explainChargesPrompt,
  chargesScreenPrompt,
  demoDataPrompt,
  completed,
}

class OnboardingState {
  final OnboardingStep step;
  final bool hasDemoData;

  const OnboardingState({
    required this.step,
    required this.hasDemoData,
  });

  OnboardingState copyWith({
    OnboardingStep? step,
    bool? hasDemoData,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      hasDemoData: hasDemoData ?? this.hasDemoData,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._ref)
      : super(const OnboardingState(
          step: OnboardingStep.inactive,
          hasDemoData: false,
        )) {
    _checkInitialStatus();
  }

  final Ref _ref;

  Future<void> _checkInitialStatus() async {
    try {
      final appMetaDao = _ref.read(databaseAppMetaDaoProvider);
      final completed = await appMetaDao.get('tutorial_completed_pocket_ledger');
      if (completed != 'true') {
        // Start showing welcome tour if they have no transactions
        final db = _ref.read(currentAppDatabaseProvider);
        final txs = await db.select(db.transactions).get();
        if (txs.isEmpty) {
          state = state.copyWith(step: OnboardingStep.welcome);
        }
      }
    } catch (_) {}
  }

  void startTour() {
    state = state.copyWith(step: OnboardingStep.setupCapitalPrompt);
  }

  void nextStep() {
    final nextIndex = state.step.index + 1;
    if (nextIndex < OnboardingStep.values.length) {
      setStep(OnboardingStep.values[nextIndex]);
    } else {
      completeTour();
    }
  }

  void setStep(OnboardingStep step) {
    if (step == OnboardingStep.demoDataPrompt && !state.hasDemoData) {
      completeTour();
    } else {
      state = state.copyWith(step: step);
    }
  }

  void setHasDemoData(bool value) {
    state = state.copyWith(hasDemoData: value);
  }

  Future<void> completeTour() async {
    state = state.copyWith(step: OnboardingStep.completed);
    try {
      await _ref.read(databaseAppMetaDaoProvider).set('tutorial_completed_pocket_ledger', 'true');
    } catch (_) {}
  }

  Future<void> resetTour() async {
    try {
      await _ref.read(databaseAppMetaDaoProvider).set('tutorial_completed_pocket_ledger', 'false');
      await clearSampleData();
      state = const OnboardingState(
        step: OnboardingStep.welcome,
        hasDemoData: false,
      );
    } catch (_) {}
  }

  Future<void> clearSampleData() async {
    try {
      final db = _ref.read(currentAppDatabaseProvider);
      
      // 1. Get transactions sync IDs to delete related fees
      final sampleRefs = ['CAP-INITIAL-3D', 'SAMPLE-REF-CASHIN-2D', 'SAMPLE-REF-CASHOUT-1D'];
      final sampleTxs = await (db.select(db.ledgerEntries)
            ..where((l) => l.reference.isIn(sampleRefs)))
          .get();
      
      final syncIds = sampleTxs.map((l) => l.id).toList();

      await db.transaction(() async {
        // Delete related fees
        if (syncIds.isNotEmpty) {
          await (db.delete(db.feeTransactions)
                ..where((f) => f.relatedTransactionSyncId.isIn(syncIds)))
              .go();
        }

        // Delete transactions
        await (db.delete(db.transactions)
              ..where((t) => t.reference.isIn(sampleRefs)))
            .go();

        // Delete ledger entries
        await (db.delete(db.ledgerEntries)
              ..where((l) => l.reference.isIn(sampleRefs)))
            .go();
      });

      state = state.copyWith(hasDemoData: false);
      if (state.step == OnboardingStep.demoDataPrompt) {
        completeTour();
      }
    } catch (_) {}
  }

  Future<void> promoteDemoDataToReal() async {
    try {
      final db = _ref.read(currentAppDatabaseProvider);
      final sampleRefs = ['CAP-INITIAL-3D', 'SAMPLE-REF-CASHIN-2D', 'SAMPLE-REF-CASHOUT-1D'];
      
      // Update local dirty flags so they will sync to backend
      await db.transaction(() async {
        await (db.update(db.transactions)..where((t) => t.reference.isIn(sampleRefs)))
            .write(const TransactionsCompanion(isDirty: Value(true)));

        await (db.update(db.ledgerEntries)..where((l) => l.reference.isIn(sampleRefs)))
            .write(const LedgerEntriesCompanion(isDirty: Value(true)));

        final sampleTxs = await (db.select(db.ledgerEntries)
              ..where((l) => l.reference.isIn(sampleRefs)))
            .get();
        final syncIds = sampleTxs.map((l) => l.id).toList();

        if (syncIds.isNotEmpty) {
          await (db.update(db.feeTransactions)
                ..where((f) => f.relatedTransactionSyncId.isIn(syncIds)))
              .write(const FeeTransactionsCompanion(isDirty: Value(true)));
        }
      });

      state = state.copyWith(hasDemoData: false);
      if (state.step == OnboardingStep.demoDataPrompt) {
        completeTour();
      }
    } catch (_) {}
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(ref);
});

class OnboardingKeys {
  final welcomeKey = GlobalKey(debugLabel: 'welcomeKey');
  final topUpButtonKey = GlobalKey(debugLabel: 'topUpButtonKey');
  final fabButtonKey = GlobalKey(debugLabel: 'fabButtonKey');
  final walletGridKey = GlobalKey(debugLabel: 'walletGridKey');
  final chargesTabKey = GlobalKey(debugLabel: 'chargesTabKey');
  final chargesWithdrawableKey = GlobalKey(debugLabel: 'chargesWithdrawableKey');
  final chargesHeroKey = GlobalKey(debugLabel: 'chargesHeroKey');
  final chargesHandlingKey = GlobalKey(debugLabel: 'chargesHandlingKey');
  final manageEarningsButtonKey = GlobalKey(debugLabel: 'manageEarningsButtonKey');
  final demoModeBannerKey = GlobalKey(debugLabel: 'demoModeBannerKey');
}

final onboardingKeysProvider = Provider<OnboardingKeys>((ref) {
  return OnboardingKeys();
});

