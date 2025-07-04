class CommonKeys {
  static String id = 'id';
  static String status = 'status';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';
}

class UserKeys {
  static String name = 'name';
  static String email = 'email';
  static String contactNo = 'contactNo';
  static String profileImg = 'profileImg';
  static String loginType = 'loginType';
  static String isAdmin = 'isAdmin';
  static String isDemoAdmin = 'isDemoAdmin';
  static String fcmToken = 'fcmToken';
}

class CategoryKeys {
  static String name = "name";
  static String image = "image";
}

class StateKeys {
  static String name = "name";
  static String image = "image";
}

class PlaceKeys {
  static String categoryId = "categoryId";
  static String placeId = "placeId";
  static String starId = "starId";
  static String distance = "distance";
  static String name = "name";
  static String image = "image";
  static String stateId = "stateId";
  static String cityId = "cityId";
  static String address = "address";
  static String secondaryImages = "secondaryImages";
  static String favourites = "favourites";
  static String rating = 'rating';
  static String description = 'description';
  static String caseSearch = 'caseSearch';
  static String latitude = "latitude";
  static String longitude = "longitude";
  static String userId = "userId";
}

class ReviewKeys {
  static String comment = 'comment';
  static String placeId = 'placeId';
  static String updatedAt = 'updatedAt';
  static String userId = 'userId';
  static String rating = 'rating';
}

class DashboardKeys {
  static String userCount = "userCount";
  static String categoryCount = "categoryCount";
  static String stateCount = "stateCount";
  static String placesCount = "placesCount";
  static String reviewCount = "reviewCount";
  static String latestPlaces = "latestPlaces";
  static String latestReview = "latestReview";
  static String mostRatedPlaces = "mostRatedPlaces";
  static String mostFavouritePlaces = "mostFavouritePlaces";
}

class AddressKey {
  static String results = 'results';
  static String status = 'status';
}

class AddressResultKey {
  static String address_components = 'address_components';
  static String formatted_address = 'formatted_address';
  static String geometry = 'geometry';
  static String place_id = 'place_id';
}

class AddressComponentKey {
  static String long_name = 'long_name';
  static String short_name = 'short_name';
  static String types = 'types';
}

class GeometryKey {
  static String location = 'location';
}

class LocationKey {
  static String lat = 'lat';
  static String lng = 'lng';
}

