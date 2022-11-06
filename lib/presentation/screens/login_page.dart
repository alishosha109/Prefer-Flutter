import 'package:Prefer/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:Prefer/business_logic/cubit/users_cubit.dart';
import 'package:Prefer/constants/globals.dart' as globals;
import 'package:Prefer/constants/my_colors.dart';
import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/data/models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool show_pass = false;
  var pass1;
  var username;
  late User user;
  var signed;
  var loading = false;
  var error_message = "";

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
                        AppLocalizations.of(context)!.translate('Login'),
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
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.black)),
                      hintText:
                          AppLocalizations.of(context)!.translate("Username"),
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
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
                  height: MediaQuery.of(context).size.height * 0.04,
                ),
                GestureDetector(
                  onTap: loading == false
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            BlocProvider.of<UsersCubit>(context).Sign_in(
                              username,
                              pass1,
                            );
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
                            AppLocalizations.of(context)!.translate('Login'),
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
                    Navigator.of(context).pushReplacementNamed(SignUpScreen);
                  },
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('Create New Account'),
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
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
      listener: (context, state) {
        if (state is usersignincomplete) {
          globals.save_tokens_to_globals();
          globals.saveUser();
          Navigator.pushReplacementNamed(
            context,
            homePageScreen,
          );
        }
        if (state is usersigninerror) {
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
      },
      builder: (context, state) {
        return bloc_child_widget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: buildblocWidget());
  }
}
