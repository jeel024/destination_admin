import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/PlaceModel.dart';
import '../screens/DashboardScreen.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/text_styles.dart';

class MostFavouritePlacesWidget extends StatelessWidget {
  final List<PlaceModel> mostFavouritePlaces;

  MostFavouritePlacesWidget(this.mostFavouritePlaces);

  @override
  Widget build(BuildContext context) {
    return mostFavouritePlaces.isNotEmpty
        ? Container(
            width: (getBodyWidth(context) - 48) * 0.5,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(defaultRadius), boxShadow: commonBoxShadow()),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.mostFavouritePlaces, style: boldTextStyle()),
                    Text(language.viewAll, style: secondaryTextStyle()).onTap(() {
                      appStore.setMenuIndex(PLACE_INDEX);
                      DashboardScreen(placeType: PlaceTypeMostFavourite).launch(context);
                    }),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: mostFavouritePlaces.length,
                  itemBuilder: (context, index) {
                    PlaceModel item = mostFavouritePlaces[index];
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
                            Text(item.name.validate(), style: boldTextStyle(), maxLines: 2),
                            Row(
                              children: [
                                Text('${item.favourites ?? 0}', style: primaryTextStyle(size: 14)),
                                8.width,
                                Icon(Icons.favorite, color: Colors.red, size: 20),
                              ],
                            ).paddingTop(8),
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
