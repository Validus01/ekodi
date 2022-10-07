import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config.dart';
import '../../model/property.dart';
import '../../providers/tabProvider.dart';
import '../../widgets/customAppBar.dart';
import '../../widgets/dateSelector.dart';
import '../../widgets/loadingAnimation.dart';
import 'IncomeExpenseStatement.dart';


class ServiceProviderReport extends StatefulWidget {
  const ServiceProviderReport({Key? key}) : super(key: key);

  @override
  State<ServiceProviderReport> createState() => _ServiceProviderReportState();
}

class _ServiceProviderReportState extends State<ServiceProviderReport> {
  List<dynamic> properties = [];
  List<dynamic> selectedProperties = [];
  bool loading = false;
  bool isPayableByTenant = true;
  List<String> paymentCategories = [
    "Plumber",
    "Electrician",
    "Beauty & Cosmetics",
    "Internet Service Provider(WiFi)",
    "Cleaners",
    "Wood & Metal Works",
    "Tutor",
    "Security",
    "Other"
  ];
  List<dynamic> selectedPaymentCategories = [];

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

    await FirebaseFirestore.instance.collection("properties").where("publisherID", isEqualTo: userID).get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        properties.add(Property.fromDocument(element));
      });
    });

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        return loading ? const LoadingAnimation(): Container(
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
              border: Border.all(
                  width: 0.5, color: Colors.grey.shade300)),
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
                      onTap: () => context.read<TabProvider>().changeTab("Reports"),
                      child: Container(
                        height: 30.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                            border: Border.all(
                                color: EKodi().themeColor,
                                width: 1.0
                            )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Center(child: Text("Back", style: TextStyle(color: EKodi().themeColor),)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    Text("Service Provider Expense Report", style: Theme.of(context).textTheme.titleMedium,)
                  ],
                ),
                Divider(color: Colors.grey.shade300,),
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
                  items: [],
                  selectedItems: [],
                  title: "Select Provider",
                  isMultiselect: true,
                  onMultiChanged: (v) {
                    //todo
                  },
                  hintText: "Select Provider",
                  labelText: "Providers",
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
                  title: "Include Payment By Tenant?",
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
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: sizeInfo.isMobile ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Select Period", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                      SizedBox(height: 10.0,),
                      DateSelector(),
                    ],
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Select Period", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                      const SizedBox(width: 20.0,),
                      SizedBox(
                          width: size.width*0.55,
                          child: const DateSelector()),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 1.0,),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          height: 30.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border.all(
                                  color: Colors.blue,
                                  width: 1.0
                              )
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Center(child: Text("Run Report", style: TextStyle(color: Colors.blue),)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}