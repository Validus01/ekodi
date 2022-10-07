import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:responsive_builder/responsive_builder.dart';


class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {

  Widget _buildLayout(Size size, bool isMobile) {
    List<Widget> list = [
      ReportCard(
        title: "Income Expense Statement",
        description: "This is a profit and loss report that shows you all the income and expenses that have been assigned to a property.",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const IncomeExpenseStatement());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("IncomeExpenseStatement");
        },
      ),
      ReportCard(
        title: "Overdue Rent Payment",
        description: "Displays a list of all overdue rent payments within a period of time.",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const OverdueRentPayments());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("OverdueRentPayments");
        },
      ),
      ReportCard(
        title: "Rent Ledger Report",
        description: "Displays a list of all rent payments over a time period",
        onTap: () {
            //Route route = MaterialPageRoute(builder: (context)=> const RentLedgerReport());
            //isMobile ? Navigator.push(context, route) :
            context.read<TabProvider>().changeTab("RentLedgerReport");
        },
      ),
      ReportCard(
        title: "Service Provider Report",
        description: "A detailed report on service providers.",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const ServiceProviderReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("ServiceProviderReport");
        },
      ),
      ReportCard(
        title: "Task Report",
        description: "Get Detailed report on recent tasks",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const TaskReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("TaskReport");
        },
      ),
      ReportCard(
        title: "Lease Expiry Report",
        description: "Displays a report of leases that will expire within the given period.",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const LeaseExpiryReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("LeaseExpiryReport");
        },
      ),
      ReportCard(
        title: "Tenant Screening Report",
        description: "Get reports for the tenants you have screened",
        onTap: () {
          //Route route = MaterialPageRoute(builder: (context)=> const TenantScreeningReport());
          //isMobile ? Navigator.push(context, route) :
          context.read<TabProvider>().changeTab("TenantScreeningReport");
        },
      )
    ];

    return isMobile ? SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    ): Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reports", style: Theme.of(context).textTheme.headlineSmall,),
        const SizedBox(height: 10.0,),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: size.width*0.5/300.0,
          children: list,
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return _buildLayout(size, isMobile);
      },
    );
  }
}


class ReportCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Function()? onTap;

  const ReportCard({Key? key, this.title, this.description, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.insert_chart_outlined, color: EKodi().themeColor,),
                  const SizedBox(width: 5.0,),
                  Text(title!, style: const TextStyle(fontWeight: FontWeight.bold),)
                ],
              ),
              Text(description!, style: GoogleFonts.baloo2(),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  InkWell(
                    onTap: onTap,
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
                        child: Center(child: Text("View", style: TextStyle(color: EKodi().themeColor),)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
