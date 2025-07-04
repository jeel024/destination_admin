import '../models/AppSettingModel.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/text_styles.dart';

class AppSettingWidget extends StatefulWidget {
  @override
  AppSettingWidgetState createState() => AppSettingWidgetState();
}

class AppSettingWidgetState extends State<AppSettingWidget> {
  TextEditingController distanceCont = TextEditingController();

  TextEditingController rateUsController = TextEditingController();
  TextEditingController privacyPolicyController = TextEditingController();
  TextEditingController termAndConController = TextEditingController();
  TextEditingController helpAndSupportController = TextEditingController();
  TextEditingController contactUsController = TextEditingController();
  TextEditingController purchaseController = TextEditingController();

  TextEditingController admobBannerIdCont = TextEditingController();
  TextEditingController admobBannerIdIosCont = TextEditingController();
  TextEditingController admobInterstitialIdCont = TextEditingController();
  TextEditingController admobInterstitialIdIosCont = TextEditingController();
  TextEditingController admobRewardedIdCont = TextEditingController();
  TextEditingController admobRewardedIdIosCont = TextEditingController();

  TextEditingController fbBannerIdCont = TextEditingController();
  TextEditingController fbBannerIdIosCont = TextEditingController();
  TextEditingController fbInterstitialIdCont = TextEditingController();
  TextEditingController fbInterstitialIdIosCont = TextEditingController();
  TextEditingController fbRewardedIdCont = TextEditingController();
  TextEditingController fbRewardedIdIosCont = TextEditingController();

  FocusNode rateUsFocus = FocusNode();
  FocusNode privacyPolicyFocus = FocusNode();
  FocusNode termAndConFocus = FocusNode();
  FocusNode helpAndSupportFocus = FocusNode();
  FocusNode contactUsFocus = FocusNode();
  FocusNode purchaseFocus = FocusNode();

  FocusNode bannerIdFocus = FocusNode();
  FocusNode bannerIdIosFocus = FocusNode();
  FocusNode interstitialIdFocus = FocusNode();
  FocusNode interstitialIdIosFocus = FocusNode();
  FocusNode rewardedIdFocus = FocusNode();
  FocusNode rewardedIdIosFocus = FocusNode();

  bool isAdsEnable = defaultIsAdsEnable;
  bool isNotificationOn = defaultIsNotificationOn;
  String adsType = defaultAdsType;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await appSettingService.getAppSettings().then((value) {
      if (value.toJson().isNotEmpty) {
        rateUsController.text = value.rateUs.validate();
        privacyPolicyController.text = value.privacyPolicy.validate();
        termAndConController.text = value.termAndConditions.validate();
        helpAndSupportController.text = value.helpAndSupport.validate();
        contactUsController.text = value.contactUs.validate();
        purchaseController.text = value.purchase.validate();
        distanceCont.text = (value.nearByPlacesDistance ?? "").toString();
        isAdsEnable = value.isAdsEnable.validate(value: defaultIsAdsEnable);
        isNotificationOn = value.isNotificationOn.validate(value: defaultIsNotificationOn);
        adsType = value.adsType.validate(value: defaultAdsType);
        if (value.admob != null) {
          if (adsType.validate() == isGoogleAds) {
            admobBannerIdCont.text = value.admob!.bannerId.validate();
            admobBannerIdIosCont.text = value.admob!.bannerIdIos.validate();
            admobInterstitialIdCont.text = value.admob!.interstitialId.validate();
            admobInterstitialIdIosCont.text = value.admob!.interstitialIdIos.validate();
            admobRewardedIdCont.text = value.admob!.rewardedId.validate();
            admobRewardedIdIosCont.text = value.admob!.rewardedIdIos.validate();
          } else {
            fbBannerIdCont.text = value.admob!.bannerId.validate();
            fbBannerIdIosCont.text = value.admob!.bannerIdIos.validate();
            fbInterstitialIdCont.text = value.admob!.interstitialId.validate();
            fbInterstitialIdIosCont.text = value.admob!.interstitialIdIos.validate();
            fbRewardedIdCont.text = value.admob!.rewardedId.validate();
            fbRewardedIdIosCont.text = value.admob!.rewardedIdIos.validate();
          }
        }
        setState(() {});
      }
    }).catchError((e) {
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> submit() async {
    appStore.setLoading(true);
    AppSettingModel appSettingModel = AppSettingModel();
    appSettingModel.rateUs = rateUsController.text.validate();
    appSettingModel.contactUs = contactUsController.text.validate();
    appSettingModel.helpAndSupport = helpAndSupportController.text.validate();
    appSettingModel.privacyPolicy = privacyPolicyController.text.validate();
    appSettingModel.purchase = purchaseController.text.validate();
    appSettingModel.termAndConditions = termAndConController.text.validate();
    appSettingModel.isAdsEnable = isAdsEnable;
    appSettingModel.isNotificationOn = isNotificationOn;
    appSettingModel.adsType = adsType;
    if(distanceCont.text.isNotEmpty) appSettingModel.nearByPlacesDistance = double.parse(distanceCont.text);

    appSettingModel.admob = Admob();
    if (adsType == isGoogleAds) {
      appSettingModel.admob!.bannerId = admobBannerIdCont.text.validate();
      appSettingModel.admob!.bannerIdIos = admobBannerIdIosCont.text.validate();
      appSettingModel.admob!.interstitialId = admobInterstitialIdCont.text.validate();
      appSettingModel.admob!.interstitialIdIos = admobInterstitialIdIosCont.text.validate();
      appSettingModel.admob!.rewardedId = admobRewardedIdCont.text.validate();
      appSettingModel.admob!.rewardedIdIos = admobRewardedIdIosCont.text.validate();
    } else {
      appSettingModel.admob!.bannerId = fbBannerIdCont.text.validate();
      appSettingModel.admob!.bannerIdIos = fbBannerIdIosCont.text.validate();
      appSettingModel.admob!.interstitialId = fbInterstitialIdCont.text.validate();
      appSettingModel.admob!.interstitialIdIos = fbInterstitialIdIosCont.text.validate();
      appSettingModel.admob!.rewardedId = fbRewardedIdCont.text.validate();
      appSettingModel.admob!.rewardedIdIos = fbRewardedIdIosCont.text.validate();
    }
    setValue(IS_NOTIFICATION_ON, isNotificationOn);
    await appSettingService.setAppSettings(appSettingModel);
  }

  Widget headingWidget() {
    return Text(language.appSettings, style: boldTextStyle(size: 20, color: primaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: ScrollController(),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headingWidget(),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(defaultRadius),
              boxShadow: commonBoxShadow(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.notificationSetting, style: boldTextStyle(size: 18)),
                        SizedBox(height: 16),
                        SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: isNotificationOn,
                            onChanged: (val) {
                              isNotificationOn = val!;
                              setState(() {});
                            },
                            title: Text(language.enableNotification, style: primaryTextStyle()),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ).expand(),
                    16.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.nearByPlaces, style: boldTextStyle(size: 18)),
                        SizedBox(height: 16),
                        Text(language.distanceKm, style: primaryTextStyle()),
                        SizedBox(height: 8),
                        AppTextField(
                          controller: distanceCont,
                          textFieldType: TextFieldType.OTHER,
                          decoration: commonInputDecoration(),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9 .]')),
                          ],
                        ),
                      ],
                    ).expand(),
                  ],
                ),
                24.height,
                Text(language.socialLinks, style: boldTextStyle(size: 18)),
                SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.privacyPolicy, style: primaryTextStyle()),
                        SizedBox(height: 8),
                        AppTextField(
                          controller: privacyPolicyController,
                          textFieldType: TextFieldType.URL,
                          focus: privacyPolicyFocus,
                          nextFocus: termAndConFocus,
                          decoration: commonInputDecoration(hintText: language.privacyPolicy),
                        ),
                      ],
                    ).expand(),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.termsAndConditions, style: primaryTextStyle()),
                        SizedBox(height: 8),
                        AppTextField(
                          controller: termAndConController,
                          textFieldType: TextFieldType.URL,
                          focus: termAndConFocus,
                          nextFocus: helpAndSupportFocus,
                          decoration: commonInputDecoration(hintText: language.termsAndConditions),
                        ),
                      ],
                    ).expand(),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.contactUs, style: primaryTextStyle()),
                        SizedBox(height: 8),
                        AppTextField(
                          controller: contactUsController,
                          textFieldType: TextFieldType.URL,
                          focus: contactUsFocus,
                          nextFocus: purchaseFocus,
                          decoration: commonInputDecoration(hintText: language.contactUs),
                        ),
                      ],
                    ).expand(),

                  ],
                ),
                30.height,
                Center(
                  child: dialogPrimaryButton(language.save, () {
                    if (getBoolAsync(IS_DEMO_ADMIN)) {
                      return toast(language.demoAdminMsg);
                    } else {
                      submit();
                    }
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
