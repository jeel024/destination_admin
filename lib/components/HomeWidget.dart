import '../main.dart';
import '../utils/AppConstant.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../models/DashboardResponse.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/text_styles.dart';
import 'LatestPlacesWidget.dart';
import 'LatestReviewWidget.dart';
import 'MostFavouritePlacesWidget.dart';
import 'MostRatedPlacesWidget.dart';

class HomeWidget extends StatefulWidget {
  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget countWidget({required String title, required int count, required int menuIndex, required IconData icon}) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Container(
          width: 235,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            boxShadow: commonBoxShadow(),
            color: context.cardColor,
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: primaryTextStyle()),
              SizedBox(height: 30),
              Text(count.toString(), style: boldTextStyle(size: 24))
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
              Color(0xFF00BBBA),
              Color(0xFF6AC6BB),
            ]),
          ),
          child: Icon(icon, size: 28, color: Colors.white),
        ),
      ],
    ).onTap(() {
      appStore.setMenuIndex(menuIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<DashboardResponse>(
      future: placeService.getDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(snapshot.data == null) return emptyWidget();
          return SingleChildScrollView(
            controller: ScrollController(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    countWidget(
                      title: language.totalUsers,
                      count: snapshot.data!.userCount.validate(),
                      menuIndex: USER_INDEX,
                      icon: Feather.users,
                    ),
                    countWidget(
                      title: language.totalCategories,
                      count: snapshot.data!.categoryCount.validate(),
                      menuIndex: CATEGORY_INDEX,
                      icon: Feather.list,
                    ),
                    countWidget(
                      title: language.totalStates,
                      count: snapshot.data!.stateCount.validate(),
                      menuIndex: STATE_INDEX,
                      icon: Ionicons.location_outline,
                    ),
                    countWidget(
                      title: language.totalPlaces,
                      count: snapshot.data!.placesCount.validate(),
                      menuIndex: PLACE_INDEX,
                      icon: MaterialCommunityIcons.city_variant_outline,
                    ),
                    countWidget(
                      title: language.totalReviews,
                      count: snapshot.data!.reviewCount.validate(),
                      menuIndex: PLACE_REVIEW_INDEX,
                      icon: FontAwesome.star_o,
                    ),
                  ],
                ),
                16.height,
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    if((snapshot.data!.latestPlaces ?? []).isNotEmpty) LatestPlacesWidget(snapshot.data!.latestPlaces ?? []),
                    if((snapshot.data!.latestReview ?? []).isNotEmpty) LatestReviewWidget(snapshot.data!.latestReview ?? []),
                    if((snapshot.data!.mostRatedPlaces ?? []).isNotEmpty) MostRatedPlacesWidget(snapshot.data!.mostRatedPlaces ?? []),
                    if((snapshot.data!.mostFavouritePlaces ?? []).isNotEmpty) MostFavouritePlacesWidget(snapshot.data!.mostFavouritePlaces ?? []),
                  ],
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return errorWidget(text: snapshot.error.toString());
        } else {
          return loaderWidget();
        }
      },
    );
  }
}
