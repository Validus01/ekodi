import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../widgets/customTextField.dart';
import '../models/ratingItem.dart';

class Ratings extends StatefulWidget {
  const Ratings({Key? key}) : super(key: key);

  @override
  State<Ratings> createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => const RatingsMobile(),
      tablet: (BuildContext context) => const RatingsMobile(),
      desktop: (BuildContext context) => const RatingsDesktop(),
      watch: (BuildContext context) => Container(color: Colors.white),
    );
  }
}

class RatingsMobile extends StatelessWidget {
  const RatingsMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Ratings & Reviews!",
            style: Theme.of(context).textTheme.headline4,
          ),
          const SizedBox(
            height: 20.0,
          ),
          Container(
            height: 3.0,
            width: size.width * 0.1,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 20.0,
          ),
          const OveralRating(),
          const Reviews(),
          const RateButton()
        ],
      ),
    );
  }
}

class RatingsDesktop extends StatelessWidget {
  const RatingsDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveWrapper.builder(
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Ratings & Reviews!",
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Container(
              height: 3.0,
              width: size.width * 0.1,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  flex: 4,
                  child: OveralRating(),
                ),
                VerticalDivider(
                  color: Colors.grey,
                ),
                Expanded(
                  flex: 6,
                  child: Reviews(),
                )
              ],
            ),
            const RateButton(),
            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
        maxWidth: 1000,
        minWidth: 480,
        defaultScale: true,
        breakpoints: const [
          ResponsiveBreakpoint.resize(480, name: MOBILE),
          ResponsiveBreakpoint.autoScale(800, name: TABLET),
          ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ResponsiveBreakpoint.autoScale(2460, name: '4K')
        ],
        background: Container(color: Colors.transparent));
  }
}

class Reviews extends StatelessWidget {
  const Reviews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reviews",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("ratings")
              .where("review", isNotEqualTo: "")
              .limit(2)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else {
              List<RatingItem> ratingItems = [];

              snapshot.data!.docs.forEach((element) {
                RatingItem item = RatingItem.fromDocument(element);

                ratingItems.add(item);
              });

              if (ratingItems.isEmpty) {
                return Container();
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ratingItems.length,
                  itemBuilder: (context, index) {
                    RatingItem item = ratingItems[index];

                    return ListTile(
                      contentPadding: EdgeInsets.only(right: size.width * 0.1),
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade50,
                        radius: 20.0,
                        child: Center(
                          child: Text(
                            item.username!.split("").first,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      title: Text(
                        item.username!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBar.builder(
                            initialRating: item.rating!.toDouble(),
                            minRating: 1,
                            itemSize: 15.0,
                            ignoreGestures: true,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                          Text(
                            item.review!,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text(DateFormat("dd MMM yyyy").format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  item.timestamp!)))
                        ],
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class OveralRating extends StatelessWidget {
  const OveralRating({Key? key}) : super(key: key);

  int findOccurances(int v, List<dynamic> ratings) {
    if (ratings.isEmpty || ratings == null) {
      return 0;
    }

    var foundElements = ratings.where((element) => element == v);

    return foundElements.length;
  }

  double getPercentage(int v, List<dynamic> ratings) {
    double percentage = findOccurances(v, ratings) / ratings.length;

    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("overallRating")
          .doc("overall")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          List<dynamic> ratings = snapshot.data!["ratings"];

          String average = (ratings.reduce((a, b) => a + b) / ratings.length)
              .toStringAsFixed(1);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Overal Rating",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Text(
                average,
                style: Theme.of(context).textTheme.headline3,
              ),
              RatingBar.builder(
                initialRating: double.parse(average),
                minRating: 1,
                maxRating: 5,
                direction: Axis.horizontal,
                ignoreGestures: true,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  print(rating);
                },
              ),
              Text(
                "Based on ${ratings.length} reviews",
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RatingCategory(
                    title: "Excellent",
                    color: Colors.teal,
                    percent: getPercentage(5, ratings),
                  ),
                  RatingCategory(
                    title: "Good",
                    color: Colors.lightGreen,
                    percent: getPercentage(4, ratings),
                  ),
                  RatingCategory(
                    title: "Average",
                    color: Colors.yellow,
                    percent: getPercentage(3, ratings),
                  ),
                  RatingCategory(
                    title: "Below Average",
                    color: Colors.orange,
                    percent: getPercentage(2, ratings),
                  ),
                  RatingCategory(
                    title: "Poor",
                    color: Colors.red,
                    percent: getPercentage(1, ratings),
                  ),
                ],
              )
            ],
          );
        }
      },
    );
  }
}

class RateButton extends StatefulWidget {
  const RateButton({
    Key? key,
  }) : super(key: key);

  @override
  State<RateButton> createState() => _RateButtonState();
}

class _RateButtonState extends State<RateButton> {
  TextEditingController review = TextEditingController();
  TextEditingController email = TextEditingController();
  bool onHover = false;
  int _rateValue = 5;

  saveRateInfoToDB() async {
    try {
      Fluttertoast.showToast(msg: "Sending...");

      RatingItem ratingItem = RatingItem(
        username: email.text.split("@").first,
        email: email.text.trim(),
        review: review.text.isEmpty ? "" : review.text,
        rating: _rateValue,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await FirebaseFirestore.instance
          .collection("ratings")
          .doc(ratingItem.timestamp.toString())
          .set(ratingItem.toMap())
          .then((value) =>
              Fluttertoast.showToast(msg: "Thank You for Rating Me!"));

      await FirebaseFirestore.instance
          .collection("overallRating")
          .doc("overall")
          .get()
          .then((docSnapshot) async {
        if (docSnapshot.exists) {
          List<dynamic> ratings = docSnapshot["ratings"];

          ratings.add(_rateValue);

          await docSnapshot.reference.update({
            "ratings": ratings,
          });
        } else {
          await docSnapshot.reference.set({
            "ratings": [_rateValue],
          });
        }
      });

      review.clear();
      email.clear();
    } catch (e) {
      Fluttertoast.showToast(msg: "An Error Occured: ${e.toString()}");
    }
  }

  displayRatingAndReview() {
    Size size = MediaQuery.of(context).size;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ResponsiveBuilder(
              builder: (context, sizeInfo) {
                bool isDesktop = sizeInfo.isDesktop;

                return AlertDialog(
                  title: const Text("Rate Us!"),
                  content: Container(
                    //height: isDesktop ? size.height * 0.6 : size.height * 0.4,
                    width: isDesktop ? size.width * 0.4 : size.width * 0.8,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RatingBar.builder(
                          initialRating: 5,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rateValue = rating.toInt();
                            });

                            this.setState(() {});
                          },
                        ),
                        CustomTextField(
                          title: "Email Address *",
                          hintText: "Email",
                          inputType: TextInputType.emailAddress,
                          controller: email,
                        ),
                        CustomTextField(
                          title: "Write a Review (Optional)",
                          hintText: "Type something here...",
                          inputType: TextInputType.text,
                          controller: review,
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton.icon(
                      onPressed: () {
                        if (email.text.isNotEmpty) {
                          Navigator.pop(context);

                          saveRateInfoToDB();
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please Enter Email Address");
                        }
                      },
                      icon: Icon(Icons.done,
                          color: Theme.of(context).primaryColor),
                      label: Text(
                        "Done",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              displayRatingAndReview();
            },
            onHover: (v) {
              setState(() {
                onHover = v;
              });
            },
            child: Container(
              height: 30.0,
              width: 120.0,
              decoration: BoxDecoration(
                  color: onHover ? Colors.pink : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color: Colors.pink,
                    width: 1.5,
                  )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Text(
                    "RATE Us!",
                    style: TextStyle(
                      color: onHover ? Colors.white : Colors.pink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RatingCategory extends StatelessWidget {
  final String? title;
  final Color? color;
  final double? percent;
  const RatingCategory({Key? key, this.title, this.color, this.percent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title!),
        const SizedBox(
          width: 5.0,
        ),
        LinearPercentIndicator(
          width: size.width * 0.2,
          lineHeight: 5.0,
          percent: percent!,
          animation: true,
          animationDuration: 2500,
          linearStrokeCap: LinearStrokeCap.butt,
          backgroundColor: Colors.grey.shade200,
          progressColor: color,
        )
      ],
    );
  }
}
