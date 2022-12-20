import 'package:dio/dio.dart';
import 'package:Prefer/constants/globals.dart';
import 'package:Prefer/constants/strings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class usersApis {
  late Dio dio;

  usersApis() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      receiveDataWhenStatusError: true,
      connectTimeout: 30 * 1000,
      receiveTimeout: 30 * 1000,
      headers: {"authorization": "token ${acctoken}"},
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
    );
    dio = Dio(options);
  }

  Future<List<dynamic>> getAllUsers() async {
    try {
      Response response = await dio.get('users');
      return response.data['Users'];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<dynamic> Sign_up(
      username, password, phone_number, birthdate, gender, amount) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    var response = await dio.post(
      'users/signup',
      data: {
        'username': username,
        'password': password,
        'phone_number': phone_number,
        'birthdate': birthdate,
        'gender': gender,
        'fcm': fcmToken,
        'subscription': amount
      },
    );
    return response;
  }

  Future<dynamic> Sign_in(
    username,
    password,
  ) async {
    var response = await dio.post(
      'users/login',
      data: {
        'username': username,
        'password': password,
      },
    );
    return response;
  }

  Future<dynamic> getUserbyID(id) async {
    var response;
    response = await dio.get('users/${id.toString()}');
    return response;
  }

  Future<dynamic> get_profile_Numbers(id) async {
    var response;
    response = await dio.get('users/profile_numbers/${id.toString()}');
    return response;
  }

  Future<dynamic> updateLocationInDB(currentlocation) async {
    var response;
    response = await dio.patch('users/${main_user.sId}', data: {
      'location': [
        {"lat": currentlocation.latitude.toString()},
        {"long": currentlocation.longitude.toString()}
      ]
    });
    return response;
  }

  Future<dynamic> updateFCM(fcm) async {
    var response;
    response = await dio.patch('users/${main_user.sId}', data: {'fcm': fcm});
    return response;
  }

  Future<dynamic> check_promo(
    promocode,
  ) async {
    var response = await dio.post(
      'promos/checkpromo',
      queryParameters: {
        'code': promocode,
      },
    );
    return response;
  }

  Future<dynamic> update_subscription(
    amount,
    user_id,
  ) async {
    var response = await dio.patch(
      'users/$user_id',
      data: {
        'subscription': amount,
      },
    );
    return response;
  }
}
