import 'package:flutter/material.dart';
import '../models/transaction.dart' as model;
import '../services/transaction_service.dart';


/// Screen for adding a new income or expense transaction.
class AddTransactionScreen extends StatefulWidget {
  /// The ID of the currently authenticated user.
  final String userId;

  const AddTransactionScreen({super.key, required this.userId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _transactionService = TransactionService();

String _selectedCategory = model.kCategories.first;
  bool _isExpense = true;
  bool _isLoading = false;

  /// Saves the transaction to Firestore and pops the screen.
  Future<void> _save() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (title.isEmpty || amount == null || amount <= 0) return;

    setState(() => _isLoading = true);
    try {
      final transaction = model.Transaction(
        id: '',
        title: title,
        amount: amount,
        category: _selectedCategory,
        isExpense: _isExpense,
        date: DateTime.now(),
        userId: widget.userId,
      );
      await _transactionService.addTransaction(widget.userId, transaction);
      if (mounted) Navigator.pop(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Transaction',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income / Expense toggle
            Row(
              children: [
                _typeButton('Expense', true),
                const SizedBox(width: 12),
                _typeButton('Income', false),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(_titleController, 'Title (e.g. Groceries)'),
            const SizedBox(height: 16),
            _buildTextField(_amountController, 'Amount (£)',
                inputType: TextInputType.number),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              dropdownColor: const Color(0xFF16213E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF16213E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: model.kCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Transaction',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the expense/income type selector button.
  Widget _typeButton(String label, bool isExpense) {
    final selected = _isExpense == isExpense;
    return GestureDetector(
      onTap: () => setState(() => _isExpense = isExpense),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6C63FF) : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  /// Builds a styled text input field.
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}