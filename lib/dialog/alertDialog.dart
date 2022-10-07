import 'package:flutter/material.dart';
import 'package:rekodi/widgets/loadingAnimation.dart';

class LoadingAlertDialog extends StatelessWidget
{
  final String? message;
  const LoadingAlertDialog({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 300.0,
            width: MediaQuery.of(context).size.width*0.4,
            child: const LoadingAnimation(),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(message!),
        ],
      ),
    );
  }
}