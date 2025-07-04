import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../main.dart';
import '../models/CategoryModel.dart';
import '../models/PlaceModel.dart';
import '../models/StateModel.dart';
import '../models/UserModel.dart';
import '../screens/DashboardScreen.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/text_styles.dart';

class PlacesRequestWidget extends StatefulWidget {
  @override
  PlacesRequestWidgetState createState() => PlacesRequestWidgetState();
}

class PlacesRequestWidgetState extends State<PlacesRequestWidget> {
  ScrollController _scrollController = ScrollController();

  List<PlaceModel> requestPlacesList = [];

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
    await requestPlaceService.fetchRequestPlaceList(list: requestPlacesList).then((value) {
      appStore.setLoading(false);
      isLast = value.length < perPageLimit;
      requestPlacesList.addAll(value);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      throw error;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget headingWidget() {
    return Text(language.placesRequest, style: boldTextStyle(size: 20, color: primaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          requestPlacesList.isNotEmpty
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
                              dataRowHeight: 100,
                              headingRowHeight: 45,
                              horizontalMargin: 16,
                              headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                              showCheckboxColumn: false,
                              dataTextStyle: primaryTextStyle(size: 14),
                              columnSpacing: 0,
                              headingTextStyle: boldTextStyle(),
                              columns: [
                                DataColumn(label: Text(language.index)),
                                DataColumn(label: ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text(language.name))),
                                DataColumn(label: Text(language.image)),
                                DataColumn(label: Text(language.category)),
                                DataColumn(label: Text(language.state)),
                                DataColumn(label: ConstrainedBox(constraints: BoxConstraints(maxWidth: 150),child: Text(language.user))),
                                DataColumn(label: Text(language.actions)),
                              ],
                              rows: requestPlacesList.map((PlaceModel mData) {
                                return DataRow(cells: [
                                  DataCell(Text('${requestPlacesList.indexOf(mData) + 1}')),
                                  DataCell(ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text('${mData.name.validate()}',maxLines: 3))),
                                  DataCell(Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.black12),
                                    padding: EdgeInsets.all(1),
                                    child: cachedImage(mData.image.validate(), fit: BoxFit.cover, height: 65, width: 65).onTap(() {
                                      mLaunchUrl(mData.image.validate());
                                    }),
                                  )),
                                  DataCell(
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: categoryService.documentById(mData.categoryId.validate()),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data!.data() != null) {
                                            CategoryModel item = CategoryModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                                            return ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: 120),
                                              child: Text('${item.name}', maxLines: 3),
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
                                  DataCell(
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: stateService.documentById(mData.stateId.validate()),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data!.data() != null) {
                                            StateModel item = StateModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                                            return ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: 120),
                                              child: Text('${item.name}', maxLines: 3),
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
                                                  Text('${item.name}',maxLines: 1),
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
                                  DataCell(dialogPrimaryButton(language.approve, () {
                                    appStore.setMenuIndex(UPLOAD_PLACE_INDEX);
                                    DashboardScreen(placeModel: mData,isRequestPlace: true).launch(context);
                                  })),
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
