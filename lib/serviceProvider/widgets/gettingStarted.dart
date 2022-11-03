import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config.dart';
import '../../model/account.dart';
import '../../routes.dart';
import '../../widgets/customButton.dart';

class GettingStarted extends StatelessWidget {
  const GettingStarted({ Key? key }) : super(key: key);

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
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Get Started",
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
              "Hello ${account.name}, just one more step to get you up and running. Create your service provision profile. Click below to get started."),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                title: "Get Started!",
                color: Colors.pink,
                onTap: () {
                  CustomRoutes.router.navigateTo(context, "/getting_started");
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
