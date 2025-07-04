import 'package:flutter/material.dart';

class MenuItemModel {
  int? index;
  IconData? icon;
  String? title;
  Widget? widget;

  MenuItemModel({this.index,this.icon, this.title, this.widget});
}

class StatusModel{
  int? value;
  String? title;

  StatusModel(this.value, this.title);
}

class CategoryModelStatic {
  String? name;
  String? image;
  int? id;
  int? status;

  CategoryModelStatic({this.name, this.image,this.id,this.status});
}

