import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() async {
    final data = await _dbService.getExpenses();
    setState(() {
      _expenses = data;
    });
  }

  void _addExpense(Map<String, dynamic> data) async {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      title: data['title'],
      amount: data['amount'],
      category: data['category'],
      date: data['date'],
    );
    _expenses.insert(0, newExpense);
    await _dbService.saveExpenses(_expenses);
    setState(() {});
  }

  void _deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _dbService.saveExpenses(_expenses);
    setState(() {});
  }

  double get _totalSpent => _expenses.fold(0.0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Total Spending Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('Total Spending', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '\$${_totalSpent.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Expenses List / Empty State
          Expanded(
            child: _expenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses added yet!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (ctx, i) => ExpenseCard(
                      expense: _expenses[i],
                      onDelete: () => _deleteExpense(_expenses[i].id),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (result != null) _addExpense(result);
        },
      ),
    );
  }
}