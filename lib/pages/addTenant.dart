import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/dialog/errorDialog.dart';
import 'package:rekodi/model/screeningData.dart';
import 'package:rekodi/providers/propertyProvider.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:rekodi/providers/tenantProvider.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../config.dart';
import '../model/account.dart';
import '../model/property.dart';
import '../model/unit.dart';
import '../widgets/customAppBar.dart';

class AddTenant extends StatefulWidget {

  const AddTenant({Key? key,}) : super(key: key);

  @override
  State<AddTenant> createState() => _AddTenantState();
}

class _AddTenantState extends State<AddTenant> {
  int startDate = DateTime.now().millisecondsSinceEpoch;
  TextEditingController rent = TextEditingController();
  TextEditingController deposit = TextEditingController();
  TextEditingController notes = TextEditingController();
  TextEditingController reminder = TextEditingController();
  TextEditingController tenantID = TextEditingController();
  String paymentFreq = 'Monthly';
  String submitTenantDetails = 'No';
  List<Unit> allUnits = [];
  Unit? selectedUnit;
  bool loading = false;
  Account? tenantAccount;


  @override
  void initState() {
    super.initState();

   getUnits();
  }

  getUnits() async {
    setState(() {
      loading = true;
    });

    Property property = Provider.of<PropertyProvider>(context, listen: false).selectedProperty;

    await FirebaseFirestore.instance.collection("properties").doc(property.propertyID!).collection("units").get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        Unit unit = Unit.fromDocument(element);

        allUnits.add(unit);
      });
    });

    setState(() {
      loading = false;
      //selectedUnit = allUnits[0];
    });
  }

  int calculateDueDate(int startDate) {
    switch (paymentFreq) {
      case "One-Time(Airbnb)":
        return  startDate+ 2.628e+9.toInt();//monthly basis
      case "Weekly":
        return startDate + 6.048e+8.toInt();
      case "Monthly":
        return startDate + 2.628e+9.toInt();
      case "Bi-Annually(6 Months)":
        return startDate + (6 * 2.628e+9).toInt();
      case "Yearly":
        return startDate + (12 * 2.628e+9).toInt();
      default:
        return startDate+ 2.628e+9.toInt();//monthly basis
    }
  }

  addTenantToUnit(Account currentUser, Property property) async {
    setState(() {
      loading = true;
    });
    //fetch for tenant data

    await FirebaseFirestore.instance.collection("users").where("idNumber", isEqualTo: tenantID.text.trim())
        .get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        setState(() {
          tenantAccount = Account.fromDocument(element);
        });
      });
    });

    if(tenantAccount != null)
      {
        try {
          int dueDate = calculateDueDate(startDate);

          Unit unit = Unit(
              name: selectedUnit!.name,
              tenantInfo: tenantAccount!.toMap(),
              rent: int.parse(rent.text.trim()),
              propertyID: selectedUnit!.propertyID,
              dueDate: dueDate,
              isOccupied: true,
              unitID: selectedUnit!.unitID,
              description: selectedUnit!.description,
              startDate: startDate,
              deposit: int.parse(deposit.text.trim()),
              paymentFreq: paymentFreq,
              reminder: int.parse(reminder.text.trim()),
              publisherID: currentUser.userID,
              isAccepted: false
          );

          //save tenant info to unit
          await FirebaseFirestore.instance.collection("properties").doc(property.propertyID)
              .collection("units").doc(selectedUnit!.unitID.toString()).update(unit.toMap()).then((value) {
            Fluttertoast.showToast(msg: "Added Tenant Successfully!");
          });

          //update property details
          await FirebaseFirestore.instance.collection("properties").doc(property.propertyID).update(
              {
                "occupied": property.occupied! + 1,
                "vacant": property.vacant! - 1,
              });

          //save tenant info to landlord
          await FirebaseFirestore.instance.collection("users").doc(currentUser.userID)
              .collection('tenants').doc(tenantAccount!.userID).set(tenantAccount!.toMap());

          await context.read<TenantProvider>().updateTenantsDB(currentUser, tenantAccount!);

          //save unit info to tenant
          await FirebaseFirestore.instance.collection("users").doc(tenantAccount!.userID)
              .collection("units").doc(unit.unitID.toString()).set(unit.toMap());

          //Navigator.pop(context, "uploaded");
          context.read<TabProvider>().changeTab("PropertyDetails");

          if(submitTenantDetails == "Yes")
          {
            ScreeningData screeningData =   ScreeningData(
              timestamp: DateTime.now().millisecondsSinceEpoch,
              isScreened: false,
              landlordInfo: currentUser.toMap(),
              tenantInfo: tenantAccount!.toMap(),
            );

            await FirebaseFirestore.instance.collection("screening").doc().set(screeningData.toMap());
          }

          setState(() {
            loading = false;
            rent.clear();
            deposit.clear();
            notes.clear();
            reminder.clear();
            tenantID.clear();
          });
        } catch (e) {
          setState(() {
            loading = false;
          });

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (c) {
              return ErrorAlertDialog(message: e.toString(),);
            }
          );
        }
      }
    else {
      setState(() {
        loading = false;
      });

      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (c) {
            return ErrorAlertDialog(message: "Could not find tenant with Tenant ID: ${tenantID.text}",);
          }
      );
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      // if (args.value is PickerDateRange) {
      //   // String _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
      //   // // ignore: lines_longer_than_80_chars
      //   //     ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      //
      // }
      // else
        if (args.value is DateTime) {
        startDate = args.value.millisecondsSinceEpoch;
      }
      //   else if (args.value is List<DateTime>) {
      //   _dateCount = args.value.length.toString();
      // } else {
      //   _rangeCount = args.value.length.toString();
      // }
    });
  }

  displayCalendar(BuildContext context, bool isMobile) {
    Size size = MediaQuery.of(context).size;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Pick Starting Date"),
          content: Container(
            height: isMobile ? size.height * 0.4 : size.height * 0.6,
            width: isMobile ? size.width * 0.8 : size.width*0.4,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0)
            ),
            child: SfDateRangePicker(
              view: DateRangePickerView.month,
              onSelectionChanged: _onSelectionChanged,
              enableMultiView: isMobile ? false : true,
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedDate: DateTime.fromMillisecondsSinceEpoch(startDate),
              // initialSelectedRange: PickerDateRange(
              //     DateTime.fromMillisecondsSinceEpoch(startDate),
              //     DateTime.fromMillisecondsSinceEpoch(endDate)
              // ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {Navigator.pop(context);},
              icon: Icon(Icons.done, color: Theme.of(context).primaryColor),
              label: Text("Done", style: TextStyle(color: Theme.of(context).primaryColor),),
            )
          ],
        );
      },
    );
  }

  Widget _buildForMobile(Account account, Size size, Property property) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(size.width, 60.0),
        child: DashboardAppBar(
          automaticallyImplyLeading: true,
          addPropertyButton: Container(),
        ),
      ),
      body:  loading ? const LoadingAnimation() : Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add New Tenant", textAlign: TextAlign.start, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20.0, )),
              const SizedBox(height: 10.0,),
              Container(
                width: size.width*0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2.0,
                        spreadRadius: 2.0,
                        offset: Offset(0.0, 0.0)
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Select Unit", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("properties")
                            .doc(property.propertyID!).collection("units").snapshots(),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData)
                          {
                            return const Text("Loading...");
                          }
                          else
                          {
                            List<Unit> allUnits = [];

                            for (var element in snapshot.data!.docs) {
                              allUnits.add(Unit.fromDocument(element));
                            }

                            return ListView.builder(
                              itemCount: allUnits.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                Unit unit = allUnits[index];
                                bool isSelected = unit == selectedUnit;
                                bool isOccupied = unit.isOccupied!;

                                return Card(
                                  elevation: 5.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      if(!isOccupied) {
                                        setState(() {
                                          selectedUnit = unit;
                                        });
                                      }
                                    },
                                    leading: isOccupied ? const Icon(Icons.check_box, color: Colors.grey,) : isSelected
                                        ? Icon(Icons.check_box, color: EKodi().themeColor,)
                                        : const Icon(Icons.check_box_outline_blank_rounded, color: Colors.grey,),
                                    title: isOccupied ? Text(unit.name!, style: const TextStyle(decoration: TextDecoration.lineThrough)) : Text(unit.name!),
                                    subtitle: Text(unit.isOccupied! ? "Occupied" : "Vacant"),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20.0,),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text("Start Date", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(startDate)), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                            const SizedBox(width: 5.0,),
                            IconButton(
                              onPressed: () => displayCalendar(context, true),
                              icon: const Icon(Icons.date_range_rounded, color: Colors.grey,),
                            )
                          ],
                        ),
                      ),
                      CustomTextField(
                        controller: tenantID,
                        hintText: "ID Number",
                        //width:  size.width,
                        title: "Tenant ID Number",
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.error_outline_rounded, color: EKodi().themeColor.withOpacity(0.3)),
                                const Text("Make sure your Tenant has an e-Kodi account", maxLines: 2, style: TextStyle(fontSize: 12.0,),),
                              ],
                            ),
                          )
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Submit Tenant Details for Screening?", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                          )
                      ),
                      const SizedBox(height: 5.0,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        child: DropdownSearch<String>(
                            mode: Mode.MENU,
                            showSelectedItems: true,
                            items: const [
                              "Yes",
                              "No"
                            ],
                            onChanged: (v) {
                              setState(() {
                                submitTenantDetails = v!;
                              });
                            },
                            selectedItem: submitTenantDetails),
                      ),
                      CustomTextField(
                        controller: rent,
                        hintText: "Rent Amount",
                        //width:  size.width,
                        title: "Rent Amount (KES)",
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Payment Frequency?", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                          )
                      ),
                      const SizedBox(height: 5.0,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        child: DropdownSearch<String>(
                            mode: Mode.MENU,
                            showSelectedItems: true,
                            items: const [
                              "One-Time(Airbnb)",
                              "Weekly",
                              "Monthly",
                              "Bi-Annually(6 Months)",
                              "Yearly"
                            ],
                            hint: "Is this property a multi-unit?",
                            onChanged: (v) {
                              setState(() {
                                paymentFreq = v!;
                              });
                            },
                            selectedItem: paymentFreq),
                      ),
                      CustomTextField(
                        controller: deposit,
                        hintText: "Deposit Amount",
                        // width:  size.width,
                        title: "Deposit Amount (KES)",
                      ),
                      CustomTextField(
                        controller: notes,
                        hintText: "Notes",
                        // width:  size.width,
                        title: "Type something here...",
                      ),
                      CustomTextField(
                        controller: reminder,
                        hintText: "0 days",
                        // width:  size.width,
                        title: "Tenant Rent Reminder Days Before",
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: RaisedButton.icon(
                            onPressed: ()=> addTenantToUnit(account, property),
                            icon: const Icon(Icons.done_rounded, color:Colors.white),
                            label: const Text("Save", style: TextStyle(color:Colors.white),),
                            color:EKodi().themeColor
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForDesktop(Account account, Size size, Property property) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20.0,),
        TextButton.icon(
          onPressed: () => context.read<TabProvider>().changeTab("PropertyDetails"),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey,),
          label: const Text("Back", style: TextStyle(color: Colors.grey),),
        ),
        Text("Add New Tenant", textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10.0,),
        Container(
          width: size.width*0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                  offset: Offset(0.0, 0.0)
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Select Unit", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                ListView.builder(
                  itemCount: allUnits.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    Unit unit = allUnits[index];
                    bool isSelected = unit == selectedUnit;
                    bool isOccupied = unit.isOccupied!;

                    return Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ListTile(
                        onTap: () {
                          if(!isOccupied) {
                            setState(() {
                              selectedUnit = unit;
                            });
                          }
                        },
                        leading: isOccupied ? const Icon(Icons.check_box, color: Colors.grey,) : isSelected
                            ? Icon(Icons.check_box, color: EKodi().themeColor,)
                            : const Icon(Icons.check_box_outline_blank_rounded, color: Colors.grey,),
                        title: isOccupied ? Text(unit.name!, style: const TextStyle(decoration: TextDecoration.lineThrough)) : Text(unit.name!),
                        subtitle: Text(unit.isOccupied! ? "Occupied" : "Vacant"),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20.0,),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text("Start Date", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(startDate)), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                      const SizedBox(width: 5.0,),
                      IconButton(
                        onPressed: () => displayCalendar(context, false),
                        icon: const Icon(Icons.date_range_rounded, color: Colors.grey,),
                      )
                    ],
                  ),
                ),
                CustomTextField(
                  controller: tenantID,
                  hintText: "ID Number",
                  //width:  size.width,
                  title: "Tenant ID Number",
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline_rounded, color: EKodi().themeColor.withOpacity(0.3)),
                          const Text("Make sure your Tenant has an e-Kodi account", maxLines: 2, style: TextStyle(fontSize: 12.0,),),
                        ],
                      ),
                    )
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Submit Tenant Details for Screening?", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                    )
                ),
                const SizedBox(height: 5.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSelectedItems: true,
                      items: const [
                        "Yes",
                        "No"
                      ],
                      onChanged: (v) {
                        setState(() {
                          submitTenantDetails = v!;
                        });
                      },
                      selectedItem: submitTenantDetails),
                ),
                CustomTextField(
                  controller: rent,
                  hintText: "Rent Amount",
                  // width:  size.width,
                  title: "Rent Amount (KES)",
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Payment Frequency?", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                    )
                ),
                const SizedBox(height: 5.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSelectedItems: true,
                      items: const [
                        "One-Time(Airbnb)",
                        "Weekly",
                        "Monthly",
                        "Bi-Annually(6 Months)",
                        "Yearly"
                      ],
                      hint: "Is this property a multi-unit?",
                      onChanged: (v) {
                        setState(() {
                          paymentFreq = v!;
                        });
                      },
                      selectedItem: paymentFreq),
                ),
                CustomTextField(
                  controller: deposit,
                  hintText: "Deposit Amount",
                  // width:  size.width,
                  title: "Deposit Amount (KES)",
                ),
                CustomTextField(
                  controller: notes,
                  hintText: "Notes",
                  // width:  size.width,
                  title: "Type something here...",
                ),
                CustomTextField(
                  controller: reminder,
                  hintText: "0 days",
                  // width:  size.width,
                  title: "Tenant Rent Reminder Days Before",
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RaisedButton.icon(
                      onPressed: ()=> addTenantToUnit(account, property),
                      icon: const Icon(Icons.done_rounded, color:Colors.white),
                      label: const Text("Save", style: TextStyle(color:Colors.white),),
                      color:EKodi().themeColor
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;
    Property property = context.watch<PropertyProvider>().selectedProperty;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return isMobile
            ? _buildForMobile(account, size, property)
            : _buildForDesktop(account, size, property);
      },
    );
  }
}
