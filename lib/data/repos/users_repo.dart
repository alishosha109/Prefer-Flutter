import 'package:get/get.dart';
import 'package:Prefer/constants/globals.dart';
import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/data/apis/users_apis.dart';
import 'package:Prefer/data/models/user.dart';

class usersRepo {
  final usersApis usersapis;

  usersRepo(this.usersapis);

  Future<List<User>> getAllUsers() async {
    final users = await usersapis.getAllUsers();
    return users.map((user) => User.fromJson(user)).toList();
  }

  Future<dynamic> Sign_up(
      username, password, phone_number, birthdate, gender) async {
    var response = await usersapis.Sign_up(
        username, password, phone_number, birthdate, gender);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var access_t = response.data['token'];
      var refresh_t = reftoken = response.data['refresh'];
      save_acctoken_reftoken(access_t, refresh_t);
      return User.fromJson(response.data['user']);
    } else {
      return User.withError(response.data['error']);
    }
  }

  Future<dynamic> Sign_in(username, password) async {
    var response = await usersapis.Sign_in(username, password);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var access_t = response.data['token'];
      var refresh_t = reftoken = response.data['refresh'];
      save_acctoken_reftoken(access_t, refresh_t);
      return User.fromJson(response.data['user']);
    } else {
      return User.withError(response.data['error']);
    }
  }

  Future<dynamic> getUserbyID(id) async {
    var response = await usersapis.getUserbyID(id);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(response.data['User']);
    } else {
      return User.withError("No exisiting user for this ID");
    }
  }

  Future<dynamic> get_profile_Numbers(id) async {
    var response = await usersapis.get_profile_Numbers(id);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return [response.data['total_answers'], response.data['choices_history']];
    } else {
      return [];
    }
  }
}
