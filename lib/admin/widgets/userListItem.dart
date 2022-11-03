import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rekodi/commonFunctions/mapUtils.dart';
import 'package:rekodi/model/locationInfo.dart';
import 'package:rekodi/model/verificationInfo.dart';
import 'package:rekodi/widgets/ProgressWidget.dart';
import 'package:rekodi/widgets/customButton.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../model/account.dart';

class UserListItem extends StatefulWidget {
  final Account? account;
  const UserListItem({Key? key, this.account}) : super(key: key);

  @override
  State<UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  bool isOpen = false;

  Color textColor(String status) {
    switch (status) {
      case "verified":
        return Colors.teal;
      case "unverified":
        return Colors.red;
      case "pending":
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  void verifyUser() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.account!.userID)
        .update({
      "verified": true,
      "verification": {
        "verified": true,
        "status": "verified",
        "timestamp": DateTime.now().millisecondsSinceEpoch
      },
    }).then((value) =>
            Fluttertoast.showToast(msg: "User Verified Successfully!"));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ListTile(
        onTap: () {
          setState(() {
            isOpen = !isOpen;
          });
        },
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: EKodi.themeColor.withOpacity(0.3),
          backgroundImage: NetworkImage(widget.account!.photoUrl!),
        ),
        title: Text(widget.account!.name!),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Created: ${DateFormat("HH:mm a, dd MMM yyyy").format(DateTime.fromMillisecondsSinceEpoch(widget.account!.timestamp!))}",
              style: Theme.of(context).textTheme.caption,
            ),
            Text(
              widget.account!.verification!["status"],
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor(widget.account!.verification!["status"])),
            ),
            isOpen
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        icon: const Icon(
                          Icons.email_rounded,
                          color: EKodi.themeColor,
                        ),
                        label: Text(widget.account!.email!),
                        onPressed: () =>
                            launch("mailto:${widget.account!.email}"),
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.phone,
                          color: EKodi.themeColor,
                        ),
                        label: Text(widget.account!.phone!),
                        onPressed: () => launch("tel:${widget.account!.phone}"),
                      ),
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.account!.userID)
                            .collection("location")
                            .orderBy("timestamp", descending: true)
                            .limit(1)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return circularProgress();
                          } else {
                            List<LocationInfo> locations = [];

                            snapshot.data!.docs.forEach((element) {
                              LocationInfo locationInfo =
                                  LocationInfo.fromDocument(element);

                              locations.add(locationInfo);
                            });

                            if (locations.isEmpty) {
                              return Container();
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.my_location,
                                    color: EKodi.themeColor,
                                  ),
                                  label:
                                      const Text("Open User Recent Location"),
                                  onPressed: () => MapUtils.openMap(
                                      locations[0].latitude!,
                                      locations[0].longitude!),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      widget.account!.verified!
                          ? Container()
                          : FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(widget.account!.userID)
                                  .collection("verification")
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return circularProgress();
                                } else {
                                  List<VerificationInfo> verificationInfos = [];

                                  snapshot.data!.docs.forEach((element) {
                                    VerificationInfo verificationInfo =
                                        VerificationInfo.fromDocument(element);

                                    verificationInfos.add(verificationInfo);
                                  });

                                  if (verificationInfos.isEmpty) {
                                    return Container();
                                  } else {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(
                                              verificationInfos.length,
                                              (index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Image.network(
                                                verificationInfos[index].url!,
                                                height: size.height * 0.25,
                                                width: size.width,
                                                fit: BoxFit.contain,
                                              ),
                                            );
                                          }),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(),
                                            CustomButton(
                                              title: "Verify User",
                                              color: Colors.teal,
                                              onTap: verifyUser,
                                            )
                                          ],
                                        )
                                      ],
                                    );
                                  }
                                }
                              },
                            ),
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
