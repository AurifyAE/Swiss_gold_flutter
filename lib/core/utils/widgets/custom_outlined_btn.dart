import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomOutlinedBtn extends StatelessWidget {
  final void Function()? onTapped;
  final String? btnText;
  final double borderRadius;
  final IconData? btnIcon;
  final Color borderColor;
  final Color? btnTextColor;
  final Color? iconColor;
  final double padH;
  final double padV;
  final MainAxisAlignment? align;
  final double? fontSize;
  final double? width;
  final double? height;

  const CustomOutlinedBtn(
      {super.key,
      this.onTapped,
      this.btnText,
      this.btnIcon,
      required this.borderRadius,
      required this.borderColor,
      this.btnTextColor,
      this.iconColor,
      required this.padH,
      required this.padV,
      this.fontSize,
      this.width,
      this.height, this.align});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: align?? MainAxisAlignment.center,
            children: [
              btnText != null
                  ? Text(
                      btnText!,
                      style: TextStyle(
                          color: btnTextColor, fontSize: fontSize ?? 14.sp),
                    )
                  : SizedBox.shrink(),
              btnIcon != null
                  ? Icon(
                      btnIcon,
                      color: iconColor,
                    )
                  : SizedBox.shrink(),
            ],
          )),
    );
  }
}
