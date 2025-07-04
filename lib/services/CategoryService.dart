import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/CategoryModel.dart';
import '../services/BaseService.dart';
import '../utils/ModelKeys.dart';

import '../utils/AppConstant.dart';

class CategoryService extends BaseService {
  CategoryService() {
    ref = db.collection('category');
  }

  Future<List<CategoryModel>> getCategories() {
    return ref!.where(CommonKeys.status,isEqualTo: 1).orderBy(CommonKeys.createdAt, descending: true).get().then((value) => value.docs.map((e) => CategoryModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  /* /// Initially load 10 data
  Future<List<CategoryModel>> fetchFirstList() async {
    List<CategoryModel> data = await ref!
        .orderBy(CommonKeys.createdAt, descending: true)
        .limit(perPageLimit)
        .get()
        .then((value) => value.docs.map((e) => CategoryModel.fromJson(e.data() as Map<String, dynamic>)).toList())
        .catchError((e) => throw e);

    return data;
  }

  /// Load 10 more data
  Future<List<CategoryModel>> fetchNextList({required List<CategoryModel> list}) async {
    List<CategoryModel> filterList = [];

    List<CategoryModel> data = await ref!
        .orderBy(CommonKeys.createdAt, descending: true)
        .startAfter([list[list.length - 1].createdAt])
        .limit(perPageLimit)
        .get()
        .then((value) => value.docs.map((e) => CategoryModel.fromJson(e.data() as Map<String, dynamic>)).toList())
        .catchError((e) => throw e);

    /// Eliminate duplicate data
    for (int i = 0; i < data.length; i++) {
      if (!list.any((element) => element.id == data[i].id)) {
        filterList.add(data[i]);
      }
    }

    return filterList;
  }*/

  Future<List<CategoryModel>> fetchCategoryList({required List<CategoryModel> list}) async {
    QuerySnapshot querySnapshot;
    List<CategoryModel> filterList = [];

    if (list.isEmpty) {
      querySnapshot = await ref!.orderBy(CommonKeys.createdAt, descending: true).limit(perPageLimit).get();
    } else {
      querySnapshot = await ref!.orderBy(CommonKeys.createdAt, descending: true).startAfter([list[list.length - 1].createdAt]).limit(perPageLimit).get();
    }

    List<CategoryModel> data = querySnapshot.docs.map((e) => CategoryModel.fromJson(e.data() as Map<String, dynamic>)).toList();

    /// Eliminate duplicate data
    for (int i = 0; i < data.length; i++) {
      if (!list.any((element) => element.id == data[i].id)) {
        filterList.add(data[i]);
      }
    }

    return filterList;
  }

  Future<int> totalCategory() {
    return ref!.get().then((x) => x.docs.length);
  }
}
