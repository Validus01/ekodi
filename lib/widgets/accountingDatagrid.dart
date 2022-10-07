import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/providers/transactionProvider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;

import '../model/account.dart';


class AccountingDataGrid extends StatefulWidget {
  const AccountingDataGrid({Key? key}) : super(key: key);

  @override
  State<AccountingDataGrid> createState() => _AccountingDataGridState();
}

class _AccountingDataGridState extends State<AccountingDataGrid> {
  late TransactionDataGridSource transactionDataGridSource;

  @override
  void initState() {
    super.initState();
    getTransactions();
  }

  getTransactions() async {

    Account account = Provider.of<EKodi>(context, listen: false).account;

    await TransactionProvider().updateTransactionsDB(account);

    transactionDataGridSource = TransactionDataGridSource(account);
  }

  Widget _buildDataGrid(bool isDesktop) {
    return FutureBuilder<String>(
      future: Future<String>.delayed(
          const Duration(milliseconds: 500), () => 'Loaded'),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          {
            return const Text("Loading...");
          }
        else
          {
            return SfDataGrid(
              source: transactionDataGridSource,
              columnWidthMode: ColumnWidthMode.fill,
              rowHeight: 50,
              columns: <GridColumn>[
                GridColumn(
                  columnName: 'name',
                  width: !isDesktop ? 90 : double.nan,
                  label: Container(
                    alignment: Alignment.centerLeft,
                    child: const Text('Name'),
                  ),
                ),
                GridColumn(
                  columnName: 'accType',
                  label: const Center(
                    child: Text('Account Type',),
                  ),
                ),
                GridColumn(
                    columnName: 'transactionType',
                    label: const Center(
                      child: Text('Transaction Type',),
                    )),
                GridColumn(
                    columnName: 'amount',
                    label: const Center(child: Text('Amount'))),
                GridColumn(
                  columnName: 'paymentFreq',
                  label: const Center(child: Text('Payment Frequency')),
                ),
              ],
            );
          }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isDesktop = sizeInfo.isDesktop;
        return _buildDataGrid(isDesktop);
      },
    );
  }
}

class TransactionDataGridSource extends DataGridSource {

  List<account_transaction.Transaction> transactions = [];

  List<DataGridRow> dataGridRows = <DataGridRow>[];

  /// Creates the team data source class with required details.
  TransactionDataGridSource(Account account) {
    _populateData(account);
  }

  Future<void> _populateData(Account account) async {
    transactions = await TransactionProvider().getAllTransactions(account);
    buildDataGridRows();
  }

  /// Building DataGridRows
  void buildDataGridRows() {
    dataGridRows = transactions.map<DataGridRow>((account_transaction.Transaction transaction) {
      return DataGridRow(cells: <DataGridCell>[
        // DataGridCell<String>(columnName: 'name', value: transaction.userInfo!['name']),
        // DataGridCell<String>(columnName: 'accType', value: transaction.userInfo!['accountType']),
        // DataGridCell<String>(columnName: 'transactionType', value: transaction.transactionType!),
        // DataGridCell<int>(columnName: 'amount', value: transaction.amount),
        // DataGridCell<String>(columnName: 'paymentFreq', value: transaction.paymentFreq),
      ]);
    }).toList();
  }

  // Overrides
  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((DataGridCell dataCell) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(dataCell.value.toString()),
          );
        }).toList());
  }

}
