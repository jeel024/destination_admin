import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/ReviewModel.dart';
import '../utils/AppConstant.dart';
import '../utils/ModelKeys.dart';
import 'BaseService.dart';

class ReviewService extends BaseService {
  ReviewService() {
    ref = db.collection('reviews');
  }

  Future<List<ReviewModel>> fetchReviewList({required List<ReviewModel> list, String? placeId}) async {
    QuerySnapshot querySnapshot;
    List<ReviewModel> filterList = [];

    if (list.isEmpty) {
      querySnapshot = await ref!.where(ReviewKeys.placeId, isEqualTo: placeId).orderBy(CommonKeys.createdAt, descending: true).limit(perPageLimit).get();
    } else {
      querySnapshot = await ref!.where(ReviewKeys.placeId, isEqualTo: placeId).orderBy(CommonKeys.createdAt, descending: true).startAfter([list[list.length - 1].createdAt]).limit(perPageLimit).get();
    }

    List<ReviewModel> data = querySnapshot.docs.map((e) => ReviewModel.fromJson(e.data() as Map<String, dynamic>)).toList();

    /// Eliminate duplicate data
    for (int i = 0; i < data.length; i++) {
      if (!list.any((element) => element.id == data[i].id)) {
        filterList.add(data[i]);
      }
    }

    return filterList;
  }

  Future<List<ReviewModel>> latestReviews() {
    return ref!.orderBy(CommonKeys.createdAt, descending: true).limit(latestRecordLimit).get().then((event) => event.docs.map((e) => ReviewModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<int> totalReviews({String? placeId}) {
    return ref!.where(ReviewKeys.placeId, isEqualTo: placeId).get().then((x) => x.docs.length);
  }
}
