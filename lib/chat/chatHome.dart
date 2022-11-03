import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/chat/chatProvider/chatProvider.dart';
import 'package:rekodi/chat/models/chat.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/providers/messageProvider.dart';
import 'package:rekodi/widgets/bulkSmsSection.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../config.dart';
import '../model/account.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  List<Account> results = [];
  List<Property> properties = [];
  bool loading = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    getMessages();
  }

  getMessages() async {
    setState(() {
      loading = true;
    });

    Account account = Provider.of<EKodi>(context, listen: false).account;

    await MessageProvider().updateMessagesDB(account);

    await Provider.of<MessageProvider>(context, listen: false)
        .updateChats(account);

    setState(() {
      loading = false;
    });
  }

  openDM(Account account, Account receiver) async {
    await context.read<ChatProvider>().switchAccount(receiver);

    await context.read<MessageProvider>().changeDMMessages(account, receiver);

    context.read<ChatProvider>().openChatDetails(true);
  }

  displayTenants(Account account) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: Colors.grey.shade300,
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            "My Tenants",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(account.userID)
              .collection("tenants")
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('Loading...'));
            } else {
              List<Account> tenants = [];

              snapshot.data!.docs.forEach((element) {
                tenants.add(Account.fromDocument(element));
              });

              if (tenants.isEmpty) {
                return const Center(
                  child: Text("You don't have Tenants"),
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(tenants.length, (index) {
                    Account tenant = tenants[index];

                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        child: ListTile(
                          onTap: () => openDM(account, tenant),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: tenant.photoUrl! == ""
                                ? Image.asset(
                                    "assets/profile.png",
                                    height: 30.0,
                                    width: 30.0,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(tenant.photoUrl!,
                                    height: 30.0,
                                    width: 30.0,
                                    fit: BoxFit.cover),
                          ),
                          title: Text(
                            tenant.name!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            tenant.accountType!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }
            }
          },
        ),
      ],
    );
  }

  searchUsers(
      BuildContext context, bool isMobile, Account account, Size size) async {
    setState(() {
      loading = true;
    });

    Navigator.pop(context);

    await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: controller.text.trim())
        .get()
        .then((value) {
      value.docs.forEach((element) {
        results.add(Account.fromDocument(element));
      });
    });

    await displayUserResults(context, isMobile, account, size);

    setState(() {
      loading = false;
    });
  }

  displayUserResults(
      BuildContext context, bool isMobile, Account account, Size size) {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: const Text("Select Person"),
            content: Container(
              height: isMobile ? size.width * 0.9 : size.height * 0.4,
              width: isMobile ? size.width * 0.9 : size.width * 0.4,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(results.length, (index) {
                  Account receiver = results[index];

                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);

                          openDM(account, receiver);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: receiver.photoUrl! == ""
                              ? Image.asset(
                                  "assets/profile.png",
                                  height: 30.0,
                                  width: 30.0,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(receiver.photoUrl!,
                                  height: 30.0, width: 30.0, fit: BoxFit.cover),
                        ),
                        title: Text(
                          receiver.name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          receiver.accountType!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // trailing: Column(
                        //   mainAxisSize: MainAxisSize.min,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     Icon(Icons.star_rate_outlined, color: Colors.grey,),
                        //     Text("${provider.rating} rating")
                        //   ],
                        // ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        });
  }

  displayDialog(
      BuildContext context, bool isMobile, Account account, Size size) {
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: const Text("Search People"),
            content: Container(
              height: isMobile ? size.width * 0.9 : size.height * 0.4,
              width: isMobile ? size.width * 0.9 : size.width * 0.4,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextField(
                    controller: controller,
                    hintText: "Email Address",
                    //width: size.width,
                    title: "Search By Email",
                    inputType: TextInputType.emailAddress,
                  ),
                  RaisedButton.icon(
                    onPressed: () =>
                        searchUsers(context, isMobile, account, size),
                    color: EKodi.themeColor,
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Search",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Messages",
              style: GoogleFonts.baloo2(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton.icon(
                  onPressed: () =>
                      displayDialog(context, isMobile, account, size),
                  color: EKodi.themeColor,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Add Chat",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: loading
              ? const LoadingAnimation()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<List<Chat>>(
                        future: context.watch<MessageProvider>().futureChats,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const LoadingAnimation();
                          } else {
                            List<Chat> chats = snapshot.data!;

                            if (chats.isEmpty) {
                              return const Center(
                                child: Text('No Chats'),
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      "Recent Chats",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        List.generate(chats.length, (index) {
                                      Chat chat = chats[index];
                                      bool isMe =
                                          chat.messages!.last.senderID ==
                                              account.userID;
                                      Account receiver = Account(
                                        name: isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['name']
                                            : chat.messages!.last
                                                .senderInfo!['name'],
                                        userID: isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['userID']
                                            : chat.messages!.last
                                                .senderInfo!['userID'],
                                        photoUrl: isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['photoUrl']
                                            : chat.messages!.last
                                                .senderInfo!['photoUrl'],
                                        email: isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['email']
                                            : chat.messages!.last
                                                .senderInfo!['email'],
                                        phone: isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['phone']
                                            : chat.messages!.last
                                                .senderInfo!['phone'],
                                        idNumber: isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['idNumber']
                                            : chat.messages!.last
                                                .senderInfo!['idNumber'],
                                        accountType: isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['accountType']
                                            : chat.messages!.last
                                                .senderInfo!['accountType'],
                                        deviceTokens: isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['deviceTokens']
                                            : chat.messages!.last
                                                .senderInfo!['deviceTokens'],
                                      );

                                      return ListTile(
                                        onTap: () => openDM(account, receiver),
                                        leading: const Icon(
                                          Icons.account_circle_rounded,
                                          color: Colors.grey,
                                        ),
                                        title: Text(isMe
                                            ? chat.messages!.last
                                                .receiverInfo!['name']
                                            : chat.messages!.last
                                                .senderInfo!['name']),
                                        subtitle: Text(
                                          isMe
                                              ? "You: ${chat.messages!.last.messageDescription}"
                                              : chat.messages!.last
                                                  .messageDescription!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Text(
                                            DateFormat('HH:mm dd MMM').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        chat.messages!.last
                                                            .timestamp!))),
                                      );
                                    }),
                                  ),
                                ],
                              );
                            }
                          }
                        },
                      ),
                      account.accountType == "Landlord" ||
                              account.accountType == "Agent"
                          ? displayTenants(account)
                          : Container(),
                      isMobile
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: account.accountType == "Landlord" ||
                                      account.accountType == "Agent"
                                  ? const BulkSMSSection()
                                  : Container(),
                            )
                          : Container()
                    ],
                  ),
                ),
        );
      },
    );
  }
}
