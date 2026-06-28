import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as model;

/// Handles all Firestore operations for transactions.
class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a reference to the transactions collection for a given [userId].
  CollectionReference _userTransactions(String userId) =>
      _db.collection('users').doc(userId).collection('transactions');

  /// Streams all transactions for [userId], ordered by date descending.
  Stream<List<model.Transaction>> getTransactions(String userId) {
    return _userTransactions(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.Transaction.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Adds a new [transaction] to Firestore for [userId].
  Future<void> addTransaction(
      String userId, model.Transaction transaction) async {
    await _userTransactions(userId).add(transaction.toMap());
  }

  /// Deletes a transaction by [transactionId] for [userId].
  Future<void> deleteTransaction(
      String userId, String transactionId) async {
    await _userTransactions(userId).doc(transactionId).delete();
  }

  /// Returns total income for [userId] this month.
  Future<double> getMonthlyIncome(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final snapshot = await _userTransactions(userId)
        .where('isExpense', isEqualTo: false)
        .where('date',
            isGreaterThanOrEqualTo:
                startOfMonth.millisecondsSinceEpoch)
        .get();
    return snapshot.docs.fold<double>(0.0,
        (sum, doc) => sum + ((doc.data() as Map)['amount'] as num).toDouble());
  }

  /// Returns total expenses for [userId] this month.
  Future<double> getMonthlyExpenses(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final snapshot = await _userTransactions(userId)
        .where('isExpense', isEqualTo: true)
        .where('date',
            isGreaterThanOrEqualTo:
                startOfMonth.millisecondsSinceEpoch)
        .get();
    return snapshot.docs.fold<double>(0.0,
        (sum, doc) => sum + ((doc.data() as Map)['amount'] as num).toDouble());
  }
}