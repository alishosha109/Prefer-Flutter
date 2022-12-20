import 'package:Prefer/app_localizations.dart';
import 'package:Prefer/business_logic/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:Prefer/business_logic/cubit/users_cubit.dart';
import 'package:Prefer/constants/globals.dart';
import 'package:Prefer/constants/my_colors.dart';
import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/data/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Prefer/presentation/screens/home_page.dart';
import 'package:Prefer/presentation/screens/login_page.dart';
import 'package:Prefer/constants/globals.dart' as globals;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gender_picker/gender_picker.dart';
import 'package:gender_picker/source/enums.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool show_pass = false;
  var pass1;
  var username;
  var promocode;
  var phone_number;
  var birthdate;
  var choosed_gender = "male";
  late User user;
  var signed;
  var loading = false;
  var error_message = "";
  bool isInteger(num value) => value is int || value == value.roundToDouble();

  promoCode_dialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: globals.theme_mode == ThemeMode.dark
            ? Colors.black87
            : Colors.white,
        content: Text(
          AppLocalizations.of(context)!
              .translate("Promo code is not valid, Do you wish to continue?"),
          style: TextStyle(
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              color: Color(0xffA9A9A9),
              padding: const EdgeInsets.all(14),
              child: Text(
                AppLocalizations.of(context)!.translate("No"),
                style: TextStyle(color: MyColors.mywhite),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<UsersCubit>(context).Sign_up(
                username,
                pass1,
                phone_number,
                birthdate.toString(),
                choosed_gender,
                false,
              );
            },
            child: Container(
              color: MyColors.myRed,
              padding: const EdgeInsets.all(14),
              child: Text(
                AppLocalizations.of(context)!.translate("Yes"),
                style: TextStyle(color: MyColors.mywhite),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bloc_child_widget() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ClipPath(
              clipper: WaveClipperTwo(),
              child: Container(
                //color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                      image: AssetImage('assets/images/900.png'),
                      fit: BoxFit.cover),
                ),
                child: Stack(children: [
                  Positioned(
                      left: MediaQuery.of(context).size.width * 0.075,
                      bottom: MediaQuery.of(context).size.height * 0.03,
                      child: Text(
                        AppLocalizations.of(context)!.translate('SignUp'),
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                            fontSize: 28.0,
                            letterSpacing: 1.5,
                            color: Colors.white),
                      )),
                ]),
              ),
            ),
            // SizedBox(
            //   height: MediaQuery.of(context).size.height * 0.01,
            // ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.black),
                  onSaved: (value) {
                    username = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .translate('Username can\'t be empty');
                    } else if (value.length < 8) {
                      return AppLocalizations.of(context)!
                          .translate('Username must be more than 8 characters');
                    } else if (value.contains(" ")) {
                      return AppLocalizations.of(context)!
                          .translate("Username can't contain spaces");
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.translate("Username"),
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.black,
                      )),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.black),
                  onSaved: (value) {
                    phone_number = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .translate('Phone number can\'t be empty');
                    } else if (value.length < 11) {
                      return AppLocalizations.of(context)!
                          .translate('Enter correct phone number');
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!
                          .translate("Phone Number"),
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.black,
                      )),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                ),
                InkWell(
                  onTap: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(1922, 1, 1),
                        maxTime: DateTime(2014, 12, 31), onChanged: (date) {
                      print('change $date');
                    }, onConfirm: (date) {
                      setState(() {
                        birthdate = date;
                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        )),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 3.0),
                                child: Icon(
                                  Icons.date_range,
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate("BirthDate"),
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          birthdate == null
                              ? Text(
                                  AppLocalizations.of(context)!
                                      .translate('Choose Birth Date'),
                                  style: TextStyle(
                                      fontSize: 14, color: MyColors.myRed),
                                )
                              : Text(
                                  '${birthdate.toString().substring(0, 11)}',
                                  style: TextStyle(
                                      fontSize: 14, color: MyColors.myRed),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.black),
                  onSaved: (value) {
                    pass1 = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .translate('Passowrd can\'t be empty');
                    } else if (value.length < 8) {
                      return AppLocalizations.of(context)!
                          .translate('Password must be more than 8 characters');
                    }
                    pass1 = value;

                    return null;
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      hintText:
                          AppLocalizations.of(context)!.translate("Password"),
                      suffixIcon: show_pass == true
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  show_pass = false;
                                });
                              },
                              child: Icon(
                                Icons.visibility,
                                color: Colors.black,
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  show_pass = true;
                                });
                              },
                              child: Icon(
                                Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.black,
                      )),
                  obscureText: show_pass == true ? false : true,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value != pass1) {
                      return AppLocalizations.of(context)!
                          .translate('Passwords doesn\'t match');
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      hintText: AppLocalizations.of(context)!
                          .translate("Repeat Password"),
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                      suffixIcon: show_pass == true
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  show_pass = false;
                                });
                              },
                              child: Icon(
                                Icons.visibility,
                                color: Colors.black,
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  show_pass = true;
                                });
                              },
                              child: Icon(
                                Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.black,
                      )),
                  obscureText: show_pass == true ? false : true,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(color: Colors.black),
                  onSaved: (value) {
                    promocode = value;
                  },
                  decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.translate("Promo Code"),
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      prefixIcon: Icon(
                        Icons.subscriptions,
                        color: Colors.black,
                      )),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: GenderPickerWithImage(
                    verticalAlignedText: false,
                    maleText: AppLocalizations.of(context)!.translate("Male"),
                    femaleText:
                        AppLocalizations.of(context)!.translate("Female"),
                    selectedGender: Gender.Male,

                    selectedGenderTextStyle: TextStyle(
                        color: MyColors.myRed, fontWeight: FontWeight.bold),
                    unSelectedGenderTextStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal),
                    onChanged: (Gender? gender) {
                      if (gender == Gender.Male) {
                        choosed_gender = "male";
                      } else {
                        choosed_gender = "female";
                      }
                    },
                    equallyAligned: true,
                    animationDuration: Duration(milliseconds: 300),
                    isCircular: true,
                    // default : true,
                    opacityOfGradient: 0.2,
                    // padding: const EdgeInsets.all(3),
                    size: 50, //default : 40
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                GestureDetector(
                  onTap: loading == false
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            if (birthdate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 3),
                                  content: Text(AppLocalizations.of(context)!
                                      .translate("Please choose a birthdate")),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            } else {
                              _formKey.currentState!.save();
                              BlocProvider.of<UsersCubit>(context).check_promo(
                                promocode,
                              );
                            }
                          }
                        }
                      : null,
                  child: loading == false
                      ? Container(
                          height: 50,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Color(0xFFE60023),
                                    Color(0xFFE60023),
                                  ]),
                              borderRadius: BorderRadius.circular(50.0)),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.translate('SignUp'),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 18.0),
                          )),
                        )
                      : CircularProgressIndicator(
                          color: MyColors.myRed,
                        ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(loginScreen);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .translate('Already have an account? '),
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      Text(
                        AppLocalizations.of(context)!.translate('Just Login!'),
                        style: TextStyle(
                            color: MyColors.myRed,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  height: 40,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyColors.myRed, //<-- SEE HERE
                  ),
                  child: BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      return DropdownButton<String>(
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        value: globals.locale.languageCode == "en"
                            ? "English"
                            : "عربي",
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: ['عربي', 'English'].map((String items) {
                          return DropdownMenuItem<String>(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            if (newValue == "English") {
                              BlocProvider.of<ThemeCubit>(context)
                                  .changeLanguage("en");
                            } else {
                              BlocProvider.of<ThemeCubit>(context)
                                  .changeLanguage("ar");
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget buildblocWidget() {
    return BlocConsumer<UsersCubit, UsersState>(
        listener: (context, state) async {
      if (state is usersignupcomplete) {
        await determinePosition();
        globals.save_tokens_to_globals();
        globals.saveUser();
        globals.usertype = "user";
        // Navigator.of(context)
        //     .pushReplacementNamed(homePageScreen, arguments: "user");
        Navigator.pushReplacementNamed(
          context,
          homePageScreen,
        );
      }
      if (state is usersignupcompleteWithPromo) {
        await determinePosition();
        globals.save_tokens_to_globals();
        globals.saveUser();
        globals.usertype = "user";
        // Navigator.of(context)
        //     .pushReplacementNamed(homePageScreen, arguments: "user");
        Navigator.pushReplacementNamed(
          context,
          homePageScreen,
        );
      }
      if (state is usersignuperror) {
        signed = (state).signed;
        error_message = (state).message;
        loading = state.loading;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
      if (state is userloading) {
        loading = state.loading;
      }
      if (state is promocode_valid) {
        BlocProvider.of<UsersCubit>(context).Sign_up(username, pass1,
            phone_number, birthdate.toString(), choosed_gender, true,
            amount: state.amount);
      }
      if (state is promocode_notvalid) {
        promoCode_dialog();
      }
    }, builder: (context, state) {
      return bloc_child_widget();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: buildblocWidget());
  }
}
