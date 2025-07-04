import '../main.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../models/UserModel.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/text_styles.dart';

class UsersWidget extends StatefulWidget {
  @override
  UsersWidgetState createState() => UsersWidgetState();
}

class UsersWidgetState extends State<UsersWidget> {
  List<UserModel> usersList = [];
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
    await userService.fetchUsersList(list: usersList).then((value) {
      appStore.setLoading(false);
      isLast = value.length < perPageLimit;
      usersList.addAll(value);
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
    return Text(language.users, style: boldTextStyle(size: 20, color: primaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          usersList.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: ScrollController(),
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
                                    DataColumn(label: Text(language.email)),
                                    DataColumn(label: Text(language.phone)),
                                    DataColumn(label: Text(language.createdAt)),
                                  ],
                                  rows: usersList.map((item) {
                                    return DataRow(cells: [
                                      DataCell(Text('${usersList.indexOf(item) + 1}')),
                                      DataCell(ConstrainedBox(constraints: BoxConstraints(maxWidth: context.width() * 0.25), child: Text('${item.name}'))),
                                      DataCell(Container(
                                        decoration:BoxDecoration(borderRadius: BorderRadius.circular(40),color: Colors.black12),
                                        padding:EdgeInsets.all(1),
                                        child: cachedImage(item.profileImg, fit: BoxFit.cover, height: 65, width: 65).cornerRadiusWithClipRRect(40).onTap(() {
                                          mLaunchUrl(item.profileImg.validate());
                                        }),
                                      )),
                                      DataCell(Text('${item.email.validate(value: "-")}')),
                                      DataCell(Text('${item.contactNo.validate(value: "-")}')),
                                      DataCell(Text(item.createdAt != null ? printDate(item.createdAt!) : '-')),
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
