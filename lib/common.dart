import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Common {
  static void openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        //universalLinksOnly: true,
      );
    } else {
      Fluttertoast.showToast(msg: "Error opening: $url");
      //throw 'There was a problem to open the url: $twitterUrl';
    }
  }
}
