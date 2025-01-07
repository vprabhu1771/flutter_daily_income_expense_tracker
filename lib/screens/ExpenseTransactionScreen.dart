import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Transaction.dart';
import '../utils/Constants.dart';

class ExpenseTransactionScreen extends StatefulWidget {

  final String title;

  const ExpenseTransactionScreen({super.key, required this.title});

  @override
  State<ExpenseTransactionScreen> createState() => _ExpenseTransactionScreenState();
}

class _ExpenseTransactionScreenState extends State<ExpenseTransactionScreen> {

  List<Transaction> transactions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http
          .get(Uri.parse(Constants.BASE_URL + Constants.EXPENSE_TRANSACTION_ROUTE));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];

        setState(() {
          transactions = data.map((row) => Transaction.fromJson(row)).toList();
          isLoading = false;
        });
      } else {
        showError('Failed to load transactions.');
        throw Exception('Failed to load transactions. ' +
            Constants.BASE_URL +
            Constants.EXPENSE_TRANSACTION_ROUTE);
      }
    } catch (e) {
      showError('An error occurred while fetching transactions: $e');
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : transactions.isEmpty
          ? Center(child: Text('No transactions found.'))
          : ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final row = transactions[index];
            // print(row);

            return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: Icon(
                    row.type == 'INCOME'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: row.type == 'INCOME'
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    '${row.type}: \$${row.amount}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(row.description),
                  trailing: Text(row.date),
                ));
          }),
    );
  }
}
