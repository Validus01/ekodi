import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/chat/chatBuilder.dart';
import 'package:rekodi/model/serviceProvider.dart';
import 'package:rekodi/pages/profilePage.dart';
import 'package:rekodi/widgets/billingCard.dart';
import 'package:rekodi/widgets/dateSelector.dart';
import 'package:rekodi/widgets/recentTransactionsCard.dart';
import 'package:rekodi/widgets/sliderWithCircle.dart';
import 'package:rekodi/widgets/todoCalendar.dart';

import '../../chat/chatDetails.dart';
import '../../chat/chatHome.dart';
import '../../chat/chatProvider/chatProvider.dart';
import '../../config.dart';
import '../../model/account.dart';
import '../../providers/datePeriod.dart';
import '../../providers/tabProvider.dart';
import '../../widgets/customAppBar.dart';
import '../../widgets/customDashDrawer.dart';
import 'package:rekodi/model/transaction.dart' as account_transaction;

import '../tenantInvoicePage.dart';

class TenantDash extends StatefulWidget {
  const TenantDash({Key? key}) : super(key: key);

  @override
  State<TenantDash> createState() => _TenantDashState();
}

class _TenantDashState extends State<TenantDash> {
  _TenantDashState();
  
  Widget dashboard(Account account, Size size, int startDate, int endDate) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: size.height * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Dashboard",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  DateSelector()
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35.0),
                    child: account.photoUrl! == ""
                        ? Image.asset(
                      "assets/profile.png",
                      height: 70.0,
                      width: 70.0,
                      fit: BoxFit.cover,
                    )
                        : Image.network(account.photoUrl!,
                        height: 70.0, width: 70.0, fit: BoxFit.cover),
                  ),
                  Expanded(
                    child: ListTile(
                      title: RichText(
                        text: TextSpan(
                          //style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Hi, ',
                                style:
                                GoogleFonts.baloo2(fontSize: 20.0)),
                            TextSpan(
                                text: account.name,
                                style: GoogleFonts.baloo2(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      subtitle: const Text(
                          "Welcome to e-KODI! Here's your activity."),
                      trailing: RaisedButton.icon(
                        elevation: 0.0,
                        hoverColor: Colors.transparent,
                        color: EKodi().themeColor.withOpacity(0.3),
                        icon: Icon(
                          Icons.cloud_download_outlined,
                          color: EKodi().themeColor,
                        ),
                        label: Text("Download Report",
                            style: TextStyle(
                                color: EKodi().themeColor,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {},
                      ),
                    ),
                  )
                ],
              ),
              const BillingCard(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    flex: 1,
                    child: RecentTransactionsCard()
                  ),
                  Expanded(
                    flex: 1,
                    child: SliderWithCircle(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const VerticalDivider(color: Colors.black26, thickness: 1.0, width: 1.0,),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TodoCalendar(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Service Providers",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.filter_list_rounded,
                          color: Colors.grey,
                        ),
                        offset: const Offset(0.0, 0.0),
                        onSelected: (v) {},
                        itemBuilder: (BuildContext context) {
                          return [
                            "Plumber",
                            "Electrician",
                            "Beauty & Cosmetics",
                            "Internet Service Provider(WiFi)",
                            "Cleaners",
                            "Wood & Metal Works",
                            "Tutor",
                            "Security",
                            "Other"
                          ].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("serviceProviders")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("Loading...");
                    } else {
                      List<ServiceProvider> providers = [];

                      snapshot.data!.docs.forEach((element) {
                        providers
                            .add(ServiceProvider.fromDocument(element));
                      });

                      if (providers.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Opacity(
                                opacity: 0.5,
                                child: Image.asset('assets/images/services_left_image.png', width: size.width*0.1, fit: BoxFit.contain,),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                "No service providers available",
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: providers.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            ServiceProvider provider = providers[index];

                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: InkWell(
                                child: Card(
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(15.0),
                                      child: provider.photoUrl! == ""
                                          ? Image.asset(
                                        "assets/profile.png",
                                        height: 30.0,
                                        width: 30.0,
                                        fit: BoxFit.cover,
                                      )
                                          : Image.network(
                                          provider.photoUrl!,
                                          height: 30.0,
                                          width: 30.0,
                                          fit: BoxFit.cover),
                                    ),
                                    title: Text(
                                      provider.title!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      provider.description!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.star_rate_outlined,
                                          color: Colors.grey,
                                        ),
                                        Text("${provider.rating} rating")
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget displayTab(Account account, String currentTab, Size size, int startDate, int endDate) {
    switch (currentTab) {
      case "Dashboard":
        return dashboard(account, size, startDate, endDate);
      case "Messages":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0,),
            TextButton.icon(
              onPressed: () {
                context.read<TabProvider>().changeTab("Dashboard");
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey,),
              label: const Text("Back", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20.0,),
            // const Text(
            //   "Messages",
            //   style: TextStyle(
            //       fontWeight: FontWeight.bold, fontSize: 20.0),
            // ),
            // const SizedBox(height: 20.0,),
            const ChatBuilder(),
          ],
        );
      case "Profile":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0,),
            TextButton.icon(
              onPressed: () {
                context.read<TabProvider>().changeTab("Dashboard");
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey,),
              label: const Text("Back", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20.0,),
            // const Text(
            //   "Profile",
            //   style: TextStyle(
            //       fontWeight: FontWeight.bold, fontSize: 20.0),
            // ),
            // const SizedBox(height: 20.0,),
            const ProfilePage(),
          ],
        );
      case "Accounting":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0,),
            TextButton.icon(
              onPressed: () {
                context.read<TabProvider>().changeTab("Dashboard");
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey,),
              label: const Text("Back", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20.0,),
            const Text(
              "Accounting",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            const SizedBox(height: 20.0,),
            Container(
                width: size.width,
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("users").doc(account.userID)
                    .collection("transactions").orderBy("timestamp", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData)
                  {
                    return const Text("Loading...");
                  }
                  else
                  {
                    List<account_transaction.Transaction> transactions = [];

                    snapshot.data!.docs.forEach((element) {
                      transactions.add(account_transaction.Transaction.fromDocument(element));
                    });

                    if(transactions.isEmpty)
                    {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.currency_exchange_rounded,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              const Text("No transactions")
                            ],
                          ),
                        ),
                      );
                    }
                    else
                    {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(transactions.length, (index) {
                          account_transaction.Transaction transaction = transactions[index];

                          return ListTile(
                            title: Text("Payment By: "+transaction.senderInfo!["name"]!, style: const TextStyle(fontWeight: FontWeight.bold),),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.transactionType!),
                                Divider(color: Colors.grey.shade300,)
                              ],
                            ),
                            trailing: Text("Kes ${transaction.paidAmount!}"),
                          );
                        }),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        );
      case "Reports":
        return const Center(
          child: Text("Reports"),
        );
      case "Tasks":
        return const Center(
          child: Text("Tasks"),
        );
      case "Invoice":
        return const TenantInvoicePage();
      default:
        return dashboard(account, size, startDate, endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;
    String currentTab = context.watch<TabProvider>().currentTab;

    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: CustomDashDrawer(),
        ),
        Expanded(
          flex: 8,
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: PreferredSize(
              preferredSize: Size(size.width, 60.0),
              child: DashboardAppBar(
                automaticallyImplyLeading: false,
                addPropertyButton: Container(),
              ),
            ),
            body: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  width: size.width,
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  child: Image.asset("assets/images/baner_dec_left.png"),
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: Image.asset("assets/images/baner_dec_right.png"),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: displayTab(account, currentTab, size, startDate, endDate),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class TenantDashMobile extends StatefulWidget {
  const TenantDashMobile({Key? key}) : super(key: key);

  @override
  State<TenantDashMobile> createState() => _TenantDashMobileState();
}

class _TenantDashMobileState extends State<TenantDashMobile> {

  _displayTabs(Account account, bool isChatOpen, String currentTab, Size size) {
    switch (currentTab) {
      case "Dashboard":
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      "Dashboard",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    DateSelector()
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35.0),
                    child: account.photoUrl! == ""
                        ? Image.asset(
                      "assets/profile.png",
                      height: 70.0,
                      width: 70.0,
                      fit: BoxFit.cover,
                    )
                        : Image.network(account.photoUrl!,
                        height: 70.0, width: 70.0, fit: BoxFit.cover),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ListTile(
                        title: RichText(
                          text: TextSpan(
                            //style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Hi, ',
                                  style:
                                  GoogleFonts.baloo2(fontSize: 20.0, color: Colors.black)),
                              TextSpan(
                                  text: account.name,
                                  style: GoogleFonts.baloo2(
                                      fontSize: 20.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        subtitle: const Text(
                            "Welcome to e-KODI! Here's your activity."),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.cloud_download_outlined,
                            color: EKodi().themeColor,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const BillingCard(),
              const RecentTransactionsCard(),
              const SliderWithCircle(),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TodoCalendar(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Service Providers",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.filter_list_rounded,
                            color: Colors.grey,
                          ),
                          offset: const Offset(0.0, 0.0),
                          onSelected: (v) {},
                          itemBuilder: (BuildContext context) {
                            return [
                              "Plumber",
                              "Electrician",
                              "Beauty & Cosmetics",
                              "Internet Service Provider(WiFi)",
                              "Cleaners",
                              "Wood & Metal Works",
                              "Tutor",
                              "Security",
                              "Other"
                            ].map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("serviceProviders")
                        .orderBy("timestamp", descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("Loading...");
                      } else {
                        List<ServiceProvider> providers = [];

                        for (var element in snapshot.data!.docs) {
                          providers
                              .add(ServiceProvider.fromDocument(element));
                        }

                        if (providers.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Image.asset('assets/images/services_left_image.png', width: size.width*0.6, fit: BoxFit.contain,),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "No service providers available",
                                  style: TextStyle(
                                    color: Colors.grey.shade300,
                                  ),
                                )
                              ],
                            ),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: providers.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              ServiceProvider provider = providers[index];

                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  child: Card(
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(15.0),
                                        child: provider.photoUrl! == ""
                                            ? Image.asset(
                                          "assets/profile.png",
                                          height: 30.0,
                                          width: 30.0,
                                          fit: BoxFit.cover,
                                        )
                                            : Image.network(
                                            provider.photoUrl!,
                                            height: 30.0,
                                            width: 30.0,
                                            fit: BoxFit.cover),
                                      ),
                                      title: Text(
                                        provider.title!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        provider.description!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.star_rate_outlined,
                                            color: Colors.grey,
                                          ),
                                          Text("${provider.rating} rating")
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }
                    },
                  )
                ],
              )
            ],
          ),
        );
      case "Accounting":
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20.0,),
                const Text(
                  "Accounting",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                const SizedBox(height: 20.0,),
                Container(
                  width: size.width,
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("users").doc(account.userID)
                        .collection("transactions").orderBy("timestamp", descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData)
                      {
                        return const Text("Loading...");
                      }
                      else
                      {
                        List<account_transaction.Transaction> transactions = [];

                        snapshot.data!.docs.forEach((element) {
                          transactions.add(account_transaction.Transaction.fromDocument(element));
                        });

                        if(transactions.isEmpty)
                        {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.currency_exchange_rounded,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  const Text("No transactions")
                                ],
                              ),
                            ),
                          );
                        }
                        else
                        {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(transactions.length, (index) {
                              account_transaction.Transaction transaction = transactions[index];

                              return ListTile(
                                title: Text("Payment By: "+transaction.senderInfo!["name"]!, style: const TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(transaction.transactionType!),
                                    Divider(color: Colors.grey.shade300,)
                                  ],
                                ),
                                trailing: Text("Kes ${transaction.paidAmount!}"),
                              );
                            }),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      case "Reports":
        return const Center(
          child: Text("Reports"),
        );
      case "Messages":
        return isChatOpen ? const ChatDetails() : const ChatHome();
      case "Tasks":
        return const Center(
          child: Text("Tasks"),
        );
      case "Profile":
        return const ProfilePage();
      case "Invoice":
        return const TenantInvoicePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    int startDate = context.watch<DatePeriodProvider>().startDate;
    int endDate = context.watch<DatePeriodProvider>().endDate;
    String currentTab = context.watch<TabProvider>().currentTab;
    bool isChatOpen = context.watch<ChatProvider>().isOpen;

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: const CustomDashDrawer(),
      appBar: PreferredSize(
        preferredSize: Size(size.width, 60.0),
        child: DashboardAppBar(
          automaticallyImplyLeading: true,
          addPropertyButton: Container(),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            child: Image.asset("assets/images/baner_dec_left.png"),
          ),
          Positioned(
            top: 0.0,
            right: 0.0,
            child: Image.asset("assets/images/baner_dec_right.png"),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            top: 0.0,
            child: _displayTabs(account, isChatOpen, currentTab, size),
          )
        ],
      ),
    );
  }
}

