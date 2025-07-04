import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:destination_admin/models/PlaceModel.dart';
import 'package:destination_admin/models/hotel_model.dart';
import 'package:destination_admin/services/AuthServices.dart';
import '../main.dart';
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
import '../utils/AppColor.dart';
import '../utils/Common.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/AppButton.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';

class UploadHotelWidget extends StatefulWidget {
  final HotelModel? hotelModel;
  final bool isRequestPlace;

  UploadHotelWidget({this.hotelModel, this.isRequestPlace = false});

  @override
  UploadHotelWidgetState createState() => UploadHotelWidgetState();
}

class UploadHotelWidgetState extends State<UploadHotelWidget> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController hotelNameController = TextEditingController();
  TextEditingController placeAddressController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<StatusModel> statusList = getStatusList();
  int status = 1;

  XFile? primaryImage;
  List<XFile> secondaryImages = [];

  List<CategoryModel> categoryList = [];
  List<PlaceModel> placeList = [];
  List<StateModel> stateList = [];
  List starList = ["3 Star","5 Star","7 Star"];
  String? categoryId;
  String? placeId;
  String? stateId;
  String? starId;

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
    placeList = await  placeService.getPlaces();
    stateList = await stateService.getStates();

    isUpdate = widget.hotelModel != null;
    if (isUpdate) {
      hotelNameController.text = widget.hotelModel!.name.validate();
      status = widget.hotelModel!.status.validate();
     
      if (placeList.any((element) => element.id == widget.hotelModel!.placeId)) {
        placeId = widget.hotelModel!.placeId.validate();
      }
      starId = widget.hotelModel!.starId.validate();
      
      placeAddressController.text = widget.hotelModel!.address.validate();
      distanceController.text = widget.hotelModel!.distance.toString().validate();
      latLng = LatLng(widget.hotelModel!.latitude.validate(), widget.hotelModel!.longitude.validate());
      descriptionController.text = widget.hotelModel!.description.validate();
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
print(res.body);
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
    HotelModel hotelModel = HotelModel();

    hotelModel.name = hotelNameController.text.trim();
    hotelModel.email = emailController.text.trim();
    hotelModel.updatedAt = DateTime.now();
    hotelModel.status = status;
    hotelModel.address = placeAddressController.text.trim();
    hotelModel.latitude = double.parse(latLng!.latitude.toStringAsFixed(5));
    hotelModel.longitude = double.parse(latLng!.longitude.toStringAsFixed(5));
    hotelModel.placeId = placeId;
    hotelModel.starId = starId;
    hotelModel.distance = distanceController.text.toDouble();
    hotelModel.caseSearch = hotelNameController.text.trim().setSearchParam();
    hotelModel.description = descriptionController.text.trim();
    hotelModel.favourites = 0;
    hotelModel.rating = 0;

    if (isUpdate) {
      if (!widget.isRequestPlace) {
        hotelModel.id = widget.hotelModel!.id;
      }else{
        hotelModel.userId = widget.hotelModel!.userId;
      }
      hotelModel.createdAt = widget.hotelModel!.createdAt;
      hotelModel.image = widget.hotelModel!.image;
      hotelModel.secondaryImages = widget.hotelModel!.secondaryImages;
      hotelModel.favourites = widget.hotelModel!.favourites ?? 0;
      hotelModel.rating = widget.hotelModel!.rating ?? 0;
    } else {
      hotelModel.createdAt = DateTime.now();
    }

    if (primaryImage != null) {
      await uploadFile(bytes: await primaryImage!.readAsBytes(), prefix: mPlacesStoragePath).then((path) async {
        hotelModel.image = path;
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
        hotelModel.secondaryImages = list;
        await addHotel(hotelModel);
      });
    } else {
      await addHotel(hotelModel);
    }
  }

  Future addHotel(HotelModel hotelModel) async {
    if (isUpdate && !widget.isRequestPlace) {
      await hotelService.updateDocument(hotelModel.toJson(), hotelModel.id).then((value) {
        appStore.setLoading(false);
        toast("Hotel updated successfully");
        appStore.setMenuIndex(HOTEL_INDEX);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      await signUpHotelWithEmail(hotelModel: hotelModel, password: passwordController.text).then((value) {
        appStore.setLoading(false);
        toast("Hotel Added");
        appStore.setMenuIndex(HOTEL_INDEX);
      },);
      //     .catchError((e) {
      //   appStore.setLoading(false);
      //   toast(e.toString());
      // });

      // await hotelService.addDocument(hotelModel.toJson()).then((value) {
      //   appStore.setLoading(false);
      //   if(widget.isRequestPlace){
      //     requestPlaceService.removeDocument(widget.hotelModel!.id);
      //   }
      //   toast(language.placeAdded);
      //   appStore.setMenuIndex(HOTEL_INDEX);
      //   // if (getBoolAsync(IS_NOTIFICATION_ON, defaultValue: defaultIsNotificationOn)) {
      //   //   String catName = categoryList.firstWhere((element) => element.id == hotelModel.categoryId).name ?? "";
      //   //   sendPushNotifications(parseHtmlString(hotelModel.name), parseHtmlString(catName), id: value.id, image: hotelModel.image.validate());
      //   // }
      // })
      //     .catchError((e) {
      //   appStore.setLoading(false);
      //   toast(e.toString());
      // });
    }
  }

  Widget headingWidget() {
    return Text("Upload Hotel", style: boldTextStyle(size: 20, color: primaryColor));
  }

  Widget getPrimaryImage() {
    if (primaryImage != null) {
      return Image.network(primaryImage!.path, height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center);
    } else if (isUpdate && widget.hotelModel!.image.validate().isNotEmpty) {
      return cachedImage(widget.hotelModel!.image.validate(), height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center);
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
    } else if (isUpdate && (widget.hotelModel!.secondaryImages ?? []).isNotEmpty) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: widget.hotelModel!.secondaryImages!.map((image) {
          return Stack(
            children: [
              cachedImage(image, height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center),
              Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.highlight_remove, color: Colors.white).onTap(() async {
                    widget.hotelModel!.secondaryImages!.remove(image);
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
                              Text("Hotel Name", style: primaryTextStyle()),
                              8.height,
                              AppTextField(
                                controller: hotelNameController,
                                autoFocus: false,
                                textFieldType: TextFieldType.NAME,
                                keyboardType: TextInputType.name,
                                errorThisFieldRequired: language.errorThisFieldIsRequired,
                                decoration: commonInputDecoration(hintText: "Hotel Name"),
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
                              Text("Hotel Email", style: primaryTextStyle()),
                              8.height,
                              AppTextField(
                                controller: emailController,
                                autoFocus: false,
                                textFieldType: TextFieldType.EMAIL,
                                errorThisFieldRequired: language.errorThisFieldIsRequired,
                                decoration: commonInputDecoration(  hintText: language.email,
                                  prefixIcon: Icon(Icons.email),),
                              ),
                            ],
                          ).expand(),
                          24.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hotel Password", style: primaryTextStyle()),
                              8.height,
                              AppTextField(
                                controller: passwordController,
                                autoFocus: false,
                                textFieldType: TextFieldType.PASSWORD,
                                errorThisFieldRequired: language.errorThisFieldIsRequired,
                                decoration: commonInputDecoration(  hintText: language.password,
                                  prefixIcon: Icon(Icons.lock),),
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
                              Text("Place", style: primaryTextStyle()),
                              8.height,
                              placeList.isNotEmpty
                                  ? DropdownButtonFormField<String>(
                                      dropdownColor: Theme.of(context).cardColor,
                                      value: placeId,
                                      decoration: commonInputDecoration(),
                                      items: placeList.map<DropdownMenuItem<String>>((item) {
                                        return DropdownMenuItem(
                                          value: item.id,
                                          child: Text(item.name.validate(), style: primaryTextStyle()),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        placeId = value!;
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
                              Text("Rating", style: primaryTextStyle()),
                              8.height,
                              starList.isNotEmpty
                                  ? DropdownButtonFormField<String>(
                                      dropdownColor: Theme.of(context).cardColor,
                                      value: starId,
                                      decoration: commonInputDecoration(),
                                      items: starList.map<DropdownMenuItem<String>>((item) {
                                        return DropdownMenuItem(
                                          value: item,
                                          child: Text(item, style: primaryTextStyle(size: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        starId = value!;
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
                              RichText(
                                text: TextSpan(
                                  text: "Hotel Address",
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
                                          } else if (isUpdate && widget.hotelModel!.image != null) {
                                            widget.hotelModel!.image = null;
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
                                          } else if (isUpdate && widget.hotelModel!.secondaryImages != null) {
                                            widget.hotelModel!.secondaryImages = [];
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
                      Row(
                        children: [
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Distance From Place", style: primaryTextStyle()),
                          8.height,
                          AppTextField(
                            controller: distanceController,
                            autoFocus: false,
                            textFieldType: TextFieldType.NAME,
                            keyboardType: TextInputType.name,
                            errorThisFieldRequired: language.errorThisFieldIsRequired,
                            decoration: commonInputDecoration(hintText: "Distance from Place"),
                          ),
                        ],
                      ).expand(),24.width,
                          SizedBox().expand()
                        ],
                      ),
                      24.height,

                      Align(
                          alignment: Alignment.center,
                          child: dialogPrimaryButton(widget.isRequestPlace ? language.approve : isUpdate ? language.update :language.save, () {
                            if (formKey.currentState!.validate()) {
                              if (latLng == null) return toast(language.pleaseEnterValidAddress);
                              if (primaryImage != null || (isUpdate && widget.hotelModel!.image != null)) {
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
