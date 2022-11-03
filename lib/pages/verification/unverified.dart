import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/widgets/customButton.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../model/account.dart';
import '../../routes.dart';

class UnverifiedCard extends StatelessWidget {
  const UnverifiedCard({Key? key}) : super(key: key);

  Widget _buildMobile(BuildContext context, Size size, Account account) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          verifyImage(size, true),
          const SizedBox(
            height: 10.0,
          ),
          _buildDescription(context, account, size, true)
        ],
      ),
    );
  }

  Widget _buildDescription(
      BuildContext context, Account account, Size size, bool isMobile) {
    String verificationStatus = account.verification!["status"];

    switch (verificationStatus) {
      case "unverified":
        return unverifiedDescription(context, account, size, isMobile);
      case "pending":
        return pendingDescription(context, account, size, isMobile);
      default:
        return unverifiedDescription(context, account, size, isMobile);
    }
  }

  Widget pendingDescription(
      BuildContext context, Account account, Size size, bool isMobile) {
    String time = DateFormat("HH:mm a, dd MMM yyyy").format(
        DateTime.fromMillisecondsSinceEpoch(
            account.verification!["timestamp"]));

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pending Verification",
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
              "Hello ${account.name}, your verification details were sent on $time pending verification. This will take upto 24 hours for your verification to be complete."),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                title: "Contact Us",
                color: Colors.pink,
                onTap: () {
                  launch("tel:${EKodi.contactPhone}");
                },
              ),
              const SizedBox()
            ],
          )
        ]);
  }

  Widget unverifiedDescription(
      BuildContext context, Account account, Size size, bool isMobile) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Verify your account",
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
              "Hello ${account.name}, we need to verify your account so that you can start uploading properties. Click below to get started!"),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                title: "Get Verified",
                color: Colors.pink,
                onTap: () {
                  CustomRoutes.router.navigateTo(context, "/verification");
                },
              ),
              const SizedBox()
            ],
          )
        ]);
  }

  Widget verifyImage(Size size, bool isMobile) {
    return isMobile
        ? Image.asset(
            "assets/vector/verify.jpg",
            width: size.width,
            height: size.height * 0.5,
            fit: BoxFit.contain,
          )
        : Image.asset(
            "assets/vector/verify.jpg",
            height: size.height * 0.7,
            width: size.width * 0.35,
            fit: BoxFit.contain,
          );
  }

  Widget _buildDesktop(BuildContext context, Size size, Account account) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verifyImage(size, false),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: _buildDescription(context, account, size, false),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = context.watch<EKodi>().account;
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.isMobile;

        return isMobile
            ? _buildMobile(context, size, account)
            : _buildDesktop(context, size, account);
      },
    );
  }
}
