import '../components/AddCategoryDialog.dart';
import '../models/CategoryModel.dart';
import '../screens/DashboardScreen.dart';
import '../services/FileStorageService.dart';
import '../utils/AppConstant.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/ModelKeys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../main.dart';
import '../utils/AppColor.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';

class CategoryWidget extends StatefulWidget {
  @override
  CategoryWidgetState createState() => CategoryWidgetState();
}

class CategoryWidgetState extends State<CategoryWidget> {
  List<CategoryModel> categoryList = [];
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
    await categoryService.fetchCategoryList(list: categoryList).then((value) {
      appStore.setLoading(false);
      isLast = value.length < perPageLimit;
      categoryList.addAll(value);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  changeStatus({required String id, required int status}) async {
    await categoryService.updateDocument({CommonKeys.status: status}, id).then((value) async {
      await placeService.placesFuture(catId: id).then((value) {
        value.forEach((element) async {
          await placeService.updateDocument({CommonKeys.status: status}, element.id);
        });
      });
    }).catchError((e) {
      toast(e.toString());
    });
  }

  deleteCategory(String id) async {
    await categoryService.removeDocument(id).then((value) async {
      CategoryModel item = categoryList.firstWhere((element) => element.id == id);
      await deleteFile(item.image.validate(),prefix: mCategoryStoragePath).then((value) async {
        categoryList.remove(item);
        setState(() {});
        await placeService.placesFuture(catId: id).then((value) {
          value.forEach((element) async {
            await placeService.removeDocument(element.id).then((value) async {
              await deleteFile(element.image.validate(),prefix: mPlacesStoragePath).then((value) {
                if ((element.secondaryImages ?? []).isNotEmpty) {
                  Future.forEach(element.secondaryImages!, (element) async {
                    await deleteFile(element.toString(),prefix: mPlacesStoragePath).then((value) {});
                  });
                }
              });
            });
          });
        });
      });
    });
  }

  Widget headingWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(language.category, style: boldTextStyle(size: 20, color: primaryColor)),
        addButton(language.addCategory, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AddCategoryDialog(onUpdate: () {
                categoryList.clear();
                init();
              });
            },
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          categoryList.isNotEmpty
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
                              columnSpacing: 0,
                              headingTextStyle: boldTextStyle(),
                              columns: [
                                DataColumn(label: Text(language.index)),
                                DataColumn(label: ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text("Name"))),
                                DataColumn(label: Text(language.image)),
                                DataColumn(label: Text(language.places)),
                                DataColumn(label: Text(language.status)),
                                DataColumn(label: Text(language.actions)),
                              ],
                              rows: categoryList.map((CategoryModel mData) {
                                return DataRow(cells: [
                                  DataCell(Text('${categoryList.indexOf(mData) + 1}')),
                                  DataCell(ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text('${mData.name.validate()}',maxLines: 3))),
                                  DataCell(Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.black12),
                                    padding: EdgeInsets.all(1),
                                    child: cachedImage(mData.image.validate(), fit: BoxFit.cover, height: 65, width: 65).onTap(() {
                                      mLaunchUrl(mData.image.validate());
                                    }),
                                  )),
                                  DataCell(
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(borderRadius: radius(defaultRadius / 2), color: primaryColor),
                                      child: FutureBuilder<int>(
                                          future: placeService.totalPlaces(catId: mData.id),
                                          builder: (context, snap) {
                                            if (snap.hasData) {
                                              return Text(snap.data.toString(), style: primaryTextStyle(color: Colors.white)).onTap(() {
                                                appStore.setMenuIndex(PLACE_INDEX);
                                                DashboardScreen(categoryId: mData.id).launch(context);
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
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext dialogContext) {
                                              return AddCategoryDialog(
                                                categoryModel: mData,
                                                onUpdate: () {
                                                  categoryList.clear();
                                                  init();
                                                },
                                              );
                                            },
                                          );
                                        }),
                                        SizedBox(width: 8),
                                        outlineActionIcon(Icons.delete, Colors.red, language.delete, () {
                                          deleteConfirmationDialog(
                                            context,
                                            () {
                                              finish(context);
                                              deleteCategory(mData.id!);
                                            },
                                            title: language.deleteCategory,
                                            subtitle: language.deleteCategoryMsg,
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
