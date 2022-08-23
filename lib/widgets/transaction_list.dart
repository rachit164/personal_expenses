import 'package:flutter/material.dart';
import 'package:flutter_guide/widgets/transaction_item.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  const TransactionList(
    this.transactions,
    this.deleteTx, {
    Key? key,
  }) : super(key: key);
  final List<Transaction> transactions;
  final Function deleteTx;
  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? LayoutBuilder(
      builder: (ctx, constraints){
        return Column(
          children: [
            Text(
              'No transactions added yet',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: constraints.maxHeight * 0.6,
              child: Image.asset(
                'assets/images/waiting.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        );
      },

        )
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (BuildContext context, int index) {
              return TransactionItem(transaction: transactions[index], deleteTx: deleteTx);
            },
          );
  }
}

