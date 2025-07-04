import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'AppColor.dart';
import 'AppConstant.dart';
import 'AppImages.dart';
import 'Extensions/Commons.dart';
import 'Extensions/Constants.dart';
import 'Extensions/decorations.dart';
import 'Extensions/shared_pref.dart';
import 'Extensions/text_styles.dart';

getMenuWidth() {
  return appStore.isMenuExpanded ? 240 : 80;
}

getBodyWidth(BuildContext context) {
  return MediaQuery.of(context).size.width - getMenuWidth();
}

InputDecoration commonInputDecoration({Widget? prefixIcon, String? hintText, Widget? suffixIcon}) {
  return InputDecoration(
    contentPadding: EdgeInsets.all(12),
    filled: true,
    prefixIcon: prefixIcon != null
        ? IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                10.width,
                prefixIcon,
                VerticalDivider(color: Colors.grey.withOpacity(0.3)),
                10.width,
              ],
            ),
          )
        : null,
    fillColor: Colors.grey.withOpacity(0.10),
    hintText: hintText.validate(),
    hintStyle: secondaryTextStyle(size: 14),
    counterText: '',
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(defaultRadius)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
  );
}

Widget dialogSecondaryButton(String title, Function() onTap) {
  return SizedBox(
    width: 120,
    height: 35,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: appStore.isDarkMode ? Colors.white12 : Colors.black12)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent),
      child: Text(title, style: boldTextStyle(color: Colors.grey)),
      onPressed: onTap,
    ),
  );
}

Widget dialogPrimaryButton(String title, Function() onTap, {Color? color}) {
  return SizedBox(
    width: 120,
    height: 35,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        elevation: 0,
        backgroundColor: color ?? primaryColor,
      ),
      child: Text(title, style: boldTextStyle(color: Colors.white)),
      onPressed: onTap,
    ),
  );
}

List<BoxShadow> commonBoxShadow() {
  return [BoxShadow(color: Colors.black12, blurRadius: 10.0, spreadRadius: 0)];
}

Widget outlineActionIcon(IconData icon, Color color, String message, Function() onTap) {
  return GestureDetector(
    child: Tooltip(
      message: message,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(defaultRadius / 2),
            border: Border.all(color: color),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
      ),
    ),
    onTap: onTap,
  );
}

Widget addButton(String title, Function() onTap) {
  return GestureDetector(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle_outline, color: Colors.white),
          SizedBox(width: 12),
          Text(title, style: boldTextStyle(color: Colors.white)),
        ],
      ),
    ),
    onTap: onTap,
  );
}

deleteConfirmationDialog(BuildContext context, Function() onDelete, {String? title, String? subtitle}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        actionsPadding: EdgeInsets.all(16),
        content: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), shape: BoxShape.circle),
                padding: EdgeInsets.all(16),
                child: Icon(Icons.delete, color: Colors.red),
              ),
              SizedBox(height: 30),
              Text(title.validate(), style: primaryTextStyle(size: 24), textAlign: TextAlign.center),
              SizedBox(height: 16),
              Text(subtitle.validate(), style: secondaryTextStyle(), textAlign: TextAlign.center),
              SizedBox(height: 8),
            ],
          ),
        ),
        actions: <Widget>[
          dialogSecondaryButton(language.no, () {
            Navigator.pop(context);
          }),
          dialogPrimaryButton(language.yes, () {
            if (getBoolAsync(IS_DEMO_ADMIN)) {
              return toast(language.demoAdminMsg);
            } else {
              onDelete.call();
            }
          }, color: Colors.red),
        ],
      );
    },
  );
}

Widget emptyWidget({String? text}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(no_data, height: 100, width: 100),
        Text(text ?? language.noDataFound, style: primaryTextStyle()),
      ],
    ),
  );
}

Widget errorWidget({String? text}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline),
        16.height,
        Text(text ?? language.somethingWentWrong, style: primaryTextStyle()),
      ],
    ),
  );
}

Widget loaderWidget() {
  return Container(
    padding: EdgeInsets.all(8),
    height: 35,
    width: 35,
    decoration: BoxDecoration(
      color: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
      shape: BoxShape.circle,
      boxShadow: defaultBoxShadow(shadowColor: Colors.black.withOpacity(0.1)),
    ),
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation(primaryColor),
    ),
  ).center();
}

Widget cachedImage(String? url, {double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, bool usePlaceholderIfUrlEmpty = true, double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      filterQuality: FilterQuality.high,
      errorWidget: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
    ).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  } else {
    return Image.asset(url!, height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset('assets/icons/logo3.jpg', height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

String printDate(DateTime date) {
  return DateFormat.yMd().add_jm().format(date);
}

Widget ratingWidget(num? rating) {
 /* return Row(
    children: [
      RatingBar(
        ratingWidget: RatingWidget(
          empty: Icon(Icons.star, color: appStore.isDarkMode ? Colors.white24 : Colors.black26),
          full: Icon(Icons.star, color: Colors.amber),
          half: Icon(Icons.star_half, color: Colors.amber),
        ),
        onRatingUpdate: (value) {},
        initialRating: rating != null ? rating.toDouble() : 0,
        itemSize: 20,
        ignoreGestures: true,
      ),
      4.width,
      rating != null && rating != 0 ? Text('${rating.toStringAsFixed(2)}', style: primaryTextStyle(size: 14)) : SizedBox(),
    ],
  );*/
  return rating != null && rating != 0 ? Container(
    padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
    decoration: boxDecorationWithRoundedCornersWidget(backgroundColor: primaryColor, borderRadius: radius(defaultRadius * 0.5)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(rating.toStringAsFixed(2), style: secondaryTextStyle(color: whiteColor)),
        2.width,
        Icon(Icons.star_rate_sharp, size: 16, color: Colors.amber),
      ],
    ),
  ) : Text('-');
}

Future<void> saveFcmTokenId() async {
  await FirebaseMessaging.instance.getToken().then((value) {
    if (value!.isNotEmpty.validate()) setValue(FCM_TOKEN, value.validate());
  });
}
