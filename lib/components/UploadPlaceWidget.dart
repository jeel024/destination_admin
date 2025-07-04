import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_admin/models/CityModel.dart';
import '../main.dart';
import '../models/PlaceModel.dart';
import '../models/StateModel.dart';
import '../utils/AppConstant.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../models/AddressModel.dart';
import '../models/CategoryModel.dart';
import '../models/models.dart';
import '../services/FileStorageService.dart';
import '../services/SendNotification.dart';
import '../utils/AppColor.dart';
import '../utils/Common.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/AppButton.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';

class UploadPlaceWidget extends StatefulWidget {
  final PlaceModel? placeModel;
  final bool isRequestPlace;

  UploadPlaceWidget({this.placeModel, this.isRequestPlace = false});

  @override
  UploadPlaceWidgetState createState() => UploadPlaceWidgetState();
}

class UploadPlaceWidgetState extends State<UploadPlaceWidget> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController placeNameController = TextEditingController();
  TextEditingController placeAddressController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<StatusModel> statusList = getStatusList();
  int status = 1;

  XFile? primaryImage;
  List<XFile> secondaryImages = [];

  List<CategoryModel> categoryList = [];
  List<StateModel> stateList = [];
  List<CityModel> cityList = [];
  String? categoryId;
  String? stateId;
  String? cityId;

  bool isUpdate = false;

  GeoPoint? placeGeoPoint;

  LatLng? latLng;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    categoryList = await categoryService.getCategories();
    stateList = await stateService.getStates();
    print("STATE LIST :::::: $stateList");
    isUpdate = widget.placeModel != null;
    if (isUpdate) {
      placeNameController.text = widget.placeModel!.name.validate();
      status = widget.placeModel!.status.validate();
      if (categoryList.any((element) => element.id == widget.placeModel!.categoryId)) {
        categoryId = widget.placeModel!.categoryId.validate();
      }
      if (stateList.any((element) => element.id == widget.placeModel!.stateId)) {
        stateId = widget.placeModel!.stateId.validate();
        cityList = await cityService.fetchCityList(list: cityList,stateId: stateId);

      }
      if (cityList.any((element) => element.id == widget.placeModel!.cityId)) {
        cityId = widget.placeModel!.cityId.validate();
      }

      placeAddressController.text = widget.placeModel!.address.validate();
      latLng = LatLng(widget.placeModel!.latitude.validate(), widget.placeModel!.longitude.validate());
      descriptionController.text = widget.placeModel!.description.validate();
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future getAddress(String text) async {
    String url = 'https://maps.google.com/maps/api/geocode/json?key=$googleMapApiKey&address=${Uri.encodeComponent(text)}';
    Response res = await get(Uri.parse(url));

    if (res.statusCode.isSuccessful()) {
      AddressModel addressModel = AddressModel.fromJson(jsonDecode(res.body));

      if (addressModel.results!.isNotEmpty) {
        AddressResult addressResult = addressModel.results!.first;
        placeAddressController.text = addressResult.formatted_address!;
        latLng = LatLng(addressResult.geometry!.location!.lat!, addressResult.geometry!.location!.lng!);
        mLaunchUrl('https://www.google.com/maps/search/?api=1&query=${latLng!.latitude}%2C${latLng!.longitude}');
        setState(() {});
      }
    } else {
      throw language.somethingWentWrong;
    }
  }

  Future<void> save() async {
    appStore.setLoading(true);
    PlaceModel placeModel = PlaceModel();

    placeModel.name = placeNameController.text.trim();
    placeModel.updatedAt = DateTime.now();
    placeModel.status = status;
    placeModel.address = placeAddressController.text.trim();
    placeModel.latitude = double.parse(latLng!.latitude.toStringAsFixed(5));
    placeModel.longitude = double.parse(latLng!.longitude.toStringAsFixed(5));
    placeModel.categoryId = categoryId;
    placeModel.stateId = stateId;
    placeModel.cityId = cityId;
    placeModel.caseSearch = placeNameController.text.trim().setSearchParam();
    placeModel.description = descriptionController.text.trim();
    placeModel.favourites = 0;
    placeModel.rating = 0;

    if (isUpdate) {
      if (!widget.isRequestPlace) {
        placeModel.id = widget.placeModel!.id;
      }else{
        placeModel.userId = widget.placeModel!.userId;
      }
      placeModel.createdAt = widget.placeModel!.createdAt;
      placeModel.image = widget.placeModel!.image;
      placeModel.secondaryImages = widget.placeModel!.secondaryImages;
      placeModel.favourites = widget.placeModel!.favourites ?? 0;
      placeModel.rating = widget.placeModel!.rating ?? 0;
    } else {
      placeModel.createdAt = DateTime.now();
    }

    if (primaryImage != null) {
      await uploadFile(bytes: await primaryImage!.readAsBytes(), prefix: mPlacesStoragePath).then((path) async {
        placeModel.image = path;
      }).catchError((e) {
        toast(e.toString());
      });
    }

    if (secondaryImages.isNotEmpty) {
      List<String> list = [];
      Future.forEach(secondaryImages, (XFile element) async {
        await uploadFile(bytes: await element.readAsBytes(), prefix: mPlacesStoragePath).then((path) async {
          list.add(path);
        }).catchError((e) {
          toast(e.toString());
        });
      }).then((value) async {
        placeModel.secondaryImages = list;
        await addPlace(placeModel);
      });
    } else {
      await addPlace(placeModel);
    }
  }

  Future addPlace(PlaceModel placeModel) async {
    if (isUpdate && !widget.isRequestPlace) {
      await placeService.updateDocument(placeModel.toJson(), placeModel.id).then((value) {
        appStore.setLoading(false);
        toast(language.placeUpdated);
        appStore.setMenuIndex(PLACE_INDEX);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      await placeService.addDocument(placeModel.toJson()).then((value) {
        appStore.setLoading(false);
        if(widget.isRequestPlace){
          requestPlaceService.removeDocument(widget.placeModel!.id);
        }
        toast(language.placeAdded);
        appStore.setMenuIndex(PLACE_INDEX);
        if (getBoolAsync(IS_NOTIFICATION_ON, defaultValue: defaultIsNotificationOn)) {
          String catName = categoryList.firstWhere((element) => element.id == placeModel.categoryId).name ?? "";
          sendPushNotifications(parseHtmlString(placeModel.name), parseHtmlString(catName), id: value.id, image: placeModel.image.validate());
        }
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  Widget headingWidget() {
    return Text(language.uploadPlaces, style: boldTextStyle(size: 20, color: primaryColor));
  }

  Widget getPrimaryImage() {
    if (primaryImage != null) {
      return Image.network(primaryImage!.path, height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center);
    } else if (isUpdate && widget.placeModel!.image.validate().isNotEmpty) {
      return cachedImage(widget.placeModel!.image.validate(), height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center);
    } else {
      return SizedBox(height: 130);
    }
  }

  Widget getSecondaryImages() {
    if (secondaryImages.isNotEmpty) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: secondaryImages.map((image) {
          return Stack(
            children: [
              Image.network(image.path, height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.highlight_remove, color: Colors.white).onTap(() {
                  secondaryImages.remove(image);
                  setState(() {});
                }),
              )
            ],
          );
        }).toList(),
      );
    } else if (isUpdate && (widget.placeModel!.secondaryImages ?? []).isNotEmpty) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: widget.placeModel!.secondaryImages!.map((image) {
          return Stack(
            children: [
              cachedImage(image, height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center),
              Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.highlight_remove, color: Colors.white).onTap(() async {
                    widget.placeModel!.secondaryImages!.remove(image);
                    setState(() {});
                  })),
            ],
          );
        }).toList(),
      );
    } else {
      return SizedBox(height: 130);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: ScrollController(),
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headingWidget(),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(defaultRadius), boxShadow: commonBoxShadow()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.placeName, style: primaryTextStyle()),
                              8.height,
                              AppTextField(
                                controller: placeNameController,
                                autoFocus: false,
                                textFieldType: TextFieldType.NAME,
                                keyboardType: TextInputType.name,
                                errorThisFieldRequired: language.errorThisFieldIsRequired,
                                decoration: commonInputDecoration(hintText: language.placeName),
                              ),
                            ],
                          ).expand(),
                          24.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.status, style: primaryTextStyle()),
                              8.height,
                              DropdownButtonFormField<int>(
                                dropdownColor: Theme.of(context).cardColor,
                                value: status,
                                decoration: commonInputDecoration(),
                                items: statusList.map<DropdownMenuItem<int>>((item) {
                                  return DropdownMenuItem(
                                    value: item.value,
                                    child: Text(item.title.validate(), style: primaryTextStyle()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  status = value!;
                                  setState(() {});
                                },
                                validator: (s) {
                                  if (s == null) return language.errorThisFieldIsRequired;
                                  return null;
                                },
                              ),
                            ],
                          ).expand(),
                        ],
                      ),
                      24.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.category, style: primaryTextStyle()),
                              8.height,
                              categoryList.isNotEmpty
                                  ? DropdownButtonFormField<String>(
                                      dropdownColor: Theme.of(context).cardColor,
                                      value: categoryId,
                                      decoration: commonInputDecoration(),
                                      items: categoryList.map<DropdownMenuItem<String>>((item) {
                                        return DropdownMenuItem(
                                          value: item.id,
                                          child: Text(item.name.validate(), style: primaryTextStyle()),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        categoryId = value!;
                                        setState(() {});
                                      },
                                      validator: (s) {
                                        if (s == null) return language.errorThisFieldIsRequired;
                                        return null;
                                      },
                                    )
                                  : Text(language.noDataFound, style: primaryTextStyle(size: 14)),
                            ],
                          ).expand(),
                          24.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.state, style: primaryTextStyle()),
                              8.height,
                              stateList.isNotEmpty
                                  ? DropdownButtonFormField<String>(
                                      dropdownColor: Theme.of(context).cardColor,
                                      value: stateId,
                                      decoration: commonInputDecoration(),
                                      items: stateList.map<DropdownMenuItem<String>>((item) {
                                        return DropdownMenuItem(
                                          value: item.id,
                                          child: Text(item.name.validate(), style: primaryTextStyle(size: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (value) async {
                                        stateId = value!;
                                        cityList = await cityService.fetchCityList(list: [],stateId: stateId);
                                        setState(() {});
                                      },
                                      validator: (s) {
                                        if (s == null) return language.errorThisFieldIsRequired;
                                        return null;
                                      },
                                    )
                                  : Text(language.noDataFound, style: primaryTextStyle()),
                            ],
                          ).expand(),
                        ],
                      ),
                      24.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("City", style: primaryTextStyle()),
                              8.height,
                              cityList.isNotEmpty
                                  ? DropdownButtonFormField<String>(
                                      dropdownColor: Theme.of(context).cardColor,
                                      value: cityId,
                                      decoration: commonInputDecoration(),
                                      items: cityList.map<DropdownMenuItem<String>>((item) {
                                        return DropdownMenuItem(
                                          value: item.id,
                                          child: Text(item.name.validate(), style: primaryTextStyle(size: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        cityId = value!;
                                        setState(() {});
                                      },
                                      validator: (s) {
                                        if (s == null) return language.errorThisFieldIsRequired;
                                        return null;
                                      },
                                    )
                                  : Text(language.noDataFound, style: primaryTextStyle()),
                            ],
                          ).expand(),
                          24.width,
                          Expanded(child: SizedBox())
                        ],
                      ),
                      24.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: language.placeAddress,
                                  style: primaryTextStyle(),
                                  children: [
                                    TextSpan(text: ' ${language.addressNote}', style: secondaryTextStyle()),
                                  ],
                                ),
                              ),
                              8.height,
                              Stack(
                                children: [
                                  AppTextField(
                                    controller: placeAddressController,
                                    autoFocus: false,
                                    maxLines: 5,
                                    minLines: 5,
                                    textFieldType: TextFieldType.ADDRESS,
                                    keyboardType: TextInputType.streetAddress,
                                    textInputAction: TextInputAction.next,
                                    errorThisFieldRequired: language.errorThisFieldIsRequired,
                                    decoration: commonInputDecoration(hintText: language.placeAddress),
                                    validator: (s) {
                                      return null;
                                    },
                                    onChanged: (val) async {
                                      latLng = null;
                                      setState(() {});
                                    },
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Row(
                                      children: [
                                        if (latLng != null)
                                          Icon(Icons.location_pin).onTap(() {
                                            mLaunchUrl('https://www.google.com/maps/search/?api=1&query=${latLng!.latitude}%2C${latLng!.longitude}');
                                          }).paddingRight(16),
                                        AppButtonWidget(
                                          child: Text(language.getAddress, style: primaryTextStyle(color: Colors.white)),
                                          color: primaryColor.withOpacity(0.5),
                                          hoverColor: primaryColor,
                                          splashColor: primaryColor,
                                          focusColor: primaryColor,
                                          elevation: 0,
                                          onTap: () async {
                                            if (placeAddressController.text.isNotEmpty) {
                                              await getAddress(placeAddressController.text);
                                            } else {
                                              toast(language.pleaseWriteSomeText);
                                            }
                                          },
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ).expand(),
                          24.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.description, style: primaryTextStyle()),
                              8.height,
                              AppTextField(
                                controller: descriptionController,
                               autoFocus: false,
                                maxLines: 5,
                               minLines: 5,
                                textFieldType: TextFieldType.ADDRESS,
                                keyboardType: TextInputType.multiline,
                               // textInputAction: TextInputAction.next,
                                errorThisFieldRequired: language.errorThisFieldIsRequired,
                                decoration: commonInputDecoration(hintText: language.description),
                              ),
                            ],
                          ).expand(),
                        ],
                      ),
                      24.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.primaryImage, style: primaryTextStyle()),
                              8.height,
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: radius(defaultRadius),
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppButtonWidget(
                                          child: Text(language.browse, style: primaryTextStyle(color: Colors.white)),
                                          color: primaryColor.withOpacity(0.5),
                                          elevation: 0,
                                          hoverColor: primaryColor,
                                          splashColor: primaryColor,
                                          focusColor: primaryColor,
                                          onTap: () async {
                                            primaryImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
                                            setState(() {});
                                          },
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                        16.width,
                                        Text(language.clear, style: primaryTextStyle(decoration: TextDecoration.underline)).onTap(() async {
                                          if (primaryImage != null) {
                                            primaryImage = null;
                                          } else if (isUpdate && widget.placeModel!.image != null) {
                                            widget.placeModel!.image = null;
                                            setState(() {});
                                          }
                                          setState(() {});
                                        }),
                                      ],
                                    ),
                                    16.height,
                                    getPrimaryImage(),
                                  ],
                                ),
                              ),
                            ],
                          ).expand(),
                          24.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.secondaryImages, style: primaryTextStyle()),
                              8.height,
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: radius(defaultRadius),
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppButtonWidget(
                                          child: Text(language.browse, style: primaryTextStyle(color: Colors.white)),
                                          elevation: 0,
                                          color: primaryColor.withOpacity(0.5),
                                          hoverColor: primaryColor,
                                          splashColor: primaryColor,
                                          focusColor: primaryColor,
                                          onTap: () async {
                                            secondaryImages = await ImagePicker().pickMultiImage(imageQuality: 100);
                                            setState(() {});
                                          },
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                        16.width,
                                        Text(language.clear, style: primaryTextStyle(decoration: TextDecoration.underline)).onTap(() async {
                                          if (secondaryImages.isNotEmpty) {
                                            secondaryImages = [];
                                            setState(() {});
                                          } else if (isUpdate && widget.placeModel!.secondaryImages != null) {
                                            widget.placeModel!.secondaryImages = [];
                                            setState(() {});
                                          }
                                        }),
                                      ],
                                    ),
                                    16.height,
                                    getSecondaryImages(),
                                  ],
                                ),
                              ),
                            ],
                          ).expand(),
                        ],
                      ),
                      24.height,
                      Align(
                          alignment: Alignment.center,
                          child: dialogPrimaryButton(widget.isRequestPlace ? language.approve : isUpdate ? language.update :language.save, () {
                            if (formKey.currentState!.validate()) {
                              if (latLng == null) return toast(language.pleaseEnterValidAddress);
                              if (primaryImage != null || (isUpdate && widget.placeModel!.image != null)) {
                                if (getBoolAsync(IS_DEMO_ADMIN)) {
                                  return toast(language.demoAdminMsg);
                                } else {
                                  save();
                                }
                              } else {
                                toast(language.pleaseSelectPrimaryImage);
                              }
                            }
                          }))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
      ],
    );
  }
}
