import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:rekodi/widgets/dateSelector.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../APIs/pdfInvoiceApi.dart';
import '../../model/account.dart';
import '../../model/report.dart';
import '../../model/transaction.dart' as my;
import '../../providers/datePeriod.dart';

class IncomeExpenseStatement extends StatefulWidget {
  const IncomeExpenseStatement({Key? key}) : super(key: key);

  @override
  State<IncomeExpenseStatement> createState() => _IncomeExpenseStatementState();
}

class _IncomeExpenseStatementState extends State<IncomeExpenseStatement> {
  List<dynamic> properties = [];
  List<dynamic> selectedProperties = [];
  bool loading = false;
  bool isPayableByTenant = true;
  List<String> paymentCategories = ["Damages", "Deposit", "Rent"];
  List<dynamic> selectedPaymentCategories = [];
  List<my.Transaction> allTransactions = [];

  @override
  void initState() {
    getProperties();
    super.initState();
  }

  getProperties() async {
    setState(() {
      loading = true;
    });

    String userID = Provider.of<EKodi>(context, listen: false).account.userID!;

    await FirebaseFirestore.instance
        .collection("properties")
        .where("publisherID", isEqualTo: userID)
        .get()
        .then((querySnapshot) {
      for (var element in querySnapshot.docs) {
        properties.add(Property.fromDocument(element));
      }
    });

    setState(() {
      loading = false;
    });
  }

  void runReport(Account account, int startDate, int endDate) async {
    setState(() {
      allTransactions.clear();
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(account.userID)
        .collection("transactions")
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        my.Transaction transaction = my.Transaction.fromDocument(element);

        allTransactions.add(transaction);
      });
    });

    if (allTransactions.isEmpty) {
      Fluttertoast.showToast(msg: "There are no transactions in this period ");
    }

    setState(() {});
  }

  generateReport(
    Account account,
    int startDate,
    int endDate,
  ) async {
    setState(() {
      loading = true;
    });

    String period = DateFormat("dd MMM yyyy")
            .format(DateTime.fromMillisecondsSinceEpoch(startDate)) +
        " - " +
        DateFormat("dd MMM yyyy")
            .format(DateTime.fromMillisecondsSinceEpoch(endDate));

    final String downloadUrl = await PdfInvoiceApi.generaterIncomeExpenseReport(
        account, "Income Expense \nStatement", period, allTransactions);

    int timestamp = DateTime.now().millisecondsSinceEpoch;

    Report report = Report(
        reportID: timestamp.toString(),
        name: "Income Expense Statement",
        url: downloadUrl,
        timestamp: timestamp,
        period: period);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(account.userID)
        .collection("reports")
        .doc(timestamp.toString())
        .set(report.toMap())
        .then((value) =>
            Fluttertoast.showToast(msg: "Report generated Successfully!"));

    setState(() {
      loading = false;
    });
  }

  Widget _buildForDesktop(BuildContext context, Size size, Account account,
      int startDate, int endDate) {
    return loading
        ? const LoadingAnimation()
        : Container(
            margin: const EdgeInsets.only(top: 20.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      spreadRadius: 1.0,
                      offset: Offset(0.0, 0.0))
                ],
                border: Border.all(width: 0.5, color: Colors.grey.shade300)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () =>
                            context.read<TabProvider>().changeTab("Reports"),
                        child: Container(
                          height: 30.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border.all(
                                  color: EKodi.themeColor, width: 1.0)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Center(
                                child: Text(
                              "Back",
                              style: TextStyle(color: EKodi.themeColor),
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        "Income Expense Statement",
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                  ),
                  CustomDropDown(
                    items: properties,
                    selectedItems: selectedProperties,
                    title: "Select Properties",
                    isMultiselect: true,
                    onMultiChanged: (v) {
                      setState(() {
                        selectedProperties = v;
                      });
                    },
                    hintText: "Select Properties",
                    labelText: "Properties",
                    itemAsString: (u) => u.name,
                  ),
                  CustomDropDown(
                    items: paymentCategories,
                    selectedItems: selectedPaymentCategories,
                    title: "Payment Categories",
                    isMultiselect: true,
                    onMultiChanged: (v) {
                      setState(() {
                        selectedPaymentCategories = v;
                      });
                    },
                    hintText: "Payment Categories",
                    labelText: "Payment Categories",
                    itemAsString: (u) => u.toString(),
                  ),
                  CustomDropDown(
                    items: const ["Yes", "No"],
                    selectedItem: "Yes",
                    title: "Include Payment \nBy Tenant?",
                    isMultiselect: false,
                    onChanged: (v) {
                      setState(() {
                        isPayableByTenant = v == "Yes";
                      });
                    },
                    hintText: "Include Payment By Tenant?",
                    labelText: "Include Payment By Tenant?",
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Select Period",
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        SizedBox(
                            width: size.width * 0.55,
                            child: const DateSelector()),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  reportRunner(account, startDate, endDate),
                ],
              ),
            ),
          );
  }

  Widget transactionsList(account, startDate, endDate) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(allTransactions.length, (index) {
            my.Transaction transaction = allTransactions[index];
            bool isIncome = transaction.paymentCategory! == "Rent";

            return ListTile(
              leading: Text(
                transaction.units![0]["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              title: Text(
                transaction.senderInfo!["name"],
                style: const TextStyle(),
              ),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat("HH: mm, dd MMM").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            transaction.timestamp!)),
                    style: const TextStyle(),
                  ),
                  Text(
                    isIncome ? "Income" : "Expense",
                    style:
                        TextStyle(color: isIncome ? Colors.green : Colors.red),
                  )
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.paidAmount.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Paid",
                        style: TextStyle(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.remainingAmount.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Remaining",
                        style: TextStyle(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () => generateReport(account, startDate, endDate),
                child: Container(
                  height: 30.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(color: Colors.green, width: 1.0)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Center(
                        child: Text(
                      "Generate Report",
                      style: TextStyle(color: Colors.green),
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget reportRunner(Account account, int startDate, int endDate) {
    return allTransactions.isNotEmpty
        ? transactionsList(account, startDate, endDate)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 1.0,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    if (selectedProperties.isNotEmpty) {
                      runReport(account, startDate, endDate);
                    } else {
                      Fluttertoast.showToast(msg: "Select a property");
                    }
                  },
                  child: Container(
                    height: 30.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(color: Colors.blue, width: 1.0)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Center(
                          child: Text(
                        "Run Report",
                        style: TextStyle(color: Colors.blue),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildForMobile(BuildContext context, Size size, Account account,
      int startDate, int endDate) {
    return loading
        ? const LoadingAnimation()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Container(
              margin: const EdgeInsets.only(top: 20.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 1,
                        spreadRadius: 1.0,
                        offset: Offset(0.0, 0.0))
                  ],
                  border: Border.all(width: 0.5, color: Colors.grey.shade300)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () =>
                              context.read<TabProvider>().changeTab("Reports"),
                          child: Container(
                            height: 30.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border.all(
                                    color: EKodi.themeColor, width: 1.0)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Center(
                                  child: Text(
                                "Back",
                                style: TextStyle(color: EKodi.themeColor),
                              )),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Income Expense Statement",
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      ],
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    CustomDropDown(
                      items: properties,
                      selectedItems: selectedProperties,
                      title: "Select Properties",
                      isMultiselect: true,
                      onMultiChanged: (v) {
                        setState(() {
                          selectedProperties = v;
                        });
                      },
                      hintText: "Select Properties",
                      labelText: "Properties",
                      itemAsString: (u) => u.name,
                    ),
                    CustomDropDown(
                      items: paymentCategories,
                      selectedItems: selectedPaymentCategories,
                      title: "Payment Categories",
                      isMultiselect: true,
                      onMultiChanged: (v) {
                        setState(() {
                          selectedPaymentCategories = v;
                        });
                      },
                      hintText: "Payment Categories",
                      labelText: "Payment Categories",
                      itemAsString: (u) => u.toString(),
                    ),
                    CustomDropDown(
                      items: const ["Yes", "No"],
                      selectedItem: "Yes",
                      title: "Include Payment \nBy Tenant?",
                      isMultiselect: false,
                      onChanged: (v) {
                        setState(() {
                          isPayableByTenant = v == "Yes";
                        });
                      },
                      hintText: "Include Payment By Tenant?",
                      labelText: "Include Payment By Tenant?",
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Select Period",
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          DateSelector(),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    reportRunner(account, startDate, endDate),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return isMobile
            ? _buildForMobile(context, size, account, startDate, endDate)
            : _buildForDesktop(context, size, account, startDate, endDate);
      },
    );
  }
}

class CustomDropDown extends StatelessWidget {
  final String? title;
  final String? labelText;
  final String? hintText;
  final List? items;
  final List? selectedItems;
  final dynamic selectedItem;
  final Function(List)? onMultiChanged;
  final Function(dynamic)? onChanged;
  final bool? isMultiselect;
  final String Function(dynamic)? itemAsString;

  const CustomDropDown(
      {Key? key,
      this.title,
      this.items,
      this.selectedItems,
      this.onChanged,
      this.labelText,
      this.hintText,
      this.selectedItem,
      this.onMultiChanged,
      this.isMultiselect,
      this.itemAsString})
      : super(key: key);

  Widget _buildForDesktop(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title!,
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SizedBox(
              width: size.width * 0.55,
              height: isMultiselect! ? 50.0 : null,
              child: isMultiselect!
                  ? DropdownSearch<dynamic>.multiSelection(
                      mode: Mode.MENU,
                      items: items!,
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                                width: 1.0,
                                color: Theme.of(context).primaryColor)),
                        labelText: labelText!,
                        hintText: hintText!,
                      ),
                      onChanged: onMultiChanged,
                      selectedItems: selectedItems!,
                      itemAsString: itemAsString,
                    )
                  : DropdownSearch<dynamic>(
                      mode: Mode.MENU,
                      //showSelectedItems: true,
                      items: items!,
                      hint: hintText,
                      onChanged: onChanged,
                      selectedItem: selectedItem),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForMobile(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title!,
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10.0,
          ),
          SizedBox(
            width: size.width,
            height: isMultiselect! ? 50.0 : null,
            child: isMultiselect!
                ? DropdownSearch<dynamic>.multiSelection(
                    mode: Mode.MENU,
                    items: items!,
                    dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).primaryColor)),
                      labelText: labelText!,
                      hintText: hintText!,
                    ),
                    onChanged: onMultiChanged,
                    selectedItems: selectedItems!,
                    itemAsString: itemAsString,
                  )
                : DropdownSearch<dynamic>(
                    mode: Mode.MENU,
                    //showSelectedItems: true,
                    items: items!,
                    hint: hintText,
                    onChanged: onChanged,
                    selectedItem: selectedItem),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        return sizeInfo.isMobile || sizeInfo.isTablet
            ? _buildForMobile(context, size)
            : _buildForDesktop(context, size);
      },
    );
  }
}
