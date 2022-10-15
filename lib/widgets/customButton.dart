import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String? title;
  final Color? color;
  final Function()? onTap;
  const CustomButton({Key? key, this.title, this.color, this.onTap})
      : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: widget.onTap!,
        onHover: (v) {
          setState(() {
            isHover = v;
          });
        },
        child: Container(
          height: 30.0,
          decoration: BoxDecoration(
              color: isHover ? widget.color! : Colors.transparent,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: widget.color!,
                width: 1.5,
              )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
              child: Text(
                widget.title!,
                style: TextStyle(
                  color: isHover ? Colors.white : widget.color!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}