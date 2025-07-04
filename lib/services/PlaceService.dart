import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/DashboardResponse.dart';
import '../models/PlaceModel.dart';
import '../utils/AppConstant.dart';
import '../utils/ModelKeys.dart';
import 'BaseService.dart';

class PlaceService extends BaseService {
  PlaceService() {
    ref = db.collection('places');
  }

  Future<DashboardResponse> getDashboardData() async {
    DashboardResponse dashboardResponse = DashboardResponse();

    dashboardResponse.userCount = await userService.totalUsers();
    dashboardResponse.categoryCount = await categoryService.totalCategory();
    dashboardResponse.placesCount = await placeService.totalPlaces();
    dashboardResponse.reviewCount = await reviewService.totalReviews();
    dashboardResponse.stateCount = await stateService.totalState();
    dashboardResponse.latestPlaces = await placeService.latestPlaces();
    dashboardResponse.mostRatedPlaces = await placeService.mostRatedPlaces();
    dashboardResponse.latestReview = await reviewService.latestReviews();
    dashboardResponse.mostFavouritePlaces = await placeService.mostFavouritePlaces();

    return dashboardResponse;
  }
  Future<List<PlaceModel>> getPlaces() {
    return ref!.where(CommonKeys.status,isEqualTo: 1).orderBy(CommonKeys.createdAt, descending: true).get().then((value) => value.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<PlaceModel>> fetchPlaceList({required List<PlaceModel> list, String? catId, String? stateId,String? cityId, String placeType = ""}) async {
    Query query;
    QuerySnapshot querySnapshot;

    if(catId!=null && stateId!=null && cityId != null){
      query = ref!.where(PlaceKeys.categoryId, isEqualTo: catId).where(PlaceKeys.stateId, isEqualTo: stateId).where(PlaceKeys.cityId, isEqualTo: cityId).orderBy(CommonKeys.createdAt, descending: true);
    } else if( stateId!=null && cityId != null){
      query = ref!.where(PlaceKeys.stateId, isEqualTo: stateId).where(PlaceKeys.cityId, isEqualTo: cityId).orderBy(CommonKeys.createdAt, descending: true);
    }
    else if(catId!=null && stateId!=null ){
      query = ref!.where(PlaceKeys.categoryId, isEqualTo: catId).where(PlaceKeys.stateId, isEqualTo: stateId).orderBy(CommonKeys.createdAt, descending: true);
    }
    else if (catId != null) {
      query = ref!.where(PlaceKeys.categoryId, isEqualTo: catId).orderBy(CommonKeys.createdAt, descending: true);
    } else if (stateId != null) {
      query = ref!.where(PlaceKeys.stateId, isEqualTo: stateId).orderBy(CommonKeys.createdAt, descending: true);
    } else if (cityId != null) {
      query = ref!.where(PlaceKeys.cityId, isEqualTo: cityId).orderBy(CommonKeys.createdAt, descending: true);
    }
    else if (placeType == PlaceTypeMostRated) {
      query = ref!.orderBy(PlaceKeys.rating, descending: true);
    } else if (placeType == PlaceTypeMostFavourite) {
      query = ref!.orderBy(PlaceKeys.favourites, descending: true);
    } else {
      query = ref!.orderBy(CommonKeys.createdAt, descending: true);
    }

    if (list.isEmpty) {
      querySnapshot = await query.limit(perPageLimit).get();
    } else {
      querySnapshot = await query.startAfterDocument(await ref!.doc(list[list.length - 1].id).get()).limit(perPageLimit).get();
    }

    List<PlaceModel> data = querySnapshot.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList();

    return data;
  }

  Future<List<PlaceModel>> latestPlaces() {
    return ref!.orderBy(CommonKeys.createdAt, descending: true).limit(latestRecordLimit).get().then((event) => event.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<PlaceModel>> mostFavouritePlaces() {
    return ref!
        .where(PlaceKeys.favourites, isNotEqualTo: 0)
        .orderBy(PlaceKeys.favourites, descending: true)
        .limit(latestRecordLimit)
        .get()
        .then((event) => event.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<PlaceModel>> mostRatedPlaces() {
    return ref!
        .where(PlaceKeys.rating, isNotEqualTo: 0)
        .orderBy(PlaceKeys.rating, descending: true)
        .limit(latestRecordLimit)
        .get()
        .then((event) => event.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<PlaceModel>> placesFuture({String? catId, String? stateId}) async {
    QuerySnapshot querySnapshot;
    if (catId != null) {
      querySnapshot = await ref!.where(PlaceKeys.categoryId, isEqualTo: catId).orderBy(CommonKeys.createdAt, descending: true).get();
    } else if (stateId != null) {
      querySnapshot = await ref!.where(PlaceKeys.stateId, isEqualTo: stateId).orderBy(CommonKeys.createdAt, descending: true).get();
    } else {
      querySnapshot = await ref!.orderBy(CommonKeys.createdAt, descending: true).get();
    }

    return querySnapshot.docs.map((e) => PlaceModel.fromJson(e.data() as Map<String, dynamic>)).toList();
  }

  Future<int> totalPlaces({String? catId, String? stateId}) {
    return ref!.where(PlaceKeys.categoryId, isEqualTo: catId).where(PlaceKeys.stateId, isEqualTo: stateId).get().then((x) => x.docs.length);
  }
  Future<int> totalPlacesByCity({String? catId, String? cityId}) {
    return ref!.where(PlaceKeys.categoryId, isEqualTo: catId).where(PlaceKeys.cityId, isEqualTo: cityId).get().then((x) => x.docs.length);
  }
}
