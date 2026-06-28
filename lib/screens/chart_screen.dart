import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart' as model;
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

/// Screen displaying spending breakdown by category using a pie chart.
class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final transactionService = TransactionService();
    final userId = authService.currentUser!.uid;

    /// Map of category colours for chart segments.
    const categoryColors = {
      'Food': Color(0xFF6C63FF),
      'Transport': Color(0xFFFF6584),
      'Shopping': Color(0xFFFFD166),
      'Bills': Color(0xFF06D6A0),
      'Entertainment': Color(0xFFEF476F),
      'Health': Color(0xFF118AB2),
      'Other': Color(0xFF073B4C),
    };

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Spending Breakdown',
            style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<model.Transaction>>(
        stream: transactionService.getTransactions(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
          }

          // Filter expenses only and group by category
          final expenses =
              snapshot.data!.where((t) => t.isExpense).toList();
          final Map<String, double> categoryTotals = {};
          for (final t in expenses) {
            categoryTotals[t.category] =
                (categoryTotals[t.category] ?? 0) + t.amount;
          }

          if (categoryTotals.isEmpty) {
            return const Center(
                child: Text('No expense data yet.',
                    style: TextStyle(color: Colors.white54)));
          }

          final total =
              categoryTotals.values.fold(0.0, (sum, v) => sum + v);

          // Build pie chart sections
          final sections = categoryTotals.entries.map((entry) {
            final pct = (entry.value / total * 100);
            return PieChartSectionData(
              color: categoryColors[entry.key] ?? Colors.grey,
              value: entry.value,
              title: '${pct.toStringAsFixed(1)}%',
              radius: 100,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: PieChart(PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 3,
                  )),
                ),
                const SizedBox(height: 32),
                // Legend
                ...categoryTotals.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: categoryColors[entry.key] ?? Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key,
                                style: const TextStyle(color: Colors.white70)),
                          ]),
                          Text('£${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}