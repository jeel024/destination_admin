import '../utils/AppConstant.dart';
import '../utils/Extensions/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../main.dart';
import '../services/AuthServices.dart';
import '../utils/AppColor.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/text_styles.dart';

class ChangePasswordDialog extends StatefulWidget {
  static String tag = '/ChangePasswordDialog';

  @override
  ChangePasswordDialogState createState() => ChangePasswordDialogState();
}

class ChangePasswordDialogState extends State<ChangePasswordDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future submit() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      if (oldPassController.text.trim() != getStringAsync(USER_PASSWORD)) return toast(language.oldPasswordIsWrong);
      finish(context);
      appStore.setLoading(true);
      await changePassword(newPassController.text.trim()).then((value) async {
        appStore.setLoading(false);
        toast(language.passwordChanged);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
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
            Text(language.changePassword, style: boldTextStyle(color: primaryColor, size: 20)),
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
            Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.oldPassword, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: oldPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: oldPassFocus,
                      nextFocus: newPassFocus,
                      decoration: commonInputDecoration(prefixIcon: Icon(Icons.lock), hintText: language.oldPassword),
                      errorThisFieldRequired: language.errorThisFieldIsRequired,
                    ),
                    SizedBox(height: 16),
                    Text(language.newPassword, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: newPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: newPassFocus,
                      nextFocus: confirmPassFocus,
                      decoration: commonInputDecoration(prefixIcon: Icon(Icons.lock), hintText: language.newPassword),
                      errorThisFieldRequired: language.errorThisFieldIsRequired,
                    ),
                    SizedBox(height: 16),
                    Text(language.confirmPassword, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: confirmPassController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: confirmPassFocus,
                      decoration: commonInputDecoration(prefixIcon: Icon(Icons.lock), hintText: language.confirmPassword),
                      validator: (val) {
                        if (val!.isEmpty) return language.errorThisFieldIsRequired;
                        if (val != newPassController.text) return language.passwordNotMatch;
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
          ],
        ),
      ),
      actions: <Widget>[
        dialogSecondaryButton(language.cancel, () {
          Navigator.pop(context);
        }),
        SizedBox(width: 4),
        dialogPrimaryButton(language.submit, () {
          if (getBoolAsync(IS_DEMO_ADMIN)) {
            return toast(language.demoAdminMsg);
          } else {
            submit();
          }
        }),
      ],
    );
  }
}
