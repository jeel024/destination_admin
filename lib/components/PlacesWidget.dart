import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/CategoryModel.dart';
import '../models/CityModel.dart';
import '../models/StateModel.dart';
import '../services/FileStorageService.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../main.dart';
import '../models/PlaceModel.dart';
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

class PlacesWidget extends StatefulWidget {
  final String? catId;
  final String? stateId;
  final String placeType;

  PlacesWidget({this.catId, this.stateId, this.placeType = ""});

  @override
  PlacesWidgetState createState() => PlacesWidgetState();
}

class PlacesWidgetState extends State<PlacesWidget> {
  ScrollController _scrollController = ScrollController();

  List<CategoryModel> categoryList = [];
  List<StateModel> stateList = [];
  List<CityModel> cityList = [];
  List<PlaceModel> placeList = [];

  String? categoryId;
  String? stateId;
  String? cityId;

  bool isLast = true;

  @override
  void initState() {
    super.initState();
    print("STATE ID123 ::: ${widget.stateId}");

    print(widget.stateId);
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

  void init() async {
    appStore.setLoading(true);
    categoryId = widget.catId;
    stateId = widget.stateId;
    categoryList = await categoryService.getCategories();
    stateList = await stateService.getStates();
    categoryList.add(CategoryModel(name: language.allCategory,id: null));
    stateList.add(StateModel(name: language.allStates,id: null));
    appStore.setLoading(false);
    places();
    print("STATE ID45 ::: ${stateId}");

  }

  Future<void> places() async{
    appStore.setLoading(true);
    print(cityId);
    await placeService.fetchPlaceList(list: placeList, catId: categoryId, stateId: stateId,cityId: cityId, placeType: widget.placeType).then((value) {
      appStore.setLoading(false);
      isLast = value.length < perPageLimit;
      placeList.addAll(value);
      setState(() {});
    })/*.catchError((error) {
      appStore.setLoading(false);
      throw error;
    })*/;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  changeStatus({required String id, required int status}) async {
    await placeService.updateDocument({CommonKeys.status: status}, id).then((value) {
      //
    }).catchError((e) {
      toast(e.toString());
    });
  }

  deletePlace(String id) async {
    appStore.setLoading(true);
    await placeService.removeDocument(id).then((value) async {
      PlaceModel item = placeList.firstWhere((element) => element.id == id);
      await deleteFile(item.image.validate(), prefix: mPlacesStoragePath).then((value) {
        if ((item.secondaryImages ?? []).isNotEmpty) {
          Future.forEach(item.secondaryImages!, (element) async {
            await deleteFile(element.toString(), prefix: mPlacesStoragePath).then((value) {});
          }).then((value) {
            appStore.setLoading(false);
            placeList.remove(item);
            setState(() {});
          });
        } else {
          appStore.setLoading(false);
          placeList.remove(item);
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
            value: categoryId,
            decoration: commonInputDecoration(),
            items: categoryList.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem(
                value: item.id,
                child: Text(item.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            onChanged: (value) {
              if(value!=null) {
                categoryId = value;
              }else{
                categoryId = null;
              }
              placeList.clear();
              places();
            },
          ),
        ).visible(categoryList.isNotEmpty),
        16.width,
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<String>(
            dropdownColor: Theme.of(context).cardColor,
            isExpanded: true,
            value: stateId,
            decoration: commonInputDecoration(),
            items: stateList.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem(
                value: item.id,
                child: Text(item.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            onChanged: (value) async {
              if(value!=null) {
                stateId = value;
                cityList.clear();
                cityList = await cityService.fetchCityList(list: cityList,stateId: stateId);
              }else{
                stateId = null;
              }
              placeList.clear();
              places();
            },
          ),
        ).visible(stateList.isNotEmpty),
        16.width,
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<String>(
            dropdownColor: Theme.of(context).cardColor,
            isExpanded: true,
            value: cityId,
            decoration: commonInputDecoration(),
            items: cityList.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem(
                value: item.id,
                child: Text(item.name.validate(), style: primaryTextStyle()),
              );
            }).toList(),
            onChanged: (value) {
              if(value!=null) {
                cityId = value;
              }else{
                cityId = null;
              }
              placeList.clear();
              places();
            },
          ),
        ).visible(cityList.isNotEmpty),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          placeList.isNotEmpty
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
                                DataColumn(label: Text(language.category)),
                                DataColumn(label: Text(language.state)),
                                DataColumn(label: Text(language.rating)),
                                DataColumn(label: Text(language.favourites)),
                                DataColumn(label: Text(language.reviews)),
                                DataColumn(label: Text(language.status)),
                                DataColumn(label: Text(language.actions)),
                              ],
                              rows: placeList.map((PlaceModel mData) {
                                return DataRow(cells: [
                                  DataCell(Text('${placeList.indexOf(mData) + 1}')),
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
                                          appStore.setMenuIndex(UPLOAD_PLACE_INDEX);
                                          DashboardScreen(placeModel: mData).launch(context);
                                        }),
                                        SizedBox(width: 8),
                                        outlineActionIcon(Icons.delete, Colors.red, language.delete, () {
                                          deleteConfirmationDialog(
                                            context,
                                            () {
                                              finish(context);
                                              deletePlace(mData.id!);
                                            },
                                            title: language.deletePlaceQue,
                                            subtitle: language.deletePlaceMsg,
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
