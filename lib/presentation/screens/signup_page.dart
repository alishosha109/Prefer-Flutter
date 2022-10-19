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
  var phone_number;
  var birthdate;
  var choosed_gender = "male";
  late User user;
  var signed;
  var loading = false;
  var error_message = "";
  bool isInteger(num value) => value is int || value == value.roundToDouble();
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
                        'SignUp',
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
                      return 'Username can\'t be empty';
                    } else if (value.length < 8) {
                      return 'Username must be more than 8 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Username",
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
                      return 'Phone number can\'t be empty';
                    } else if (value.length < 11) {
                      return 'Enter correct phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Phone Number",
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
                                  "BirthDate",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          birthdate == null
                              ? Text(
                                  'Choose Birth Date',
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
                      return 'Passowrd can\'t be empty';
                    } else if (value.length < 8) {
                      return 'Password must be more than 8 characters';
                    }
                    pass1 = value;

                    return null;
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      hintText: "Password",
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
                      return 'Passwords doesn\'t match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      hintText: "Repeat Password",
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
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: GenderPickerWithImage(
                    verticalAlignedText: false,
                    maleText: "Male",
                    femaleText: "Female",
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
                                  content: Text("Please choose a birthdate"),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            } else {
                              _formKey.currentState!.save();
                              BlocProvider.of<UsersCubit>(context).Sign_up(
                                  username,
                                  pass1,
                                  phone_number,
                                  birthdate.toString(),
                                  choosed_gender);
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
                            'SignUp',
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
                        'Already have an account? ',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      Text(
                        'Just Login!',
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
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget buildblocWidget() {
    return BlocConsumer<UsersCubit, UsersState>(listener: (context, state) {
      if (state is usersignupcomplete) {
        determinePosition();
        globals.save_tokens_to_globals();
        globals.saveUser();
        Navigator.of(context)
            .pushReplacementNamed(homePageScreen, arguments: "user");
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
    }, builder: (context, state) {
      return bloc_child_widget();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: buildblocWidget());
  }
}
