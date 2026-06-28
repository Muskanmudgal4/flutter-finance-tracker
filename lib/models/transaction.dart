/// Represents a financial transaction in the app.
class Transaction {
  /// Unique identifier for the transaction (Firestore document ID).
  final String id;

  /// Title or description of the transaction (e.g. "Groceries").
  final String title;

  /// Amount spent or earned.
  final double amount;

  /// Category of the transaction (e.g. "Food", "Transport", "Shopping").
  final String category;

  /// Whether this is an expense (true) or income (false).
  final bool isExpense;

  /// Date and time of the transaction.
  final DateTime date;

  /// User ID of the owner of this transaction.
  final String userId;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isExpense,
    required this.date,
    required this.userId,
  });

  /// Converts a Firestore document snapshot into a [Transaction] object.
  factory Transaction.fromMap(String id, Map<String, dynamic> map) {
    return Transaction(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? 'Other',
      isExpense: map['isExpense'] ?? true,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      userId: map['userId'] ?? '',
    );
  }

  /// Converts this [Transaction] into a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'isExpense': isExpense,
      'date': date.millisecondsSinceEpoch,
      'userId': userId,
    };
  }
}

/// Available spending categories.
const List<String> kCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Entertainment',
  'Health',
  'Other',
];