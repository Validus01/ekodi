import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config.dart';
import '../../model/account.dart';
import '../../model/property.dart';
import '../../model/screeningData.dart';
import '../../providers/tabProvider.dart';
import '../../widgets/customAppBar.dart';
import '../../widgets/dateSelector.dart';
import '../../widgets/loadingAnimation.dart';
import 'IncomeExpenseStatement.dart';


class TenantScreeningReport extends StatefulWidget {
  const TenantScreeningReport({Key? key}) : super(key: key);

  @override
  State<TenantScreeningReport> createState() => _TenantScreeningReportState();
}

class _TenantScreeningReportState extends State<TenantScreeningReport> {
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController description = TextEditingController();
  List<dynamic> properties = [];
  List<dynamic> selectedProperties = [];
  bool loading = false;

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

  submitTenantForScreening(Account account) async {
    setState(() {
      loading = true;
    });

    ScreeningData screeningData =   ScreeningData(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isScreened: false,
      landlordInfo: account.toMap(),
      tenantInfo: {
        "email": email.text.trim(),
        "phone": phone.text.trim(),
        "description": description.text
      },
    );

    await FirebaseFirestore.instance.collection("screening").doc().set(screeningData.toMap());

    Fluttertoast.showToast(msg: "Tenant details submitted successfully!");

    setState(() {
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        return loading ? const LoadingAnimation(): Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                        Text("Screen a new tenant", style: Theme.of(context).textTheme.titleMedium,)
                      ],
                    ),
                    Divider(color: Colors.grey.shade300,),
                    CustomTextField(
                      controller: email,
                      hintText: "Email Address",
                      // width: size.width,
                      title: "Tenant Email Address",
                      inputType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      controller: phone,
                      hintText: "Phone (254...)",
                      // width: size.width,
                      title: "Tenant Phone Number",
                      inputType: TextInputType.phone,
                    ),
                    CustomTextField(
                      controller: description,
                      hintText: "Type something here...",
                      // width: size.width,
                      title: "Describe the person",
                      inputType: TextInputType.text,
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
                                child: Center(child: Text("Submit for Screening", style: TextStyle(color: Colors.blue),)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
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
                    Text("Generate Tenant Screening Report", style: Theme.of(context).textTheme.titleMedium,),
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
            )
          ],
        );
      },
    );
  }
}
