import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as model;
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import 'add_transaction_screen.dart';
import 'chart_screen.dart';
import 'login_screen.dart';

/// Main home screen showing balance summary and transaction list.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _transactionService = TransactionService();

  /// Returns the current user's ID.
  String get _userId => _authService.currentUser!.uid;

  /// Signs out the user and navigates to the login screen.
  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  /// Calculates the net balance from a list of transactions.
  double _getBalance(List<model.Transaction> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return t.isExpense ? sum - t.amount : sum + t.amount;
    });
  }

  /// Calculates total expenses from a list of transactions.
  double _getExpenses(List<model.Transaction> transactions) {
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculates total income from a list of transactions.
  double _getIncome(List<model.Transaction> transactions) {
    return transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Finances',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChartScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder<List<model.Transaction>>(
        stream: _transactionService.getTransactions(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
          }
          final transactions = snapshot.data ?? [];
          final balance = _getBalance(transactions);
          final expenses = _getExpenses(transactions);
          final income = _getIncome(transactions);

          return Column(
            children: [
              // Balance card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('£${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryTile('Income', income, Colors.greenAccent),
                        _summaryTile('Expenses', expenses, Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),

              // Transaction list header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recent Transactions',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              // Transaction list
              Expanded(
                child: transactions.isEmpty
                    ? const Center(
                        child: Text('No transactions yet.',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          return _transactionTile(t);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTransactionScreen(userId: _userId))),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Builds an income/expense summary tile for the balance card.
  Widget _summaryTile(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text('£${amount.toStringAsFixed(2)}',
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// Builds a single transaction list tile with delete functionality.
  Widget _transactionTile(model.Transaction t) {
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          _transactionService.deleteTransaction(_userId, t.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: t.isExpense
              ? Colors.redAccent.withValues(alpha: 0.2)
              : Colors.greenAccent.withValues(alpha: 0.2),
          child: Icon(
            t.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: t.isExpense ? Colors.redAccent : Colors.greenAccent,
          ),
        ),
        title: Text(t.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(
            '${t.category} · ${DateFormat('dd MMM yyyy').format(t.date)}',
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: Text(
          '${t.isExpense ? '-' : '+'}£${t.amount.toStringAsFixed(2)}',
          style: TextStyle(
              color: t.isExpense ? Colors.redAccent : Colors.greenAccent,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}