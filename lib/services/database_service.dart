import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class DatabaseService {
  static const String _key = 'expenses_key';

  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_key);
    if (list == null) return [];
    return list.map((item) => Expense.fromJson(item)).toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList = expenses.map((e) => e.toJson()).toList();
    await prefs.setStringList(_key, stringList);
  }
}