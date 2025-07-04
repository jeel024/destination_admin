import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get appName;

  String get addCategory;

  String get name;

  String get status;

  String get errorThisFieldIsRequired;

  String get image;

  String get browse;

  String get cancel;

  String get submit;

  String get pleaseSelectImage;

  String get categoryUpdated;

  String get categoryAdded;

  String get stateUpdated;

  String get stateAdded;

  String get addState;

  String get category;

  String get index;

  String get places;

  String get actions;

  String get edit;

  String get delete;

  String get deleteCategory;

  String get deleteCategoryMsg;

  String get oldPasswordIsWrong;

  String get passwordChanged;

  String get changePassword;

  String get oldPassword;

  String get newPassword;

  String get confirmPassword;

  String get passwordNotMatch;

  String get editProfile;

  String get email;

  String get youCannotChangeEmailId;

  String get contactNumber;

  String get forgotPassword;

  String get forgotPasswordMsg;

  String get totalUsers;

  String get totalCategories;

  String get totalStates;

  String get totalPlaces;

  String get totalReviews;

  String get latestPlaces;

  String get viewAll;

  String get address;

  String get state;

  String get latestReview;

  String get user;

  String get comment;

  String get mostFavouritePlaces;

  String get mostRatedPlaces;

  String get placeReviews;

  String get rating;

  String get place;

  String get createdAt;

  String get favourites;

  String get reviews;

  String get deletePlaceQue;

  String get deletePlaceMsg;

  String get deleteStateQue;

  String get selectStateMsg;

  String get placeUpdated;

  String get placeAdded;

  String get uploadPlaces;

  String get placeName;

  String get loading;

  String get placeAddress;

  String get primaryImage;

  String get clear;

  String get description;

  String get secondaryImages;

  String get save;

  String get pleaseSelectPrimaryImage;

  String get users;

  String get phone;

  String get theme;

  String get logout;

  String get areYouSure;

  String get logoutConfirmation;

  String get no;

  String get yes;

  String get notAllowed;

  String get signIn;

  String get signInToYourAccount;

  String get password;

  String get forgotPasswordQue;

  String get youAreNotRegisteredWithUs;

  String get appSettings;

  String get rateUs;

  String get privacyPolicy;

  String get termsAndConditions;

  String get helpAndSupport;

  String get contactUs;

  String get purchase;

  String get notificationSetting;

  String get enableNotification;

  String get adsConfiguration;

  String get enableAds;

  String get adsType;

  String get admob;

  String get facebook;

  String get bannerId;

  String get bannerIdIos;

  String get interstitialId;

  String get interstitialIdIos;

  String get socialLinks;

  String get profile;

  String get appConfigUpdated;

  String get appConfigSaved;

  String get demoAdminMsg;

  String get resetEmailSentTo;

  String get noUserFound;

  String get somethingWentWrong;

  String get noDataFound;

  String get nearByPlaces;

  String get distanceKm;

  String get placesRequest;

  String get approve;

  String get addressNote;

  String get getAddress;

  String get pleaseWriteSomeText;

  String get update;

  String get pleaseEnterValidAddress;

  String get dashboard;

  String get active;

  String get inactive;

  String get allCategory;

  String get allStates;
}
