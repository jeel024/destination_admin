import '../main.dart';
import '../utils/Extensions/int_extensions.dart';
import 'package:flutter/material.dart';

import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';

class ForgotPasswordDialog extends StatefulWidget {
  static String tag = '/ForgotPasswordDialog';

  @override
  ForgotPasswordDialogState createState() => ForgotPasswordDialogState();
}

class ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      finish(context);
      appStore.setLoading(true);
      if (await userService.isUserExist(forgotEmailController.text, LoginTypeApp)) {
        await auth.sendPasswordResetEmail(email: forgotEmailController.text).then((value) {
          toast('${language.resetEmailSentTo} ${forgotEmailController.text}');
          appStore.setLoading(false);
        }).catchError((e) {
          toast(e.toString());
          appStore.setLoading(false);
        });
      } else {
        toast(language.noUserFound);
        appStore.setLoading(false);
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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
            Text(language.forgotPassword, style: boldTextStyle(color: primaryColor, size: 20)),
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
          width: 400,
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.forgotPasswordMsg, style: secondaryTextStyle(size: 16)),
                    30.height,
                    Text(language.email, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: forgotEmailController,
                      autoFocus: false,
                      textFieldType: TextFieldType.EMAIL,
                      keyboardType: TextInputType.emailAddress,
                      decoration: commonInputDecoration(hintText: language.email, prefixIcon: Icon(Icons.email)),
                      errorThisFieldRequired: language.errorThisFieldIsRequired,
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
