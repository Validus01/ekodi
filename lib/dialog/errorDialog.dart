import 'package:flutter/material.dart';

class ErrorAlertDialog extends StatelessWidget
{
  final String? message;
  const ErrorAlertDialog({Key? key, this.message}) : super(key: key);


  @override
  Widget build(BuildContext context)
  {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: <Widget>[
        RaisedButton(onPressed: ()
        {
          Navigator.pop(context);
        },
          color: Colors.red,
          child: const Center(
            child: Text("OK"),
          ),
        )
      ],
    );
  }
}