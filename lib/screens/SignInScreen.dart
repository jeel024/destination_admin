import '../utils/Common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../components/ForgotPasswordDialog.dart';
import '../utils/Extensions/AppButton.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/AppColor.dart';
import '../utils/AppImages.dart';
import '../main.dart';
import 'DashboardScreen.dart';

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';
  final bool isDashboard;

  SignInScreen({this.isDashboard = false});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  GlobalKey<FormState> signInformKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode passFocus = FocusNode();


  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    saveFcmTokenId();
  }

  Future<void> signIn() async {
    print("object1234567object1234567");
    DashboardScreen().launch(context, isNewTask: true);

//     hideKeyboard(context);
//     if (signInformKey.currentState!.validate()) {
//       signInformKey.currentState!.save();
//       appStore.setLoading(true);
//
//       signInWithEmail(emailController.text, passwordController.text).then((user) {
//         appStore.setLoading(false);
// print("object1234567");
//         if (user.isAdmin.validate()) {
//           print("object1234567");
//
//           DashboardScreen().launch(context, isNewTask: true);
//         } else {
//           print("vfkjjbfdbfdbd");
//           toast(language.notAllowed);
//         }
//       })/*.catchError((e) {
//         toast(e.toString().splitAfter(']'));
//         appStore.setLoading(false);
//       })*/;
//     }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor
             //   image: DecorationImage(image: AssetImage(login_bg), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Container( height: 250, width: 250,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),image: DecorationImage(image: AssetImage(login), fit: BoxFit.cover)),),
                   // child: Image.asset(login, fit: BoxFit.cover, height: 250, width: 250,),
                  ),
                ],
              )
            ),
          ),
          Expanded(flex: 5,
            child: Container(
              padding: EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 16),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  SingleChildScrollView(
                    child: Form(
                      key: signInformKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.signIn, style: boldTextStyle(size: 30)),
                          SizedBox(height: 16),
                          Text(language.signInToYourAccount, style: secondaryTextStyle(size: 16)),
                          SizedBox(height: 50),
                          Text(language.email, style: primaryTextStyle()),
                          8.height,
                          AppTextField(
                            controller: emailController,
                            nextFocus: passFocus,
                            autoFocus: false,
                            textFieldType: TextFieldType.EMAIL,
                            keyboardType: TextInputType.emailAddress,
                            errorThisFieldRequired: errorThisFieldRequired,
                            decoration: commonInputDecoration(hintText: language.email, prefixIcon: Icon(Icons.email)),
                          ),
                          30.height,
                          Text(language.password, style: primaryTextStyle()),
                          8.height,
                          AppTextField(
                            controller: passwordController,
                            focus: passFocus,
                            textFieldType: TextFieldType.PASSWORD,
                            keyboardType: TextInputType.visiblePassword,
                            validator: (String? value) {
                              if (value.validate().isEmpty) return errorThisFieldRequired;
                              return null;
                            },
                            decoration: commonInputDecoration(hintText: language.password, prefixIcon: Icon(Icons.lock)),
                            onFieldSubmitted: (c) {
                              signIn();
                            },
                          ),
                          50.height,
                          AppButtonWidget(
                            height: 50,
                            text: language.signIn,
                            textStyle: boldTextStyle(color: whiteColor),
                            color: primaryColor,
                            shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
                            onTap: () {
                              signIn();
                            },
                            width: context.width(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext dialogContext) {
                              return ForgotPasswordDialog();
                            },
                          );
                        },
                        child: Text(language.forgotPasswordQue, style: primaryTextStyle(color: primaryColor))),
                  ),
                  Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
