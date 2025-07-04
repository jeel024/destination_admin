import '../main.dart';
import '../screens/DashboardScreen.dart';
import '../screens/SignInScreen.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import 'package:flutter/material.dart';

import '../utils/AppImages.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await 5.seconds.delay;
    if (appStore.isLoggedIn) {
      DashboardScreen().launch(context,isNewTask: true);
    } else {
      SignInScreen().launch(context, isNewTask: true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: boxDecorationRoundedWithShadowWidget(16),
            child: Image.asset(login, fit: BoxFit.cover, height: 250, width: 250),
          ).center(),
        ],
      ),
    );
  }
}
