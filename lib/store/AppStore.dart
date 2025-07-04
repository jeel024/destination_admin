import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import '../language/AppLocalizations.dart';
import '../language/BaseLanguage.dart';
import '../main.dart';
import '../models/LanguageDataModel.dart';
import '../utils/AppConstant.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/shared_pref.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {

  @observable
  bool isLoggedIn = false;

  @observable
  bool isLoading = false;

  @observable
  int selectedMenuIndex = 0;

  @observable
  bool isMenuExpanded = true;

  @observable
  String userProfile = '';

  @observable
  bool isDarkMode = false;

  @observable
  String selectedLanguage = "";

  @action
  Future<void> setLoggedIn(bool val) async {
    isLoggedIn = val;
    await setValue(IS_LOGGED_IN, val);
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  void setMenuIndex(int val) {
    selectedMenuIndex = val;
  }

  @action
  void setExpandedMenu(bool val) {
    isMenuExpanded = val;
  }

  @action
  void setUserProfile(String val){
    userProfile = val;
  }

  @action
  void setDarkMode(bool val) {
    isDarkMode = val;
    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;

      shadowColorGlobal = Colors.white12;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;
    }
  }

  @action
  Future<void> setLanguage(String aCode, {BuildContext? context}) async {
    selectedLanguageDataModel = getSelectedLanguageModel(defaultLang: defaultLanguage);
    selectedLanguage = getSelectedLanguageModel(defaultLang: defaultLanguage)!.languageCode!;

    if (context != null) language = BaseLanguage.of(context)!;
    language = await AppLocalizations().load(Locale(selectedLanguage));
  }

}