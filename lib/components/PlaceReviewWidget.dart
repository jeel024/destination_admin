import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/PlaceModel.dart';
import '../models/ReviewModel.dart';
import '../models/UserModel.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../main.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/text_styles.dart';

class PlaceReviewWidget extends StatefulWidget {
  final String? placeId;

  PlaceReviewWidget({this.placeId});

  @override
  PlaceReviewWidgetState createState() => PlaceReviewWidgetState();
}

class PlaceReviewWidgetState extends State<PlaceReviewWidget> {
  List<ReviewModel> reviewList = [];
  ScrollController _scrollController = ScrollController();

  bool isLast = true;

  @override
  void initState() {
    super.initState();
    init();
    _scrollController.addListener(() async {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      if (maxScroll == currentScroll) {
        if (!isLast) {
          init();
        }
      }
    });
  }

  void init() async {
    appStore.setLoading(true);
    await reviewService.fetchReviewList(list: reviewList, placeId: widget.placeId).then((value) {
      appStore.setLoading(false);
      isLast = value.length < perPageLimit;
      reviewList.addAll(value);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget headingWidget() {
    return Text(language.placeReviews, style: boldTextStyle(size: 20, color: primaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          reviewList.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headingWidget(),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(defaultRadius), boxShadow: commonBoxShadow()),
                        child: SingleChildScrollView(
                          controller: ScrollController(),
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: getBodyWidth(context) - 48),
                            child: DataTable(
                              dataRowHeight: 120,
                              headingRowHeight: 45,
                              horizontalMargin: 16,
                              headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                              showCheckboxColumn: false,
                              dataTextStyle: primaryTextStyle(size: 14),
                              columnSpacing: 0,
                              headingTextStyle: boldTextStyle(),
                              columns: [
                                DataColumn(label: Text(language.index)),
                                DataColumn(label: ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text(language.comment))),
                                DataColumn(label: Text(language.rating)),
                                DataColumn(label: ConstrainedBox(constraints: BoxConstraints(maxWidth: 150),child: Text(language.place))),
                                DataColumn(label: ConstrainedBox(constraints: BoxConstraints(maxWidth: 150),child: Text(language.user))),
                                DataColumn(label: Text(language.createdAt)),
                              ],
                              rows: reviewList.map((ReviewModel mData) {
                                return DataRow(cells: [
                                  DataCell(Text('${reviewList.indexOf(mData) + 1}')),
                                  DataCell(ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text('${mData.comment.validate()}', softWrap: true, maxLines: 5))),
                                  DataCell(ratingWidget(mData.rating)),
                                  DataCell(
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: placeService.documentById(mData.placeId.validate()),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          PlaceModel item = PlaceModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                                          return ConstrainedBox(
                                            constraints: BoxConstraints(maxWidth: 150),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  decoration:BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius),color: Colors.black12),
                                                  padding:EdgeInsets.all(1),
                                                  child: cachedImage(item.image.validate(), fit: BoxFit.cover, height: 65, width: 65).onTap(() {
                                                    mLaunchUrl(item.image.validate());
                                                  }),
                                                ),
                                                8.height,
                                                Text('${item.name}',maxLines: 2),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return SizedBox();
                                        }
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: userService.documentById(mData.userId.validate()),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data!.data() != null) {
                                            UserModel item = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                                            return ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: 150),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    decoration:BoxDecoration(borderRadius: BorderRadius.circular(40),color: Colors.black12),
                                                    padding:EdgeInsets.all(1),
                                                    child: cachedImage(item.profileImg.validate(), fit: BoxFit.cover, height: 60, width: 60).onTap(() {
                                                      mLaunchUrl(item.profileImg.validate());
                                                    }).cornerRadiusWithClipRRect(40),
                                                  ),
                                                  8.height,
                                                  Text('${item.name}',maxLines: 2),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return SizedBox();
                                          }
                                        } else {
                                          return SizedBox();
                                        }
                                      },
                                    ),
                                  ),
                                  DataCell(Text(mData.createdAt != null ? printDate(mData.createdAt!) : '-')),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : !appStore.isLoading
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headingWidget(),
                        emptyWidget().expand(),
                      ],
                    ).paddingAll(16)
                  : SizedBox(),
          loaderWidget().visible(appStore.isLoading),
        ],
      );
    });
  }
}
