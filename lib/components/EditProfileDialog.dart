import 'dart:typed_data';
import '../services/FileStorageService.dart';
import '../utils/AppConstant.dart';
import '../utils/ModelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../utils/AppColor.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';

class EditProfileDialog extends StatefulWidget {
  static String tag = '/EditProfileDialog';

  @override
  EditProfileDialogState createState() => EditProfileDialogState();
}

class EditProfileDialogState extends State<EditProfileDialog> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String countryCode = '+91';

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  XFile? imageProfile;
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    emailController.text = getStringAsync(USER_EMAIL);
    nameController.text = getStringAsync(USER_NAME);
    contactNumberController.text = getStringAsync(USER_CONTACT_NO);
  }

  Widget profileImage() {
    if (image != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.memory(image!, height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center));
    } else {
      if (appStore.userProfile.isNotEmpty) {
        return ClipRRect(borderRadius: BorderRadius.circular(50), child: cachedImage(appStore.userProfile, fit: BoxFit.cover, height: 100, width: 100));
      } else {
        return Padding(
          padding: EdgeInsets.only(right: 4, bottom: 4),
          child: ClipRRect(borderRadius: BorderRadius.circular(50), child: cachedImage('assets/profile.png', height: 100, width: 100)),
        );
      }
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    image = await imageProfile!.readAsBytes();
    setState(() {});
  }

  Future<void> save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      hideKeyboard(context);

      finish(context);
      appStore.setLoading(true);

      Map<String, dynamic> req = {};

      if (nameController.text != getStringAsync(USER_NAME)) {
        req.putIfAbsent(UserKeys.name, () => nameController.text.trim());
      }

      if (contactNumberController.text != getStringAsync(USER_CONTACT_NO)) {
        req.putIfAbsent(UserKeys.contactNo, () => contactNumberController.text.trim());
      }

      req.putIfAbsent(CommonKeys.updatedAt, () => DateTime.now());

      if (image != null) {
        await uploadFile(bytes: image, prefix: mProfileStoragePath).then((path) async {
          req.putIfAbsent(UserKeys.profileImg, () => path);

          await setValue(USER_PROFILE, path);
          appStore.setUserProfile(path);
        }).catchError((e) {
          toast(e.toString());
        });
      }

      await userService.updateDocument(req, getStringAsync(USER_ID)).then((value) async {
        appStore.setLoading(false);
        setValue(USER_NAME, nameController.text.trim());
        setValue(USER_CONTACT_NO, contactNumberController.text.trim());
      }).catchError((e) {
        appStore.setLoading(false);
        throw e;
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.only(right: 16, bottom: 16),
      titlePadding: EdgeInsets.zero,
      title: Container(
        color: primaryColor.withOpacity(0.1),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.editProfile, style: boldTextStyle(color: primaryColor, size: 20)),
            IconButton(
              icon: Icon(Icons.close),
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 500,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Center(child: profileImage()),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 60, left: 80),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: primaryColor),
                            child: IconButton(
                              onPressed: () {
                                getImage();
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 50),
                    Text(language.email, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    AppTextField(
                      readOnly: true,
                      controller: emailController,
                      textFieldType: TextFieldType.EMAIL,
                      focus: emailFocus,
                      nextFocus: usernameFocus,
                      decoration: commonInputDecoration(prefixIcon: Icon(Icons.email), hintText: language.email),
                      onTap: () {
                        toast(language.youCannotChangeEmailId);
                      },
                    ),
                    SizedBox(height: 16),
                    Text(language.name, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: nameController,
                      textFieldType: TextFieldType.NAME,
                      focus: nameFocus,
                      nextFocus: addressFocus,
                      decoration: commonInputDecoration(prefixIcon: Icon(Icons.person), hintText: language.name),
                      errorThisFieldRequired: language.errorThisFieldIsRequired,
                    ),
                    SizedBox(height: 16),
                    Text(language.contactNumber, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: contactNumberController,
                      textFieldType: TextFieldType.PHONE,
                      focus: contactFocus,
                      nextFocus: addressFocus,
                      decoration: commonInputDecoration(prefixIcon: Icon(Icons.phone), hintText: language.contactNumber),
                      validator: (s) {
                        if (s!.trim().isEmpty) return language.errorThisFieldIsRequired;
                        if (s.trim().length < 10 && s.trim().length > 14) return '';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
          ],
        ),
      ),
      actions: <Widget>[
        dialogSecondaryButton(language.cancel, () {
          Navigator.pop(context);
        }),
        SizedBox(width: 4),
        dialogPrimaryButton(language.submit, () {
          if (_formKey.currentState!.validate()) {
            if (getBoolAsync(IS_DEMO_ADMIN)) {
              return toast(language.demoAdminMsg);
            }else {
              save();
            }
          }
        }),
      ],
    );
  }
}
