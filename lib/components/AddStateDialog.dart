import '../main.dart';
import '../models/StateModel.dart';
import '../models/models.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/AppButton.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/FileStorageService.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';

class AddStateDialog extends StatefulWidget {
  static String tag = '/AddStateDialog';
  final StateModel? stateData;
  final Function()? onUpdate;

  AddStateDialog({this.stateData, this.onUpdate});

  @override
  AddStateDialogState createState() => AddStateDialogState();
}

class AddStateDialogState extends State<AddStateDialog> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController nameController = TextEditingController();

  List<StatusModel> statusList = getStatusList();
  int status = 1;

  bool isUpdate = false;

  XFile? image;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.stateData != null;
    if (isUpdate) {
      nameController.text = widget.stateData!.name.validate();
      status = widget.stateData!.status.validate(value: 1);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  save() async {
    finish(context);
    appStore.setLoading(true);
    StateModel stateModel = StateModel();
    stateModel.name = nameController.text.validate();
    stateModel.status = status;
    stateModel.updatedAt = DateTime.now();

    if (isUpdate) {
      stateModel.id = widget.stateData!.id;
      stateModel.createdAt = widget.stateData!.createdAt;
      stateModel.image = widget.stateData!.image;
    } else {
      stateModel.createdAt = DateTime.now();
    }

    if (image != null) {
      await uploadFile(bytes: await image!.readAsBytes(), prefix: mStateStoragePath).then((path) async {
        stateModel.image = path;
      }).catchError((e) {
        toast(e.toString());
      });
    }

    if (isUpdate) {
      await stateService.updateDocument(stateModel.toJson(), stateModel.id).then((value) {
        appStore.setLoading(false);
        widget.onUpdate!.call();
        toast(language.stateUpdated);
      }).catchError((e) {
        toast(e.toString());
      });
    } else {
      await stateService.addDocument(stateModel.toJson()).then((value) {
        appStore.setLoading(false);
        1.seconds.delay;
        widget.onUpdate!.call();
        toast(language.stateAdded);
      }).catchError((e) {
        toast(e.toString());
      });
    }
  }

  Widget getImage() {
    if (image != null) {
      return Image.network(image!.path, height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center);
    } else if (isUpdate && widget.stateData!.image.validate().isNotEmpty) {
      return cachedImage(widget.stateData!.image.validate(), height: 130, width: 130, fit: BoxFit.cover, alignment: Alignment.center);
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.all(16),
      titlePadding: EdgeInsets.zero,
      title: Container(
        color: primaryColor.withOpacity(0.1),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.addState, style: boldTextStyle(color: primaryColor, size: 20)),
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
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.name, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: nameController,
                      autoFocus: false,
                      textFieldType: TextFieldType.NAME,
                      keyboardType: TextInputType.name,
                      decoration: commonInputDecoration(hintText: language.name),
                      errorThisFieldRequired: language.errorThisFieldIsRequired,
                    ),
                    16.height,
                    Text(language.status, style: primaryTextStyle()),
                    SizedBox(height: 8),
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
                    16.height,
                    Text(language.image, style: primaryTextStyle()),
                    8.height,
                    Container(
                      height: 150,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: radius(defaultRadius),
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getImage().center().expand(),
                          AppButtonWidget(
                            child: Text(language.browse, style: primaryTextStyle(color: Colors.white)),
                            color: primaryColor.withOpacity(0.5),
                            elevation: 0,
                            onTap: () async {
                              image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
                              setState(() {});
                            },
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        dialogSecondaryButton(language.cancel, () {
          Navigator.pop(context);
        }),
        SizedBox(width: 4),
        dialogPrimaryButton(language.submit, () {
          if (formKey.currentState!.validate()) {
            if (image != null || (isUpdate && widget.stateData!.image!.isNotEmpty)) {
              if (getBoolAsync(IS_DEMO_ADMIN)) {
                return toast(language.demoAdminMsg);
              } else {
                save();
              }
            } else {
              toast(language.pleaseSelectImage);
            }
          }
        }),
      ],
    );
  }
}
