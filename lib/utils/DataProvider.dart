import 'package:destination_admin/models/hotel_model.dart';

import '../components/PlacesRequestWidget.dart';
import '../components/UploadHotelWidget.dart';
import '../components/UsersWidget.dart';
import '../components/cityWidget.dart';
import '../components/hotelsWidget.dart';
import '../main.dart';
import '../models/PlaceModel.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../components/CategoryWidget.dart';
import '../components/HomeWidget.dart';
import '../components/PlaceReviewWidget.dart';
import '../components/PlacesWidget.dart';
import '../components/StatesWidget.dart';
import '../components/UploadPlaceWidget.dart';
import '../models/LanguageDataModel.dart';
import '../models/models.dart';
import 'AppConstant.dart';

List<MenuItemModel> getMenuItems({String? catId, String? stateId,String? cityId, String? placeId, String? starId, PlaceModel? place,HotelModel? hotel, String plaType = "",bool isRequestPlace = false}) {
  List<MenuItemModel> list = [];
  list.add(MenuItemModel(index: DASHBOARD_INDEX, icon: MaterialCommunityIcons.view_dashboard_outline, title: language.dashboard, widget: HomeWidget()));
  list.add(MenuItemModel(index: CATEGORY_INDEX, icon: Feather.list, title: language.category, widget: CategoryWidget()));
  list.add(MenuItemModel(index: STATE_INDEX, icon: Ionicons.location_outline, title: language.state, widget: StatesWidget()));
  list.add(MenuItemModel(index: CITY_INDEX, icon: Ionicons.location_outline, title: "City", widget: CityWidget(stateId: stateId,)));
  list.add(MenuItemModel(index: PLACES_REQUEST_INDEX, icon: MaterialCommunityIcons.city_variant_outline, title: language.placesRequest, widget: PlacesRequestWidget()));
  list.add(MenuItemModel(index: PLACE_INDEX, icon: MaterialCommunityIcons.city_variant_outline, title: language.places, widget: PlacesWidget(catId: catId, stateId: stateId, placeType: plaType)));
  list.add(MenuItemModel(index: UPLOAD_PLACE_INDEX, icon: Feather.upload, title: language.uploadPlaces, widget: UploadPlaceWidget(placeModel: place,isRequestPlace: isRequestPlace)));
  list.add(MenuItemModel(index: HOTEL_INDEX, icon: MaterialCommunityIcons.city_variant_outline, title: "Hotel", widget: HotelsWidget(placeId: placeId, starId: starId, placeType: plaType)));
  list.add(MenuItemModel(index: UPLOAD_HOTEL_INDEX, icon: Feather.upload, title: "Upload Hotel", widget: UploadHotelWidget(hotelModel: hotel,isRequestPlace: isRequestPlace)));
  list.add(MenuItemModel(index: USER_INDEX, icon: Feather.users, title: language.users, widget: UsersWidget()));
  list.add(MenuItemModel(index: PLACE_REVIEW_INDEX, icon: FontAwesome.star_o, title: language.placeReviews, widget: PlaceReviewWidget(placeId: placeId)));
  // list.add(MenuItemModel(index: APP_SETTING_INDEX, icon: Ionicons.settings_outline, title: language.appSettings, widget: AppSettingWidget()));
  return list;
}

List<StatusModel> getStatusList() {
  List<StatusModel> list = [];
  list.add(StatusModel(1, language.active));
  list.add(StatusModel(0, language.inactive));
  return list;
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(id: 1, name: 'Spanish', subTitle: 'Española', languageCode: 'es', fullLanguageCode: 'es-ES', flag: 'assets/flag/ic_spain.png'),
    LanguageDataModel(id: 2, name: 'Afrikaans', subTitle: 'Afrikaans', languageCode: 'af', fullLanguageCode: 'af-AF', flag: 'assets/flag/ic_south_africa.png'),
    LanguageDataModel(id: 3, name: 'French', subTitle: 'Français', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/flag/ic_france.png'),
    LanguageDataModel(id: 1, name: 'German', subTitle: 'Deutsch', languageCode: 'de', fullLanguageCode: 'de-DE', flag: 'assets/flag/ic_germany.png'),
    LanguageDataModel(id: 2, name: 'Indonesian', subTitle: 'bahasa Indonesia', languageCode: 'id', fullLanguageCode: 'id-ID', flag: 'assets/flag/ic_indonesia.png'),
    LanguageDataModel(id: 3, name: 'Portuguese', subTitle: 'Português', languageCode: 'pt', fullLanguageCode: 'pt-PT', flag: 'assets/flag/ic_portugal.png'),
    LanguageDataModel(id: 1, name: 'Turkish', subTitle: 'Türkçe', languageCode: 'tr', fullLanguageCode: 'tr-TR', flag: 'assets/flag/ic_turkey.png'),
    LanguageDataModel(id: 2, name: 'vietnamese', subTitle: 'Tiếng Việt', languageCode: 'vi', fullLanguageCode: 'vi-VI', flag: 'assets/flag/ic_vitnam.png'),
    LanguageDataModel(id: 3, name: 'Dutch', subTitle: 'Nederlands', languageCode: 'nl', fullLanguageCode: 'nl-NL', flag: 'assets/flag/ic_dutch.png'),
  ];
}
