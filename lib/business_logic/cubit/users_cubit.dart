import 'package:Prefer/data/apis/users_apis.dart';
import 'package:Prefer/data/models/user.dart';
import 'package:bloc/bloc.dart';
import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/data/models/user.dart';
import 'package:Prefer/data/repos/users_repo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Prefer/constants/globals.dart' as globals;
part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final usersRepo usersrepo;
  usersApis usersapi = new usersApis();
  List<User> users = [];
  User user = User();

  UsersCubit(this.usersrepo) : super(UsersInitial());

  List<User> getAllUsers() {
    usersrepo.getAllUsers().then((users) {
      emit(usersLoaded(users));
      this.users = users;
    });
    return users;
  }

  getUserbyID(id) {
    usersrepo.getUserbyID(id).then((user) {
      globals.main_user = user;
    });
  }

  dynamic Sign_up(
      username, password, phone_number, birthdate, gender, promovalid,
      {amount: 0}) {
    emit(userloading(true));
    usersrepo.Sign_up(
            username, password, phone_number, birthdate, gender, amount)
        .then((user) async {
      if (user.error == null) {
        await delete_all_prefs(user.sId);

        await getUserbyID(user.sId);
        await change_first();
        await save_id_stay_signed(user.sId);
        get_all_prefs(user.sId);
        if (promovalid) {
          emit(usersignupcompleteWithPromo(user, true, amount));
        } else {
          emit(usersignupcomplete(user, true));
        }
        this.user = user;
      } else {
        emit(usersignuperror(user.error, false, false));
      }
    });
    return user;
  }

  dynamic Sign_in(
    username,
    password,
  ) {
    emit(userloading(true));
    usersrepo.Sign_in(
      username,
      password,
    ).then((user) async {
      if (user.error == null) {
        await delete_all_prefs(user.sId);
        await getUserbyID(user.sId);
        await change_first();
        await save_id_stay_signed(user.sId);
        get_all_prefs(user.sId);
        final fcmToken = await FirebaseMessaging.instance.getToken();
        await usersapi.updateFCM(fcmToken);
        emit(usersignincomplete(user, true));
        this.user = user;
      } else {
        emit(usersigninerror(user.error, false, false));
      }
    });
    return user;
  }

  Future<bool> check_first() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? first = prefs.getBool('first');
    if (first == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> change_first() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first', false);
  }

  Future<bool> check_signed() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? first = prefs.getBool('signed');
    if (first == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> save_id_stay_signed(id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('signed', true);
    await prefs.setString('id', id);
  }

  Future<void> change_signed_false() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('signed', false);
  }

  Future<void> get_all_prefs(id) async {
    final prefs = await SharedPreferences.getInstance();
    var signed = await prefs.getBool('signed');
    var first = await prefs.getBool('first');
    var saved_id = await prefs.getString('id');
  }

  Future<void> delete_all_prefs(id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
  }

  Future<void> save_tokens_to_globals() async {
    final prefs = await SharedPreferences.getInstance();
    var saved_acctoken = await prefs.get('acc_token');
    acctoken = saved_acctoken.toString();
    var saved_reftoken = await prefs.get('ref_token');
    reftoken = saved_reftoken.toString();
  }

  Future<dynamic> get_profile_Numbers(id) async {
    usersrepo.get_profile_Numbers(id).then((values) => {
          if (values.length == 0)
            {
              emit(numbersloaded([0, 0]))
            }
          else
            {emit(numbersloaded(values))}
        });
  }

  Future<dynamic> check_promo(
    promocode,
  ) async {
    usersrepo
        .check_promo(
          promocode,
        )
        .then((result) => {
              if (result != null)
                {emit(promocode_valid(result))}
              else
                {emit(promocode_notvalid())}
            });
  }
}
