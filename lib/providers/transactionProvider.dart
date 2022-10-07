import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';


class TransactionProvider with ChangeNotifier {
  bool _isPaying = false;

  bool get isPaying => _isPaying;

  setIsPaying(bool v) {
    _isPaying = v;

    notifyListeners();
  }

  updateTransactionsDB(Account account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String transactionsString = prefs.getString("${account.userID}_transactions") ?? "";

    List<account_transaction.Transaction> transactions = account_transaction.Transaction.decode(transactionsString);

    transactions.sort((a, b)=> a.timestamp!.compareTo(b.timestamp!));

    var transactionsTimestamp = transactions.isEmpty ? 0 : transactions.last.timestamp;

    await FirebaseFirestore.instance.collection("users").doc(account.userID)
        .collection("transactions").where("timestamp", isGreaterThan: transactionsTimestamp)
        .orderBy("timestamp", descending: false).get().then((querySnapshot) async {
          querySnapshot.docs.forEach((element) {
            transactions.add(account_transaction.Transaction.fromDocument(element));
          });

          final String encodedData = account_transaction.Transaction.encode(transactions);

          await prefs.setString("${account.userID}_transactions", encodedData);

          notifyListeners();
    });
  }

  Future<List<TransactionGroup>> getGroupedTenantTransactions(Account account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String transactionsString = prefs.getString("${account.userID}_transactions") ?? "";

    List<account_transaction.Transaction> transactions = account_transaction.Transaction.decode(transactionsString);

    //sort
    transactions.sort((a, b)=> a.timestamp!.compareTo(b.timestamp!));

    var newMap = transactions.groupListsBy((element) => element.paymentCategory);

    List<TransactionGroup> transactionGroups = newMap.entries.map((e) => TransactionGroup(paymentCategory: e.key, transactions: e.value)).toList();

    transactionGroups.sort((a, b) => a.transactions!.last.timestamp!.compareTo(b.transactions!.last.timestamp!));

    return transactionGroups.reversed.toList();
  }

  Future<List<ChatData>> getGroupedLandlordTransactions(Account account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String transactionsString = prefs.getString("${account.userID}_transactions") ?? "";

    List<account_transaction.Transaction> transactions = account_transaction.Transaction.decode(transactionsString);

    //sort
    transactions.sort((a, b)=> a.timestamp!.compareTo(b.timestamp!));

    List<ChatData> chatDataList = [];

    var transactionsMap = transactions.groupListsBy((element) => DateFormat("MMM").format(DateTime.fromMillisecondsSinceEpoch(element.timestamp!)));

    //Lets use paymentCategory as month*********************
    List<TransactionGroup> transactionGroups = transactionsMap.entries.map((e) => TransactionGroup(paymentCategory: e.key, transactions: e.value)).toList();

    for (var element in transactionGroups) {
      int incomeAmount = 0;
      int expenseAmount = 0;

      for(var trans in element.transactions!) {
        if(trans.paymentCategory == "Rent")
          {
            incomeAmount = incomeAmount + trans.paidAmount!;
          }
        else
          {
            expenseAmount = expenseAmount + trans.paidAmount!;
          }
      }

      ChatData data = ChatData(
        month: element.paymentCategory,
        incomeAmount: incomeAmount,
        expenseAmount: expenseAmount,
      );

      chatDataList.add(data);
    }

    return chatDataList;
  }

  Future<List<account_transaction.Transaction>> getAllTransactions(Account account) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String transactionsString = prefs.getString("${account.userID}_transactions") ?? "";

    List<account_transaction.Transaction> transactions = account_transaction.Transaction.decode(transactionsString);

    //sort
    transactions.sort((a, b)=> a.timestamp!.compareTo(b.timestamp!));

    return transactions.reversed.toList();
  }

}

class TransactionGroup {
  final String? paymentCategory;
  final List<account_transaction.Transaction>? transactions;

  TransactionGroup({this.paymentCategory, this.transactions});
}

class ChatData {
  final String? month;
  final int? incomeAmount;
  final int? expenseAmount;

  ChatData({this.month, this.incomeAmount, this.expenseAmount});
}