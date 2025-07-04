import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_admin/models/PlaceModel.dart';
import '../models/hotel_model.dart';
import '../services/FileStorageService.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../main.dart';
import '../screens/DashboardScreen.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/ModelKeys.dart';

class HotelsWidget extends StatefulWidget {
  final String? placeId;
  final String? starId;
  final String placeType;

  HotelsWidget({this.placeId, this.starId, this.placeType = ""});

  @override
  HotelsWidgetState createState() => HotelsWidgetState();
}

class HotelsWidgetState extends State<HotelsWidget> {
  ScrollController _scrollController = ScrollController();

  List<PlaceModel> placeList = [];
  List starList = ["All Star","3 Star","5 Star","7 Star"];
  List<HotelModel> hotelList = [];

  String? placeId;
  String? starId;

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
          places();
        }
      }
    });
  }

  Future<void> init()  async {
    appStore.setLoading(true);
    placeId = widget.placeId;
    starId = "All Star";
    placeList = await placeService.getPlaces();

    placeList.add(PlaceModel(name: "All Places",id: null));
    appStore.setLoading(false);
    places();
  }

  Future<void> places() async{
    appStore.setLoading(true);
    await hotelService.fetchPlaceList(list: hotelList, placeId: placeId, starId: starId, placeType: widget.placeType).then((value) {
      appStore.setLoading(false);
      isLast = value.length < perPageLimit;
      hotelList.addAll(value);
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

  changeStatus({required String id, required int status}) async {
    await hotelService.updateDocument({CommonKeys.status: status}, id).then((value) {
      //
    }).catchError((e) {
      toast(e.toString());
    });
  }

  deletePlace(String id) async {
    appStore.setLoading(true);
    await hotelService.removeDocument(id).then((value) async {
      HotelModel item = hotelList.firstWhere((element) => element.id == id);
      await deleteFile(item.image.validate(), prefix: mPlacesStoragePath).then((value) {
        if ((item.secondaryImages ?? []).isNotEmpty) {
          Future.forEach(item.secondaryImages!, (element) async {
            await deleteFile(element.toString(), prefix: mPlacesStoragePath).then((value) {});
          }).then((value) {
            appStore.setLoading(false);
            hotelList.remove(item);
            setState(() {});
          });
        } else {
          appStore.setLoading(false);
          hotelList.remove(item);
          setState(() {});
        }
      });
    });
  }

  Widget headingWidget() {
    return Row(
      children: [
        Text(language.places, style: boldTextStyle(size: 20, color: primaryColor)),
        Spacer(),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<String>(
            dropdownColor: Theme.of(context).cardColor,
            isExpanded: true,
            value: placeId,
            decoration: commonInputDecoration(),
            items: placeList.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem(
                value: item.id,
                child: Text(item.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            onChanged: (value) {
              if(value!=null) {
                placeId = value;
              }else{
                placeId = null;
              }
              hotelList.clear();
              places();
            },
          ),
        ).visible(placeList.isNotEmpty),
        16.width,
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<String>(
            dropdownColor: Theme.of(context).cardColor,
            isExpanded: true,
            value: starId,
            decoration: commonInputDecoration(),
            items: starList.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: primaryTextStyle()),
              );
            }).toList(),
            onChanged: (value) {
              if(value!=null) {
                starId = value;
              }else{
                starId = null;
              }
              hotelList.clear();
              places();
            },
          ),
        ).visible(starList.isNotEmpty),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          hotelList.isNotEmpty
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
                        dataRowHeight: 85,
                        headingRowHeight: 45,
                        horizontalMargin: 16,
                        headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                        showCheckboxColumn: false,
                        dataTextStyle: primaryTextStyle(size: 14),
                        columnSpacing: 16,
                        headingTextStyle: boldTextStyle(),
                        columns: [
                          DataColumn(label: Text(language.index)),
                          DataColumn(label: ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text(language.name))),
                          DataColumn(label: Text(language.image)),
                          DataColumn(label: Text("Place")),
                          DataColumn(label: Text("Star")),
                          DataColumn(label: Text(language.rating)),
                          DataColumn(label: Text(language.favourites)),
                          DataColumn(label: Text(language.reviews)),
                          DataColumn(label: Text(language.status)),
                          DataColumn(label: Text(language.actions)),
                        ],
                        rows: hotelList.map((HotelModel mData) {
                          return DataRow(cells: [
                            DataCell(Text('${hotelList.indexOf(mData) + 1}')),
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
                                stream: placeService.documentById(mData.placeId.validate()),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.data() != null) {
                                      PlaceModel item = PlaceModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
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
                              Text(mData.starId.toString()),
                              // StreamBuilder<DocumentSnapshot>(
                              //   stream: stateService.documentById(mData.starId.validate()),
                              //   builder: (context, snapshot) {
                              //     print(snapshot.data!.data().toString());
                              //     if (snapshot.hasData) {
                              //
                              //       if (snapshot.data!.data() != null) {
                              //         StateModel item = StateModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                              //         return ConstrainedBox(
                              //           constraints: BoxConstraints(maxWidth: 120),
                              //           child: Text('${item.name}', maxLines: 3),
                              //         );
                              //       } else {
                              //         return SizedBox();
                              //       }
                              //     } else {
                              //       return SizedBox();
                              //     }
                              //   },
                              // ),
                            ),
                            DataCell(ratingWidget(mData.rating)),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${mData.favourites.validate()}'),
                                6.width,
                                Icon(Icons.favorite, size: 20, color: Colors.red),
                              ],
                            )),
                            DataCell(
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(borderRadius: radius(defaultRadius / 2), color: primaryColor),
                                child: FutureBuilder<int>(
                                    future: reviewService.totalReviews(placeId: mData.id),
                                    builder: (context, snap) {
                                      if (snap.hasData) {
                                        return Text(snap.data.toString(), style: primaryTextStyle(color: Colors.white)).onTap(() {
                                          appStore.setMenuIndex(PLACE_REVIEW_INDEX);
                                          DashboardScreen(placeId: mData.id).launch(context);
                                        });
                                      } else {
                                        return Text('0', style: primaryTextStyle(color: Colors.white));
                                      }
                                    }),
                              ),
                            ),
                            DataCell(Transform.scale(
                              scale: 0.7,
                              child: CupertinoSwitch(
                                value: mData.status == 1,
                                onChanged: (value) {
                                  if (getBoolAsync(IS_DEMO_ADMIN)) {
                                    return toast(language.demoAdminMsg);
                                  } else {
                                    mData.status = value ? 1 : 0;
                                    changeStatus(id: mData.id!, status: value ? 1 : 0);
                                    setState(() {});
                                  }
                                },
                              ),
                            )),
                            DataCell(
                              Row(
                                children: [
                                  outlineActionIcon(Icons.edit, Colors.green, language.edit, () {
                                    appStore.setMenuIndex(UPLOAD_HOTEL_INDEX);
                                    DashboardScreen(hotelModel: mData).launch(context);
                                  }),
                                  SizedBox(width: 8),
                                  outlineActionIcon(Icons.delete, Colors.red, language.delete, () {
                                    deleteConfirmationDialog(
                                      context,
                                          () {
                                        finish(context);
                                        deletePlace(mData.id!);
                                      },
                                      title: "Delete Hotel ?",
                                      subtitle: "Are you sure you want to delete this hotel ?",
                                    );
                                  }),
                                ],
                              ),
                            ),
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
