import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/model/bulkSmsModel.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';
import '../model/account.dart';


class BulkSMSSection extends StatefulWidget {
  const BulkSMSSection({Key? key}) : super(key: key);

  @override
  State<BulkSMSSection> createState() => _BulkSMSSectionState();
}

class _BulkSMSSectionState extends State<BulkSMSSection> {
  List<dynamic> phoneNumbers = [];
  TextEditingController controller = TextEditingController();
  List<Account> selectedTenants = [];
  bool loading = false;
  int balance = 0;

  sendBulkSMS(Account currentUser) async {
    setState(() {
      loading = true;
    });

    for (var tenant in selectedTenants) {
      phoneNumbers.add(tenant.phone);
    }

    BulkSMS bulkSMS = BulkSMS(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      phoneNumbers: phoneNumbers,
      smsDescription: controller.text
    );

    await FirebaseFirestore.instance.collection("users").doc(currentUser.userID).collection("bulkSMS")
        .doc(bulkSMS.timestamp.toString()).set(bulkSMS.toMap());

    Fluttertoast.showToast(msg: "SMS Sent Successfully!");

    setState(() {
      loading = false;
      selectedTenants.clear();
      controller.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return Container(
          width: size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey.shade300, width: 1.0)),
          child: loading? const LoadingAnimation(): Padding(
            padding: EdgeInsets.all(isMobile ? 10.0 : 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Send Bulk SMS to Tenants", style: Theme.of(context).textTheme.titleSmall,),
                    RichText(
                      text: const TextSpan(
                        //style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Bulk SMS Balance: ',
                              style: TextStyle(
                                  color: Colors.teal)),
                          TextSpan(
                              text: 'KES 0',
                              style: TextStyle(
                                  color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0,),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection("users").doc(account.userID).collection("tenants").get(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData)
                    {
                      return const Center(child: Text('Loading...'));
                    }
                    else {
                      List<Account> tenants = [];

                      for (var element in snapshot.data!.docs) {
                        tenants.add(Account.fromDocument(element));
                      }

                      if(tenants.isEmpty)
                      {
                        return const Center(
                          child: Text("You don't have Tenants"),
                        );
                      }
                      else
                      {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(tenants.length, (index) {
                            Account tenant = tenants[index];

                            return TenantItem(
                                tenant: tenant,
                                isSelected: (v) {
                                  setState(() {
                                    if(v)
                                    {
                                      selectedTenants.add(tenant);
                                    }
                                    else
                                    {
                                      selectedTenants.removeWhere((acc) => tenant.userID == acc.userID);
                                    }
                                  });
                                }
                            );
                          }),
                        );
                      }
                    }
                  },
                ),
                MyTextField(
                  controller: controller,
                  hintText: 'Type something...',
                  width: size.width,
                  title: "SMS Details",
                  inputType: TextInputType.multiline,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RaisedButton.icon(
                    onPressed: () {
                      if(selectedTenants.isNotEmpty && controller.text.isNotEmpty )//todo: && balance != 0)
                      {
                        sendBulkSMS(account);
                      }
                      else
                      {
                        Fluttertoast.showToast(msg: "Select Tenants and Type something");
                      }
                    },
                    color: EKodi().themeColor,
                    icon: const Icon(Icons.send_rounded, color: Colors.white,),
                    label: Text("Send To ${selectedTenants.length}", style: const TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}


class TenantItem extends StatefulWidget {

  final Account? tenant;
  final ValueChanged<bool>? isSelected;
  const TenantItem({Key? key, this.tenant, this.isSelected}) : super(key: key);

  @override
  State<TenantItem> createState() => _TenantItemState();
}

class _TenantItemState extends State<TenantItem> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        child: ListTile(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
              widget.isSelected!(isSelected);
            });
          },
          leading: isSelected
              ?  Icon(Icons.check_box, color: EKodi().themeColor,)
              : const Icon(Icons.check_box_outline_blank_rounded, color: Colors.grey,),
          title: Text(widget.tenant!.name!, style: const TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(widget.tenant!.accountType!, maxLines: 3, overflow: TextOverflow.ellipsis,),
        ),
      ),
    );
  }
}
