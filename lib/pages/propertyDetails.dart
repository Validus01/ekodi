import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;
import 'package:rekodi/providers/propertyProvider.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:rekodi/widgets/customButton.dart';
import 'package:rekodi/widgets/googleMapsWidget.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:rekodi/widgets/propertyDetailsCard.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../commonFunctions/AddToOutstanding.dart';
import '../config.dart';
import '../model/account.dart';
import '../model/propertyImagesModel.dart';
import '../model/unit.dart';
import '../widgets/customAppBar.dart';
import '../widgets/customTextField.dart';

class PropertyDetails extends StatefulWidget {
  //final Property? property;

  const PropertyDetails({Key? key, }) : super(key: key);

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  TextEditingController description = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController unitName = TextEditingController();
  TextEditingController unitDesc = TextEditingController();
  //List<Unit> units = [];
  bool loading = false;

  @override
  void initState() {
    //getUnits();
    super.initState();
  }

  proceedToAddTenant(Property property) async {

    context.read<TabProvider>().changeTab("AddTenant");

  }

  Widget showUnits(List<Unit> units, Size size, bool isMobile, Property property) {

    List<Widget> unitsWidgets = List.generate(units.length, (index) {
      Unit unit = units[index];
      String date = DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(unit.startDate!));

      if(DateTime.now().millisecondsSinceEpoch >= units[0].dueDate!) {
        AddToOutstanding().addToOutstanding(units[0]);
      }

      return Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
        child: SizedBox(
          height: isMobile && unit.isOccupied! ? 160.0 : 100.0,
          width: isMobile ? size.width : size.width*0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.house_rounded, color: Colors.grey, ),
                title: Text(unit.name!, style: const TextStyle(fontWeight: FontWeight.bold),),
                subtitle: Text(unit.description!, maxLines: 3, overflow: TextOverflow.ellipsis,),
                trailing: unit.isOccupied! ? const Text("Occupied", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold) ) : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Vacant", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                    RaisedButton(
                      color: Colors.red,
                      onPressed: ()=> removeUnit(unit, property),
                      child: const Text("Delete", style: TextStyle(color: Colors.white),),
                    )
                  ],
                ),
              ),
              unit.isOccupied! ? ListTile(
                title: Text("Occupied By: ${unit.tenantInfo!["name"]}", maxLines: 2, overflow: TextOverflow.ellipsis,),
                subtitle: Text("From $date to Date"),
                trailing: Text("Rent: KES ${unit.rent.toString()}", style: const TextStyle(fontWeight: FontWeight.bold),),
              ) : Container()
            ],
          ),
        ),
      );
    });

    return isMobile ? Column(
      mainAxisSize: MainAxisSize.min,
      children: unitsWidgets,
    ) : GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: size.width*0.5/200.0,
      children: unitsWidgets,
    );
  }

  showAddExpense(BuildContext context, Account account, Size size, bool isMobile, Property property) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return ResponsiveBuilder(
          builder: (context, sizeInfo) {
            bool isDesktop = sizeInfo.isDesktop;

            return AlertDialog(
              title: const Text("Add Expense"),
              content: Container(
                // height: isDesktop ? size.height * 0.6 : size.height * 0.4,
                width: isDesktop ? size.width * 0.4 : size.width*0.8,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: description,
                      hintText: "What's the expense for?",
                      // width: size.width,
                      title: "Describe Expense",
                      inputType: TextInputType.text,
                    ),
                    CustomTextField(
                      controller: paidAmount,
                      hintText: "Amount (Kes)",
                      // width: size.width,
                      title: "Amount (Kes)",
                      inputType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                RaisedButton.icon(
                  onPressed: () {
                    if(description.text.isNotEmpty && paidAmount.text.isNotEmpty)
                    {
                      proceedToAddExpense(account, property);
                    }
                  },
                  color: EKodi().themeColor,
                  icon: const Icon(Icons.add, color: Colors.white,),
                  label: const Text("Add Expense", style: TextStyle(color: Colors.white),),
                )
              ],
            );
          },
        );
      },
    );
  }

  addNewUnit(Unit newUnit, Property property) async {
    setState(() {
      loading = true;
    });

    await FirebaseFirestore.instance.collection("properties").doc(property.propertyID)
        .collection("units").doc(newUnit.unitID.toString()).set(newUnit.toMap());

    await FirebaseFirestore.instance.collection("properties").doc(property.propertyID).update({
      "units": property.units! + 1,
      "vacant": property.vacant! + 1,
    });

    Navigator.pop(context);

    setState(() {
      unitName.clear();
      unitDesc.clear();
      loading = false;
    });
  }

  removeUnit(Unit oldUnit, Property property) async {
    setState(() {
      loading = true;
    });

    await FirebaseFirestore.instance.collection("properties").doc(property.propertyID)
        .collection("units").doc(oldUnit.unitID.toString()).get().then((value) async {
          if(value.exists)
            {
              await value.reference.delete();

              Fluttertoast.showToast(msg: "Unit deleted successfully");
            }
    });

    await FirebaseFirestore.instance.collection("properties").doc(property.propertyID).update({
      "units": property.units! - 1,
      "vacant": property.vacant! - 1,
    });

    setState(() {
      loading = false;
    });

  }

  showAddUnits(BuildContext context, Account account, Size size, Property property) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return ResponsiveBuilder(
          builder: (context, sizeInfo) {
            bool isDesktop = sizeInfo.isDesktop;
            return AlertDialog(
              title: const Text("Add Units"),
              content: Container(
                width: isDesktop ? size.width * 0.4 : size.width*0.8,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: isDesktop ? size.width*0.2 : size.width*0.6,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: unitName,
                                hintText: "Name",
                                // width: isDesktop ? size.width*0.2 : size.width*0.6,
                                title: "Unit Name",
                              ),
                              CustomTextField(
                                controller: unitDesc,
                                hintText: "Description",
                                // width:isDesktop ? size.width*0.2 : size.width*0.6,
                                title: "Description",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5.0,),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton.icon(
                  label: Text("Add", style: TextStyle(color: EKodi().themeColor),),
                  icon: Icon(Icons.add, color: EKodi().themeColor,),
                  onPressed: () {
                    if(unitName.text.isNotEmpty && unitDesc.text.isNotEmpty)
                    {
                      Unit newUnit = Unit(
                        name: unitName.text,
                        description: unitDesc.text,
                        unitID: DateTime.now().millisecondsSinceEpoch,
                        tenantInfo: {},
                        isOccupied: false,
                        rent: 0,
                        dueDate: 0,
                        propertyID: property.propertyID,
                        deposit: 0,
                        startDate: 0,
                        paymentFreq: "",
                        reminder: 0,
                        publisherID: account.userID,
                        isAccepted: false,
                      );

                      addNewUnit(newUnit, property);
                    }
                    else {
                      Fluttertoast.showToast(msg: "Fill in the unit details");
                    }
                  },
                )
              ],
            );
          },
        );
      }
    );
  }

  proceedToAddExpense(Account account, Property property) async {
    setState(() {
      loading = true;
    });
    Navigator.pop(context);

    account_transaction.Transaction transaction = account_transaction.Transaction(
      transactionID: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionType: "",
      paymentCategory: description.text.trim(),
      description: description.text,
      timestamp:  DateTime.now().millisecondsSinceEpoch,
      actualAmount: int.parse(paidAmount.text.trim()),
      paidAmount: int.parse(paidAmount.text.trim()),
      remainingAmount: 0,
      properties: [property.propertyID],
      serviceProviders: [],
      tenants: [],
      senderInfo: account.toMap(),
      units: [],
      receiverInfo: {},
    );

    await FirebaseFirestore.instance.collection("users").doc(account.userID)
        .collection("transactions").doc(transaction.transactionID).set(transaction.toMap());


    setState(() {
      loading = false;
      description.clear();
      paidAmount.clear();
    });
  }

  Widget showImages(Property property, Size size) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection("properties").doc(property.propertyID).collection("images").get(),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
        {
          return const Text("Loading...");
        }
        else
        {
          List<PropertyImages> imagesCollection = [];

          for (var element in snapshot.data!.docs) {
            imagesCollection.add(PropertyImages.fromDocument(element));
          }

          if(imagesCollection.isEmpty)
          {
            return Container();
          }
          else
          {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Property Images", style: Theme.of(context).textTheme.headlineSmall,),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(imagesCollection.length, (index) {
                    return GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: size.width*0.5/300.0,
                      shrinkWrap: true,
                      children: List.generate(imagesCollection[index].imageUrls!.length, (imageIndex) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              imagesCollection[index].imageUrls![imageIndex],
                              width: size.width,
                              height: 300.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ],
            );
          }
        }
      },
    );
  }

  Widget _buildForDesktop(BuildContext context, Account account, Size size, Property property) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0,),
        TextButton.icon(
          onPressed: () => context.read<TabProvider>().changeTab("Properties"),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey,),
          label: const Text("Back", style: TextStyle(color: Colors.grey),),
        ),
        Row(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: PropertyDetailsCard(property: property,),
            ),
            const Expanded(
              flex: 1,
              child: GoogleMapsWidget(),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            //horizontal: size.width*0.1,
              vertical: 10.0
          ),
          child: showImages(property, size),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              //horizontal: size.width*0.1,
              vertical: 10.0
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Property Units", style: Theme.of(context).textTheme.headlineSmall,),
              InkWell(
                onTap: () => showAddUnits(context, account, size, property),
                child: Container(
                  height: 25.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(
                          color: EKodi().themeColor,
                          width: 1.0
                      )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Center(child: Text("Add Units", style: TextStyle(color: EKodi().themeColor),)),
                  ),
                ),
              )
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("properties")
              .doc(property.propertyID).collection("units").snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData)
            {
              return const Text("Loading...");
            }
            else
            {
              List<Unit> units = [];

              snapshot.data!.docs.forEach((element) {
                units.add(Unit.fromDocument(element));
              });

              return showUnits(units, size, false, property);
            }
          },
        ),
        property.vacant == 0 ? Container() : Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 0.0),
                      spreadRadius: 2.0,
                      blurRadius: 2.0
                  )
                ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Leases/Tenancies", style: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 2),),
                      InkWell(
                        onTap: ()=> proceedToAddTenant(property),
                        child: Container(
                          height: 25.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border.all(
                                  color: EKodi().themeColor,
                                  width: 1.0
                              )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Center(child: Text("Add New Tenant", style: TextStyle(color: EKodi().themeColor),)),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10.0,),
                  Image.asset("assets/add_tenant.png", height: 80.0, width: 80.0, fit: BoxFit.contain,),
                  const SizedBox(height: 10.0,),
                  const Text("Start by adding your tenant"),
                  const SizedBox(height: 10.0,),
                  const Text("Once you add a tenant, you can start tracking your rent payments"),
                  const SizedBox(height: 10.0,),
                  RaisedButton.icon(
                      onPressed: ()=> proceedToAddTenant(property),
                      color: EKodi().themeColor,
                      icon: const Icon(Icons.person_add, color: Colors.white,),
                      label: const Text("Add new tenant", style: TextStyle(color: Colors.white),)
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 0.0),
                      spreadRadius: 2.0,
                      blurRadius: 2.0
                  )
                ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Property Documents", style: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 2),),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: 25.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border.all(
                                  color: EKodi().themeColor,
                                  width: 1.0
                              )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Center(child: Text("Add Document", style: TextStyle(color: EKodi().themeColor),)),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(color: Colors.grey,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/blog_dec.png", height: 120.0, width: 120.0, fit: BoxFit.contain,),
                      const SizedBox(height: 10.0,),
                      const Text("No documents added", style: TextStyle(color: Colors.grey),)
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 0.0),
                      spreadRadius: 2.0,
                      blurRadius: 2.0
                  )
                ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Expenses", style: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 2),),
                      InkWell(
                        onTap: () => showAddExpense(context, account, size, false, property),
                        child: Container(
                          height: 25.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border.all(
                                  color: EKodi().themeColor,
                                  width: 1.0
                              )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Center(child: Text("Add Expense", style: TextStyle(color: EKodi().themeColor),)),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(color: Colors.grey,),
                  FutureBuilder(
                    future: FirebaseFirestore.instance.collection("users")
                        .doc(account.userID).collection("transactions")
                        .where("properties", arrayContains: property.propertyID)
                        .where("paymentCategory", isNotEqualTo: "Rent").get(),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData) {
                        return const Text("Loading...");
                      }
                      else
                      {
                        List<account_transaction.Transaction> transactions = [];

                        if(transactions.isEmpty)
                        {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.currency_exchange_rounded, color: Colors.grey.shade400, size: 40.0,),
                              const SizedBox(height: 10.0,),
                              const Text("No expenses added", style: TextStyle(color: Colors.grey),)
                            ],
                          );
                        }
                        else
                        {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(transactions.length, (index) {
                              return ListTile(
                                leading: Text((index+1).toString(), style: const TextStyle(fontWeight: FontWeight.w600),),
                                title: Text(transactions[index].description!),
                                subtitle: Divider(color: Colors.grey.shade300,),
                                trailing: Text("Kes "+transactions[index].paidAmount.toString()),
                              );
                            }),
                          );
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30.0,)
      ],
    );
  }

  Widget _buildForMobile(BuildContext context, Account account, Size size, Property property)
  {
    return loading ? const LoadingAnimation(): SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () {Navigator.pop(context);},
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey,),
            label: const Text("Back", style: TextStyle(color: Colors.grey),),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PropertyDetailsCard(property: property,),
              const GoogleMapsWidget()
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Property Units", style: Theme.of(context).textTheme.headlineSmall,),
                InkWell(
                  onTap: () => showAddUnits(context, account, size, property),
                  child: Container(
                    height: 25.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(
                            color: EKodi().themeColor,
                            width: 1.0
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Center(child: Text("Add Units", style: TextStyle(color: EKodi().themeColor),)),
                    ),
                  ),
                )
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("properties")
                .doc(property.propertyID).collection("units").snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData)
              {
                return const Text("Loading...");
              }
              else
              {
                List<Unit> units = [];

                snapshot.data!.docs.forEach((element) {
                  units.add(Unit.fromDocument(element));
                });

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: showUnits(units, size, true, property),
                );
              }
            },
          ),
          property.vacant == 0 ? Container() : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Container(
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 0.0),
                        spreadRadius: 2.0,
                        blurRadius: 2.0
                    )
                  ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Leases/Tenancies", style: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 2),),
                        InkWell(
                          onTap: ()=> proceedToAddTenant(property),
                          child: Container(
                            height: 25.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border.all(
                                    color: EKodi().themeColor,
                                    width: 1.0
                                )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Center(child: Text("Add New Tenant", style: TextStyle(color: EKodi().themeColor),)),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10.0,),
                    Image.asset("assets/add_tenant.png", height: 80.0, width: 80.0, fit: BoxFit.contain,),
                    const SizedBox(height: 10.0,),
                    const Text("Start by adding your tenant"),
                    const SizedBox(height: 10.0,),
                    const Text("Once you add a tenant, you can start tracking your rent payments"),
                    const SizedBox(height: 10.0,),
                    RaisedButton.icon(
                        onPressed: ()=> proceedToAddTenant(property),
                        color: EKodi().themeColor,
                        icon: const Icon(Icons.person_add, color: Colors.white,),
                        label: const Text("Add new tenant", style: TextStyle(color: Colors.white),)
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Container(
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 0.0),
                        spreadRadius: 2.0,
                        blurRadius: 2.0
                    )
                  ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Property Documents", style: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 2),),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            height: 25.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border.all(
                                    color: EKodi().themeColor,
                                    width: 1.0
                                )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Center(child: Text("Add Document", style: TextStyle(color: EKodi().themeColor),)),
                            ),
                          ),
                        )
                      ],
                    ),
                    const Divider(color: Colors.grey,),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/blog_dec.png", height: 120.0, width: 120.0, fit: BoxFit.contain,),
                        const SizedBox(height: 10.0,),
                        const Text("No documents added", style: TextStyle(color: Colors.grey),)
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Container(
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 0.0),
                        spreadRadius: 2.0,
                        blurRadius: 2.0
                    )
                  ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Expenses", style: Theme.of(context).textTheme.titleMedium!.apply(fontWeightDelta: 2),),
                        InkWell(
                          onTap: () => showAddExpense(context, account, size, true, property),
                          child: Container(
                            height: 25.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border.all(
                                    color: EKodi().themeColor,
                                    width: 1.0
                                )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Center(child: Text("Add Expense", style: TextStyle(color: EKodi().themeColor),)),
                            ),
                          ),
                        )
                      ],
                    ),
                    const Divider(color: Colors.grey,),
                    FutureBuilder(
                      future: FirebaseFirestore.instance.collection("users")
                          .doc(account.userID).collection("transactions")
                          .where("properties", arrayContains: property.propertyID)
                          .where("paymentCategory", isNotEqualTo: "Rent").get(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) {
                          return const Text("Loading...");
                        }
                        else
                        {
                          List<account_transaction.Transaction> transactions = [];

                          if(transactions.isEmpty)
                          {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.currency_exchange_rounded, color: Colors.grey.shade400, size: 40.0,),
                                const SizedBox(height: 10.0,),
                                const Text("No expenses added", style: TextStyle(color: Colors.grey),)
                              ],
                            );
                          }
                          else
                          {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(transactions.length, (index) {
                                return ListTile(
                                  leading: Text((index+1).toString(), style: const TextStyle(fontWeight: FontWeight.w600),),
                                  title: Text(transactions[index].description!),
                                  subtitle: Divider(color: Colors.grey.shade300,),
                                  trailing: Text("Kes "+transactions[index].paidAmount.toString()),
                                );
                              }),
                            );
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30.0,)
        ],
      ),
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
            ? _buildForMobile(context, account, size, property)
            : _buildForDesktop(context, account, size, property);
      },
    );
  }


}
