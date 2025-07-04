import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/StateModel.dart';
import '../services/BaseService.dart';

import '../utils/AppConstant.dart';
import '../utils/ModelKeys.dart';

class StateService extends BaseService {
  StateService() {
    ref = db.collection('state');
  }

  Future<List<StateModel>> getStates() {
    return ref!.where(CommonKeys.status,isEqualTo: 1).orderBy(CommonKeys.createdAt, descending: true).get().then((value) => value.docs.map((e) => StateModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<StateModel>> fetchStateList({required List<StateModel> list}) async {
    QuerySnapshot querySnapshot;
    List<StateModel> filterList = [];

    if (list.isEmpty) {
      querySnapshot = await ref!.orderBy(CommonKeys.createdAt, descending: true).limit(perPageLimit).get();
    } else {
      querySnapshot = await ref!.orderBy(CommonKeys.createdAt, descending: true).startAfter([list[list.length - 1].createdAt]).limit(perPageLimit).get();
    }

    List<StateModel> data = querySnapshot.docs.map((e) => StateModel.fromJson(e.data() as Map<String, dynamic>)).toList();

    /// Eliminate duplicate data
    for (int i = 0; i < data.length; i++) {
      if (!list.any((element) => element.id == data[i].id)) {
        filterList.add(data[i]);
      }
    }

    return filterList;
  }

  Future<int> totalState() {
    return ref!.get().then((x) => x.docs.length);
  }
}
