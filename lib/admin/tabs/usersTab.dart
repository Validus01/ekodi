import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rekodi/admin/widgets/userListItem.dart';
import 'package:rekodi/admin/widgets/usersCard.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/account.dart';
import 'package:rekodi/widgets/ProgressWidget.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({Key? key}) : super(key: key);

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  String tab = "All";

  Widget _buildUsersList(List<Account> accounts) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$tab Users",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.grey,
                    //size: 25.0,
                  ),
                  offset: const Offset(0.0, 10.0),
                  onSelected: (v) {
                    setState(() {
                      tab = v;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      "All",
                      "Verified",
                      "Unverified",
                      "Pending(Verification)"
                    ].map((String choice) {
                      bool isSelected = choice == tab;
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: TextStyle(
                              color: isSelected ? Colors.pink : Colors.grey),
                        ),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            const Divider(
              height: 20.0,
              thickness: 1.0,
              color: Colors.grey,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(generateAccountGroups(accounts).length,
                  (index) {
                Account account = generateAccountGroups(accounts)[index];

                return UserListItem(account: account);
              }),
            )
          ],
        ),
      ),
    );
  }

  List<Account> generateAccountGroups(List<Account> accounts) {
    switch (tab) {
      case "All":
        return accounts;
      case "Verified":
        return accounts
            .where((element) => element.verification!["status"] == "verified")
            .toList();
      case "Unverified":
        return accounts
            .where((element) => element.verification!["status"] == "unverified")
            .toList();
      case "Pending(Verification)":
        return accounts
            .where((element) => element.verification!["status"] == "pending")
            .toList();
      default:
        return accounts;
    }
  }

  Widget headerWidget(
    Size size,
  ) {
    return Container(
      height: size.height * 0.25,
      width: size.width,
      color: EKodi.themeColor.withOpacity(0.4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800.0, minWidth: 300),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Users",
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .apply(color: Colors.white),
              ),
              const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<Account> accounts = [];

          snapshot.data!.docs.forEach((element) {
            Account account = Account.fromDocument(element);

            accounts.add(account);
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget(size),
              UsersCard(
                accounts: accounts,
              ),
              const SizedBox(
                height: 20.0,
              ),
              _buildUsersList(accounts),
              const SizedBox(
                height: 50.0,
              ),
            ],
          );
        }
      },
    );
  }
}
