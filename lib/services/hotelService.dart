import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_admin/models/hotel_model.dart';
import '../main.dart';
import '../models/DashboardResponse.dart';
import '../models/PlaceModel.dart';
import '../utils/AppConstant.dart';
import '../utils/ModelKeys.dart';
import 'BaseService.dart';

class HotelService extends BaseService {
  HotelService() {
    ref = db.collection('hotels');
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

  Future<List<HotelModel>> fetchPlaceList({required List<HotelModel> list, String? placeId, String? starId, String placeType = ""}) async {
    Query query;
    QuerySnapshot querySnapshot;

    if(placeId!=null && starId!="All Star"){
      query = ref!.where(PlaceKeys.placeId, isEqualTo: placeId).where(PlaceKeys.starId, isEqualTo: starId).orderBy(CommonKeys.createdAt, descending: true);
    }
    else if (placeId != null) {
      query = ref!.where(PlaceKeys.placeId, isEqualTo: placeId).orderBy(CommonKeys.createdAt, descending: true);
    } else if (starId != "All Star") {
      query = ref!.where(PlaceKeys.starId, isEqualTo: starId).orderBy(CommonKeys.createdAt, descending: true);
    } else if (placeType == PlaceTypeMostRated) {
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

    List<HotelModel> data = querySnapshot.docs.map((e) => HotelModel.fromJson(e.data() as Map<String, dynamic>)).toList();

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

  Future<DocumentReference> addDocumentWithCustomId(String id, Map data) async {
    var doc = ref!.doc(id);

    return await doc.set(data).then((value) {
      log('Added: $data');

      return doc;
    }).catchError((e) {
      log(e);
      throw e;
    });
  }
}
