import 'package:destination_admin/models/hotel_model.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import '../main.dart';
import '../services/AuthServices.dart';
import '../utils/AppConstant.dart';
import '../utils/AppImages.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/on_hover.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../components/ChangePasswordDialog.dart';
import '../components/EditProfileDialog.dart';
import '../models/PlaceModel.dart';
import '../models/models.dart';
import '../utils/AppColor.dart';
import '../utils/Common.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/text_styles.dart';

//ignore: must_be_immutable
class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';
  String? categoryId;
  String? stateId;
  String? cityId;
  String? starId;
  String? placeId;
  PlaceModel? placeModel;
  HotelModel? hotelModel;
  String placeType;
  bool isRequestPlace;

  DashboardScreen({this.categoryId, this.stateId, this.cityId, this.starId,this.placeId, this.placeModel, this.hotelModel, this.placeType = "",this.isRequestPlace = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<MenuItemModel> menuList = [];
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    menuList = getMenuItems(
      catId: widget.categoryId,
      stateId: widget.stateId,
      cityId: widget.cityId,
      starId: widget.starId,
      placeId: widget.placeId,
      place: widget.placeModel,
      hotel: widget.hotelModel,
      plaType: widget.placeType,
      isRequestPlace : widget.isRequestPlace,
    );
    firebaseOnMessage();
    setState(() {});
  }

  void firebaseOnMessage() {
    FirebaseMessaging.onMessage.listen((event) async {
      ElegantNotification.info(
        title: Text(event.notification!.title.validate(), style: boldTextStyle(color: primaryColor, size: 18)),
        description: Text(event.notification!.body.validate(), style: primaryTextStyle(color: Colors.black, size: 16)),
        notificationPosition: NotificationPosition.topCenter,
        autoDismiss: true,
        animation: AnimationType.fromTop,
        showProgressIndicator: false,
        width: 400,
        height: 100,
        toastDuration: Duration(seconds: 15),
        iconSize: 30,
      ).show(context);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          elevation: 8,
          shadowColor: Colors.black26,
          title: Row(
            children: [
              Image.asset(ic_appLogo_transparent,height: 30).onTap(() {
                appStore.setExpandedMenu(!appStore.isMenuExpanded);
              }),
              SizedBox(width: 16),
              Text(language.appName, style: boldTextStyle(color: primaryColor, size: 20)),
            ],
          ),
          actions: [
            Tooltip(
              message: language.theme,
              child: FlutterSwitch(
                value: appStore.isDarkMode,
                width: 55,
                height: 30,
                toggleSize: 25,
                borderRadius: 30.0,
                padding: 4.0,
                activeIcon: ImageIcon(AssetImage('assets/icons/ic_moon.png'), color: Colors.white, size: 30),
                inactiveIcon: ImageIcon(AssetImage('assets/icons/ic_sun.png'), color: Colors.white, size: 30),
                activeColor: primaryColor,
                activeToggleColor: Colors.black,
                inactiveToggleColor: Colors.orangeAccent,
                inactiveColor: scaffoldColor,
                onToggle: (value) {
                  appStore.setDarkMode(value);
                  setValue(THEME_MODE_INDEX, value ? ThemeModeDark : ThemeModeLight);
                  setState(() {});
                },
              ),
            ),
            SizedBox(width: 16),
            // Container(
            //   margin: EdgeInsets.only(top: 14, bottom: 14),
            //   padding: EdgeInsets.only(left: 12,right: 12),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).cardColor,
            //     borderRadius: BorderRadius.circular(defaultRadius),
            //     border: Border.all(color:Colors.grey.withOpacity(0.15))
            //   ),
            //   child: LanguageListWidget(
            //     widgetType: WidgetType.DROPDOWN,
            //     onLanguageChange: (val) async {
            //       appStore.setLanguage(val.languageCode ?? '-');
            //       await setValue(SELECTED_LANGUAGE_CODE, val.languageCode ?? defaultLanguage);
            //       init();
            //       setState(() {});
            //     },
            //   ),
            // ),
            // SizedBox(width: 16),
            PopupMenuButton(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.only(right: 16, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.15)),
                        shape: BoxShape.circle,
                        image: DecorationImage(image: NetworkImage(appStore.userProfile.isNotEmpty ? '${appStore.userProfile}' : 'assets/profile.png'), fit: BoxFit.cover),
                      ),
                    ),
                    8.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${getStringAsync(USER_NAME)}', style: boldTextStyle()),
                        SizedBox(height: 8),
                        Text(getStringAsync(USER_EMAIL), style: secondaryTextStyle(size: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.person, color:Colors.grey),
                      SizedBox(width: 8),
                      Text(language.editProfile),
                    ],
                  ),
                  textStyle: primaryTextStyle(),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.lock, color:  Colors.grey),
                      SizedBox(width: 8),
                      Text(language.changePassword),
                    ],
                  ),
                  textStyle: primaryTextStyle(),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.logout, color:  Colors.grey),
                      SizedBox(width: 8),
                      Text(language.logout),
                    ],
                  ),
                  textStyle: primaryTextStyle(),
                ),
              ],
              onSelected: (value) {
                if (value == 1) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return EditProfileDialog();
                    },
                  );
                } else if (value == 2) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return ChangePasswordDialog();
                    },
                  );
                } else if (value == 3) {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        actionsPadding: EdgeInsets.all(16),
                        content: SizedBox(
                          width: 200,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                                padding: EdgeInsets.all(16),
                                child: Icon(Icons.clear, color: primaryColor),
                              ),
                              SizedBox(height: 30),
                              Text(language.areYouSure, style: primaryTextStyle(size: 24)),
                              SizedBox(height: 16),
                              Text(language.logoutConfirmation, style: boldTextStyle(), textAlign: TextAlign.center),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          dialogSecondaryButton(language.no, () {
                            Navigator.pop(context);
                          }),
                          dialogPrimaryButton(language.yes, () async {
                            finish(context);
                            appStore.setLoading(true);
                            await logout(context);
                            appStore.setLoading(false);
                          }),
                        ],
                      );
                    },
                  );
                }
              },
              tooltip: language.profile,
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: IntrinsicHeight(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: getMenuWidth(),
                  child: Container(
                    padding: EdgeInsets.only(top: 16, right: 16, bottom: 16),
                    width: getMenuWidth(),
                    decoration: boxDecorationRoundedWithShadowWidget(0, backgroundColor: context.cardColor, shadowColor: Colors.grey.withOpacity(0.15)),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        ListView(
                          children: menuList.map((item) {
                            int index = menuList.indexOf(item);
                            return HoverWidget(builder: (context, isHovering) {
                              return GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  alignment: appStore.isMenuExpanded ? Alignment.centerLeft : Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: appStore.isMenuExpanded ? 16 : 0, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(topRight: radiusCircular(defaultRadius), bottomRight: radiusCircular(defaultRadius)),
                                    color: appStore.selectedMenuIndex == index
                                        ? primaryColor
                                        : isHovering
                                            ? primaryColor.withOpacity(0.3)
                                            : Colors.transparent,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Icon(item.icon, size: 24, color: appStore.selectedMenuIndex == index ? Colors.white : null),
                                        appStore.isMenuExpanded
                                            ? Padding(
                                                padding: EdgeInsets.only(left: 16),
                                                child: Text(item.title!,
                                                    style: boldTextStyle(
                                                      color: appStore.selectedMenuIndex == index ? Colors.white : null,
                                                    )),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  appStore.selectedMenuIndex = index;

                                  /// Clear Filters
                                  widget.categoryId = null;
                                  widget.stateId = null;
                                  widget.placeModel = null;
                                  widget.placeId = null;
                                  widget.placeType = '';
                                  widget.isRequestPlace = false;
                                  init();
                                  setState(() {});
                                },
                              );
                            });
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    alignment: AlignmentDirectional.topStart,
                    width: getBodyWidth(context),
                    child: Stack(
                      children: [
                        Container(
                          width: getBodyWidth(context),
                          child: menuList[appStore.selectedMenuIndex].widget,
                        ),
                        Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
