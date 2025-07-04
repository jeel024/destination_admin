import 'package:destination_admin/models/hotel_model.dart';

import '../screens/SignInScreen.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/ModelKeys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/UserModel.dart';
import '../utils/AppConstant.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/shared_pref.dart';

Future<UserModel> signInWithEmail(String email, String password) async {
  if (/*await userService.isUserExist(email, LoginTypeApp)*/true) {
    UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
    print(userCredential.user?.email);
  //  return UserModel();
    if (userCredential.user != null) {
      UserModel userModel = UserModel();

      User user = userCredential.user!;

      return await userService.userByEmail(user.email).then((value) async {
        userModel = value;

        await setValue(USER_PASSWORD, password);
        await setValue(LOGIN_TYPE, LoginTypeApp);
        //
        await updateUserData(userModel);
        //
        await setUserDetailPreference(userModel);

        return userModel;
      })/*.catchError((e) {
        throw e;
      })*/;
    } else {
      print("object");
      throw errorSomethingWentWrong;
    }
  } else {
    print("object");

return UserModel();    throw language.youAreNotRegisteredWithUs;
  }
}
Future<void> signUpHotelWithEmail({required HotelModel hotelModel,  required String password}) async {
  UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: hotelModel.email!, password: password);

print(userCredential.user?.email ?? "ff");
  if (userCredential.user != null) {
    User currentUser = userCredential.user!;

    hotelModel.id = currentUser.uid;

    await hotelService.addDocumentWithCustomId(currentUser.uid, hotelModel.toJson()).catchError((e) {
      throw e;
    });
  } else {
    throw errorSomethingWentWrong;
  }
}


Future<void> updateUserData(UserModel user) async {
  /// Update user data
  userService.updateDocument({
    UserKeys.fcmToken: getStringAsync(FCM_TOKEN),
    CommonKeys.updatedAt: DateTime.now(),
  }, user.id);
}

Future<void> setUserDetailPreference(UserModel userModel) async {
  await setValue(USER_ID, userModel.id);
  await setValue(USER_NAME, userModel.name);
  await setValue(USER_EMAIL, userModel.email);
  await setValue(USER_PROFILE, userModel.profileImg.validate());
  await setValue(IS_ADMIN, userModel.isAdmin.validate());
  await setValue(IS_DEMO_ADMIN, userModel.isDemoAdmin.validate());
  await setValue(IS_LOGGED_IN, userModel.email);

  appStore.setUserProfile(userModel.profileImg.validate());
  appStore.setLoggedIn(true);
}

Future<void> changePassword(String newPassword) async {
  await auth.currentUser!.updatePassword(newPassword).then((value) async {
    await setValue(USER_PASSWORD, newPassword);
  });
}

Future<void> logout(BuildContext context) async {
  await removeKey(USER_ID);
  await removeKey(USER_NAME);
  await removeKey(USER_EMAIL);
  await removeKey(USER_PROFILE);
  await removeKey(IS_ADMIN);
  await removeKey(IS_DEMO_ADMIN);
  await removeKey(IS_LOGGED_IN);
  appStore.setUserProfile('');
  appStore.setLoggedIn(false);
  SignInScreen().launch(context);
}
