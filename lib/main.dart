import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_admin/services/CityService.dart';
import 'package:destination_admin/services/hotelService.dart';
import '../screens/SplashScreen.dart';
import '../services/AppSettingService.dart';
import '../services/CategoryService.dart';
import '../services/PlaceService.dart';
import '../services/ReviewServices.dart';
import '../services/StateService.dart';
import '../services/UserService.dart';
import '../services/requestPlaceService.dart';
import '../store/AppStore.dart';
import '../utils/AppConstant.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/device_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppTheme.dart';
import 'language/AppLocalizations.dart';
import 'language/BaseLanguage.dart';
import 'models/LanguageDataModel.dart';

AppStore appStore = AppStore();
late BaseLanguage language;
List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

late SharedPreferences sharedPreferences;
final navigatorKey = GlobalKey<NavigatorState>();

UserService userService = UserService();
CategoryService categoryService = CategoryService();
StateService stateService = StateService();
CityService cityService = CityService();
PlaceService placeService = PlaceService();
HotelService hotelService = HotelService();
ReviewService reviewService = ReviewService();
AppSettingService appSettingService = AppSettingService();
RequestPlaceService requestPlaceService = RequestPlaceService();

Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  sharedPreferences = await SharedPreferences.getInstance();
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel = getSelectedLanguageModel(defaultLang: defaultLanguage);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBejXTk5KYKEInPViVikHz9WOnoAuvNeJI",
        authDomain: "discover-destination.firebaseapp.com",
        projectId: "discover-destination",
        storageBucket: "discover-destination.appspot.com",
        messagingSenderId: "579061873435",
        appId: "1:579061873435:web:6bfd3e2a55ba4a55a271be",
        measurementId: "G-7VKE5ZQLQ5"
    ),
  );

  if(isMobile){
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  await initialize(aLocaleLanguageList: languageList());
  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage));

  sharedPreferences = await SharedPreferences.getInstance();
  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));
  appStore.setUserProfile(getStringAsync(USER_PROFILE));
  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }
  await appSettingService.getAppSettings().then((value) {
    if (value.isNotificationOn != null) {
      setValue(IS_NOTIFICATION_ON, value.isNotificationOn);
    }
  }).catchError((e) {
    throw e;
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: language.appName,
        home: SplashScreen(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage.validate(value: defaultLanguage)),
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              },
            ),
            child: child!,
          );
        },
      );
    });
  }
}
