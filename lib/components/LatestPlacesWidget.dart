import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/StateModel.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/CategoryModel.dart';
import '../models/PlaceModel.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/text_styles.dart';

class LatestPlacesWidget extends StatelessWidget {
  final List<PlaceModel> latestPlaces;

  LatestPlacesWidget(this.latestPlaces);

  @override
  Widget build(BuildContext context) {
    return latestPlaces.isNotEmpty
        ? Container(
            width: (getBodyWidth(context) - 48) * 0.5,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(defaultRadius), boxShadow: commonBoxShadow()),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.latestPlaces, style: boldTextStyle()),
                    Text(language.viewAll, style: secondaryTextStyle()).onTap(() {
                      appStore.setMenuIndex(PLACE_INDEX);
                    }),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: latestPlaces.length,
                  itemBuilder: (context, index) {
                    PlaceModel item = latestPlaces[index];
                    return Row(
                      children: [
                        Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.black12),
                            padding: EdgeInsets.all(1),
                            child: cachedImage(item.image, height: 100, width: 100, fit: BoxFit.cover)),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name.validate(), style: boldTextStyle(), maxLines: 1),
                            if (item.address.validate().isNotEmpty) Text('${language.address}: ${item.address}', style: primaryTextStyle(size: 14), maxLines: 2).paddingTop(8),
                            StreamBuilder<DocumentSnapshot>(
                              stream: stateService.documentById(item.stateId.validate()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.data() == null) return SizedBox();
                                  StateModel item = StateModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                                  return Text('${language.state}: ${item.name}', style: primaryTextStyle(size: 14), maxLines: 1).paddingTop(4);
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                            StreamBuilder<DocumentSnapshot>(
                              stream: categoryService.documentById(item.categoryId.validate()),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.data() == null) return SizedBox();
                                  CategoryModel item = CategoryModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                                  return Text('${language.category}: ${item.name}', style: primaryTextStyle(size: 14), maxLines: 1).paddingTop(4);
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                          ],
                        ).expand(),
                      ],
                    ).paddingTop(16);
                  },
                ),
              ],
            ),
          )
        : SizedBox();
  }
}
