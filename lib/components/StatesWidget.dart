import '../components/AddStateDialog.dart';
import '../main.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/ModelKeys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../models/StateModel.dart';
import '../screens/DashboardScreen.dart';
import '../services/FileStorageService.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';

class StatesWidget extends StatefulWidget {
  @override
  StatesWidgetState createState() => StatesWidgetState();
}

class StatesWidgetState extends State<StatesWidget> {
  List<StateModel> stateList = [];
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
    await stateService.fetchStateList(list: stateList).then((value) {
      appStore.setLoading(false);
      isLast = value.length < perPageLimit;
      stateList.addAll(value);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(language.state, style: boldTextStyle(size: 20, color: primaryColor)),
        addButton(language.addState, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AddStateDialog(
                onUpdate: () {
                  stateList.clear();
                  init();
                },
              );
            },
          );
        }),
      ],
    );
  }

  changeStatus({required String id, required int status}) async {
    await stateService.updateDocument({CommonKeys.status: status}, id).then((value) async {
      await placeService.placesFuture(stateId: id).then((value) {
        value.forEach((element) async {
          await placeService.updateDocument({CommonKeys.status: status}, element.id);
        });
      });
    }).catchError((e) {
      toast(e.toString());
    });
  }

  deleteState(String id) async {
    await stateService.removeDocument(id).then((value) async {
      StateModel item = stateList.firstWhere((element) => element.id == id);
      await deleteFile(item.image.validate(),prefix: mStateStoragePath).then((value) async {
        stateList.remove(item);
        setState(() {});
        await placeService.placesFuture(stateId: id).then((value) {
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

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          stateList.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headingWidget(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                                  columnSpacing: 0,
                                  dataTextStyle: primaryTextStyle(size: 14),
                                  headingTextStyle: boldTextStyle(),
                                  columns: [
                                    DataColumn(label: Text(language.index)),
                                    DataColumn(label: ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text(language.name,maxLines: 3))),
                                    DataColumn(label: Text(language.image)),
                                    DataColumn(label: Text("City")),
                                    DataColumn(label: Text(language.status)),
                                    DataColumn(label: Text(language.actions)),
                                  ],
                                  rows: stateList.map((StateModel mData) {
                                    return DataRow(cells: [
                                      DataCell(Text('${stateList.indexOf(mData) + 1}')),
                                      DataCell(ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text('${mData.name.validate()}'))),
                                      DataCell(Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.black12),
                                        padding: EdgeInsets.all(1),
                                        child: cachedImage(mData.image.validate(), width: 65, height: 65, fit: BoxFit.cover).onTap(() {
                                          mLaunchUrl(mData.image.validate());
                                        }),
                                      )),
                                      DataCell(
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(borderRadius: radius(defaultRadius / 2), color: primaryColor),
                                          child: FutureBuilder<int>(
                                              future: cityService.totalCity(id: mData.id!),
                                              builder: (context, snap) {
                                                if (snap.hasData) {
                                                  return Text(snap.data.toString(), style: primaryTextStyle(color: Colors.white)).onTap(() {
                                                    appStore.setMenuIndex(CITY_INDEX);
                                                    print(mData.id);
                                                    DashboardScreen(stateId: mData.id).launch(context);
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
                                                  return AddStateDialog(
                                                      stateData: mData,
                                                      onUpdate: () {
                                                        stateList.clear();
                                                        init();
                                                      });
                                                },
                                              );
                                            }),
                                            SizedBox(width: 8),
                                            outlineActionIcon(Icons.delete, Colors.red, language.delete, () {
                                              deleteConfirmationDialog(
                                                context,
                                                () {
                                                  finish(context);
                                                  deleteState(mData.id!);
                                                },
                                                title: language.deleteStateQue,
                                                subtitle: language.selectStateMsg,
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
                          SizedBox(height: 16),
                        ],
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
                    ).paddingAll(16).visible(!appStore.isLoading && stateList.isEmpty)
                  : SizedBox(),
          loaderWidget().visible(appStore.isLoading),
        ],
      );
    });
  }
}
