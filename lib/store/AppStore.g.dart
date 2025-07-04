// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppStore on _AppStore, Store {
  late final _$isLoggedInAtom =
      Atom(name: '_AppStore.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AppStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$selectedMenuIndexAtom =
      Atom(name: '_AppStore.selectedMenuIndex', context: context);

  @override
  int get selectedMenuIndex {
    _$selectedMenuIndexAtom.reportRead();
    return super.selectedMenuIndex;
  }

  @override
  set selectedMenuIndex(int value) {
    _$selectedMenuIndexAtom.reportWrite(value, super.selectedMenuIndex, () {
      super.selectedMenuIndex = value;
    });
  }

  late final _$isMenuExpandedAtom =
      Atom(name: '_AppStore.isMenuExpanded', context: context);

  @override
  bool get isMenuExpanded {
    _$isMenuExpandedAtom.reportRead();
    return super.isMenuExpanded;
  }

  @override
  set isMenuExpanded(bool value) {
    _$isMenuExpandedAtom.reportWrite(value, super.isMenuExpanded, () {
      super.isMenuExpanded = value;
    });
  }

  late final _$userProfileAtom =
      Atom(name: '_AppStore.userProfile', context: context);

  @override
  String get userProfile {
    _$userProfileAtom.reportRead();
    return super.userProfile;
  }

  @override
  set userProfile(String value) {
    _$userProfileAtom.reportWrite(value, super.userProfile, () {
      super.userProfile = value;
    });
  }

  late final _$isDarkModeAtom =
      Atom(name: '_AppStore.isDarkMode', context: context);

  @override
  bool get isDarkMode {
    _$isDarkModeAtom.reportRead();
    return super.isDarkMode;
  }

  @override
  set isDarkMode(bool value) {
    _$isDarkModeAtom.reportWrite(value, super.isDarkMode, () {
      super.isDarkMode = value;
    });
  }

  late final _$selectedLanguageAtom =
      Atom(name: '_AppStore.selectedLanguage', context: context);

  @override
  String get selectedLanguage {
    _$selectedLanguageAtom.reportRead();
    return super.selectedLanguage;
  }

  @override
  set selectedLanguage(String value) {
    _$selectedLanguageAtom.reportWrite(value, super.selectedLanguage, () {
      super.selectedLanguage = value;
    });
  }

  late final _$setLoggedInAsyncAction =
      AsyncAction('_AppStore.setLoggedIn', context: context);

  @override
  Future<void> setLoggedIn(bool val) {
    return _$setLoggedInAsyncAction.run(() => super.setLoggedIn(val));
  }

  late final _$setLanguageAsyncAction =
      AsyncAction('_AppStore.setLanguage', context: context);

  @override
  Future<void> setLanguage(String aCode, {BuildContext? context}) {
    return _$setLanguageAsyncAction
        .run(() => super.setLanguage(aCode, context: context));
  }

  late final _$_AppStoreActionController =
      ActionController(name: '_AppStore', context: context);

  @override
  void setLoading(bool val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setLoading');
    try {
      return super.setLoading(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMenuIndex(int val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setMenuIndex');
    try {
      return super.setMenuIndex(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setExpandedMenu(bool val) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setExpandedMenu');
    try {
      return super.setExpandedMenu(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserProfile(String val) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setUserProfile');
    try {
      return super.setUserProfile(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDarkMode(bool val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setDarkMode');
    try {
      return super.setDarkMode(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoggedIn: ${isLoggedIn},
isLoading: ${isLoading},
selectedMenuIndex: ${selectedMenuIndex},
isMenuExpanded: ${isMenuExpanded},
userProfile: ${userProfile},
isDarkMode: ${isDarkMode},
selectedLanguage: ${selectedLanguage}
    ''';
  }
}
