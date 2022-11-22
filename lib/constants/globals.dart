import 'package:flutter/material.dart';
import 'package:Prefer/business_logic/cubit/users_cubit.dart';
import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/data/apis/users_apis.dart';
import 'package:Prefer/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Prefer/data/repos/users_repo.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

User main_user = User();
String usertype = "guest";
usersApis userapis = new usersApis();
Locale locale = new Locale("en");

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  var currentlocaion = await Geolocator.getCurrentPosition();
  print(currentlocaion);
  userapis.updateLocationInDB(currentlocaion);
  return currentlocaion;
}

Future<void> delete_all_prefs(id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('signed', false);
  await prefs.remove('id');
}

late var theme_mode;
var initialize = "";
initialize_theme() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString("theme_mode") == "light") {
    theme_mode = ThemeMode.light;
  } else {
    theme_mode = ThemeMode.dark;
  }
}

bool check_ref_token_duration(reftoken) {
  if (reftoken == null || reftoken == "") {
    return true;
  }
  String RefToken = reftoken;
  bool ref_Expired = JwtDecoder.isExpired(RefToken);
  return ref_Expired;
}

Future<void> return_initialize() async {
  await initialize_theme();
  final prefs = await SharedPreferences.getInstance();
  var first = await prefs.getBool('first');
  var signed = await prefs.getBool('signed');
  var reftoken = await prefs.getString('ref_token');
  var theme_mode = await prefs.getString('theme_mode');
  bool refcheck;

  print(reftoken);
  var id = await prefs.getString('id');
  if (reftoken == "" || reftoken == null) {
    refcheck = true;
  } else {
    refcheck = check_ref_token_duration(reftoken);
  }

  if (first == null || first == true) {
    initialize = boardingScreen;
  } else if (first == false && signed == false) {
    initialize = loginScreen;
  } else if (first == false && signed == true) {
    if (refcheck) {
      initialize = loginScreen;
    } else {
      initialize = homePageScreen;
      save_tokens_to_globals();
      saveUser();
      usertype = "user";
    }
  }
}

Future<void> save_acctoken_reftoken(act, reft) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('acc_token', act);
  await prefs.setString('ref_token', reft);
}

Future<void> save_tokens_to_globals() async {
  final prefs = await SharedPreferences.getInstance();
  var saved_acctoken = await prefs.get('acc_token');
  acctoken = saved_acctoken.toString();
  var saved_reftoken = await prefs.get('ref_token');
  reftoken = saved_reftoken.toString();
}

Future<void> delete_acctoken_reftoken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('acc_token');
  await prefs.remove('ref_token');
}

Future<void> saveUser() async {
  final prefs = await SharedPreferences.getInstance();
  var userobj = UsersCubit(usersRepo(usersApis()));
  var savedID = await prefs.get('id');
  if (savedID == null) {
    return;
  }
  if (main_user.sId == null) {
    await userobj.getUserbyID(savedID);
  }
}
