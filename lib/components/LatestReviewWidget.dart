import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/PlaceModel.dart';
import '../models/UserModel.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/ReviewModel.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/text_styles.dart';

class LatestReviewWidget extends StatelessWidget {
  final List<ReviewModel> latestReview;

  LatestReviewWidget(this.latestReview);

  @override
  Widget build(BuildContext context) {
    return latestReview.isNotEmpty
        ? Container(
            width: (getBodyWidth(context) - 48) * 0.5,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(defaultRadius), boxShadow: commonBoxShadow()),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.latestReview, style: boldTextStyle()),
                    Text(language.viewAll, style: secondaryTextStyle()).onTap(() {
                      appStore.setMenuIndex(PLACE_REVIEW_INDEX);
                    }),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: latestReview.length,
                  itemBuilder: (context, index) {
                    ReviewModel item = latestReview[index];
                    return StreamBuilder<DocumentSnapshot>(
                      stream: placeService.documentById(item.placeId.validate()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.data() == null) return SizedBox();
                          PlaceModel place = PlaceModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                          return Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.black12),
                                  padding: EdgeInsets.all(1),
                                  child: cachedImage(place.image, height: 100, width: 100, fit: BoxFit.cover)),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(place.name.validate(), style: boldTextStyle(), maxLines: 1),
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: userService.documentById(item.userId.validate()),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data!.data() == null) return SizedBox();
                                        UserModel item = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                                        return Text('${language.user}: ${item.name}', style: primaryTextStyle(size: 14), maxLines: 1).paddingTop(8);
                                      } else {
                                        return SizedBox();
                                      }
                                    },
                                  ),
                                  if (item.comment.validate().isNotEmpty) Text('${language.comment}: ${item.comment!.trim()}', style: primaryTextStyle(size: 14), maxLines: 2).paddingTop(4),
                                  item.rating != null && item.rating != 0 ? ratingWidget(item.rating.validate()).paddingTop(4) : Offstage(),
                                ],
                              ).expand(),
                            ],
                          ).paddingTop(16);
                        } else {
                          return SizedBox();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          )
        : SizedBox();
  }
}
