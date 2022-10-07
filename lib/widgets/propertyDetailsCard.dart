import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rekodi/config.dart';
import 'package:rekodi/model/property.dart';
import 'package:rekodi/providers/tabProvider.dart';
import 'package:rekodi/widgets/customTextField.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PropertyDetailsCard extends StatefulWidget {
  final Property? property;

  const PropertyDetailsCard({Key? key, this.property}) : super(key: key);

  @override
  State<PropertyDetailsCard> createState() => _PropertyDetailsCardState();
}

class _PropertyDetailsCardState extends State<PropertyDetailsCard> {

  TextEditingController name = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController town = TextEditingController();
  TextEditingController notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      name.text = widget.property!.name!;
      country.text = widget.property!.country!;
      city.text = widget.property!.city!;
      address.text = widget.property!.address!;
      town.text = widget.property!.town!;
      notes.text = widget.property!.notes!;
    });
  }

  void updateInfo() async {
    await FirebaseFirestore.instance.collection("properties").doc(widget.property!.propertyID).update(
        {
          "name": name.text.trim(),
          "country": country.text.trim(),
          "city": city.text.trim(),
          "town": town.text.trim(),
          "address": address.text.trim(),
          "notes": notes.text,
        }).then((value) => Fluttertoast.showToast(msg: "Property Updated Successfully"));

    Navigator.pop(context);
  }

  showPropertyDetails(BuildContext context, Size size, bool isMobile) {
    double width = isMobile ? size.width*0.8 : size.width*0.4;

    showDialog(
      context:  context,
      builder: (c) {
        return AlertDialog(
          title: const Text("Property Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                controller: name,
                hintText: "Name",
                width: width,
                title: "Property Name",
                inputType: TextInputType.name,
              ),
              MyTextField(
                controller: address,
                hintText: "Address",
                width: width,
                title: "Physical Address",
                inputType: TextInputType.streetAddress,
              ),
              MyTextField(
                controller: town,
                hintText: "Town",
                width: width,
                title: "Town",
                inputType: TextInputType.text,
              ),
              MyTextField(
                controller: city,
                hintText: "City",
                width: width,
                title: "City",
                inputType: TextInputType.text,
              ),
              MyTextField(
                controller: country,
                hintText: "Country",
                width: width,
                title: "Country",
                inputType: TextInputType.text,
              ),
              MyTextField(
                controller: notes,
                hintText: "Notes",
                width: width,
                title: "Notes",
                inputType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            RaisedButton.icon(
              onPressed: updateInfo,
              label: const Text("Update", style: TextStyle(color: Colors.white),),
              color: EKodi().themeColor,
              icon: const Icon(Icons.check, color: Colors.white,),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveBuilder(
      builder: (context, sizeInfo) {
        bool isMobile = sizeInfo.isMobile || sizeInfo.isTablet;

        return  StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("properties").doc(widget.property!.propertyID).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData)
              {
                return const Text("Loading...");
              }
            else
              {
                Property property = Property.fromDocument(snapshot.data!);

                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: isMobile ? 5.0 : 10.0
                  ),
                  child: Container(
                    width: isMobile ? size.width : size.width*0.5,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Property Details", style: Theme.of(context).textTheme.titleMedium,),
                          const Divider(color: Colors.grey,),
                          Text(property.name!, style: Theme.of(context).textTheme.bodyMedium,),
                          Text("${property.address!}, ${property.city!} ${property.country!}", style: Theme.of(context).textTheme.bodyMedium,),
                          const SizedBox(height: 10.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: ()=> context.read<TabProvider>().changeTab("PropertyImages"),
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
                                    child: Center(child: Text("Manage images for your property", style: TextStyle(color: EKodi().themeColor),)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5.0,),
                              InkWell(
                                onTap: ()=> showPropertyDetails(context, size, isMobile),
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
                                    child: Center(child: Text("Edit Property", style: TextStyle(color: EKodi().themeColor),)),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
          },
        );
      },
    );
  }

}
