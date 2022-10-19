import 'package:flutter/material.dart';


class LandingButton extends StatefulWidget {
  final void Function()? onTap;
  final Color? hoverFillColor;
  final Color? hoverBorderColor;
  final Color? borderColor;
  final Color? hoverTextColor;
  final Color? textColor;
  final double? fontSize;
  final IconData? iconData;
  final Color? hoverIconColor;
  final Color? iconColor;
  final String? title;

  const LandingButton({ Key? key, this.onTap, this.hoverFillColor, this.hoverBorderColor, this.borderColor, this.hoverTextColor, this.textColor, this.fontSize, this.iconData, this.hoverIconColor, this.iconColor, this.title }) : super(key: key);

  @override
  State<LandingButton> createState() => _LandingButtonState();
}

class _LandingButtonState extends State<LandingButton> {
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (v) {
        setState(() {
          onHover = v;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: onHover ? widget.hoverFillColor : Colors.transparent,
          border: Border.all(
            width: 1.0,
            color: onHover ? widget.hoverBorderColor! : widget.borderColor!,
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.title!, style: TextStyle(color: onHover ? widget.hoverTextColor : widget.textColor, fontSize: widget.fontSize,),),
              const SizedBox(width: 5.0,),
              Icon(widget.iconData, color: onHover ? widget.hoverIconColor! : widget.iconColor,)
            ],
          ),
        ),
      ),
    );
  }
}