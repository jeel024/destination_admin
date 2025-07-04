import '../models/ReviewModel.dart';
import '../utils/ModelKeys.dart';

import 'PlaceModel.dart';

class DashboardResponse {
  int? userCount;
  int? categoryCount;
  int? stateCount;
  int? placesCount;
  int? reviewCount;
  List<PlaceModel>? latestPlaces;
  List<ReviewModel>? latestReview;
  List<PlaceModel>? mostRatedPlaces;
  List<PlaceModel>? mostFavouritePlaces;

  DashboardResponse({
    this.userCount,
    this.categoryCount,
    this.stateCount,
    this.placesCount,
    this.reviewCount,
    this.latestPlaces,
    this.latestReview,
    this.mostRatedPlaces,
    this.mostFavouritePlaces,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      userCount: json[DashboardKeys.userCount],
      categoryCount: json[DashboardKeys.categoryCount],
      stateCount: json[DashboardKeys.stateCount],
      placesCount: json[DashboardKeys.placesCount],
      reviewCount: json[DashboardKeys.reviewCount],
      latestPlaces: json[DashboardKeys.latestPlaces] != null ? (json[DashboardKeys.latestPlaces] as List).map((i) => PlaceModel.fromJson(i)).toList() : null,
      latestReview: json[DashboardKeys.latestReview] != null ? (json[DashboardKeys.latestReview] as List).map((i) => ReviewModel.fromJson(i)).toList() : null,
      mostRatedPlaces: json[DashboardKeys.mostRatedPlaces] != null ? (json[DashboardKeys.mostRatedPlaces] as List).map((i) => PlaceModel.fromJson(i)).toList() : null,
      mostFavouritePlaces: json[DashboardKeys.mostFavouritePlaces] != null ? (json[DashboardKeys.mostFavouritePlaces] as List).map((i) => PlaceModel.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson({bool toStore = true}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userCount != null) {
      data[DashboardKeys.userCount] = this.userCount;
    }
    if (this.categoryCount != null) {
      data[DashboardKeys.categoryCount] = this.categoryCount;
    }
    if (this.stateCount != null) {
      data[DashboardKeys.stateCount] = this.stateCount;
    }
    if (this.placesCount != null) {
      data[DashboardKeys.placesCount] = this.placesCount;
    }
    if (this.reviewCount != null) {
      data[DashboardKeys.reviewCount] = this.reviewCount;
    }
    if (this.latestPlaces != null) {
      data[DashboardKeys.latestPlaces] = this.latestPlaces!.map((v) => v.toJson()).toList();
    }
    if (this.latestReview != null) {
      data[DashboardKeys.latestReview] = this.latestReview!.map((v) => v.toJson()).toList();
    }
    if (this.mostRatedPlaces != null) {
      data[DashboardKeys.mostRatedPlaces] = this.mostRatedPlaces!.map((v) => v.toJson()).toList();
    }
    if (this.mostFavouritePlaces != null) {
      data[DashboardKeys.mostFavouritePlaces] = this.mostFavouritePlaces!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
