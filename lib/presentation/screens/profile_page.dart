import 'package:Prefer/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:Prefer/business_logic/cubit/users_cubit.dart';
import 'package:Prefer/constants/globals.dart';
import 'package:Prefer/constants/globals.dart' as globals;
import 'package:Prefer/constants/my_colors.dart';
import 'package:Prefer/data/models/user.dart';
import 'package:Prefer/presentation/widgets/shared_widgets.dart';

// This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  int choices_history = 0;
  int posts_total_answers = 0;

  Widget buildblocWidget() {
    BlocProvider.of<UsersCubit>(context).get_profile_Numbers(main_user.sId);

    return BlocConsumer<UsersCubit, UsersState>(
      listener: (context, state) {
        if (state is numbersloaded) {
          choices_history = state.values[1];
          posts_total_answers = state.values[0];
          loading = false;
        }
      },
      builder: (context, state) {
        return profileWidget();
      },
    );
  }

  Widget profileWidget() {
    return loading
        ? Center(
            child: SpinKitFadingFour(
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.white : Colors.grey,
                  ),
                );
              },
            ),
          )
        : SingleChildScrollView(
            child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: buildUserInfoDisplay(
                  "${main_user.username}",
                  AppLocalizations.of(context)!.translate("Username"),
                ),
              ),
              SizedBox(
                height: 10.0,
                child: new Center(
                  child: new Container(
                    margin:
                        new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              buildUserInfoDisplay(
                "${main_user.phoneNumber}",
                AppLocalizations.of(context)!.translate("Phone Number"),
              ),
              SizedBox(
                height: 10.0,
                child: new Center(
                  child: new Container(
                    margin:
                        new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              buildUserInfoDisplay(
                "${main_user.reports}",
                AppLocalizations.of(context)!
                    .translate("Times you have been reported"),
              ),
              buildWarning(),
              SizedBox(
                height: 10.0,
                child: new Center(
                  child: new Container(
                    margin:
                        new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              buildUserInfoDisplay(
                  "${main_user.blocked == false ? AppLocalizations.of(context)!.translate("No") : AppLocalizations.of(context)!.translate("Yes")}",
                  AppLocalizations.of(context)!.translate("Blocked")),
              SizedBox(
                height: 10.0,
                child: new Center(
                  child: new Container(
                    margin:
                        new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate("Users you have helped: "),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: globals.theme_mode == ThemeMode.dark
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          choices_history.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 10.0,
                child: new Center(
                  child: new Container(
                    margin:
                        new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate("Users helped you: "),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: globals.theme_mode == ThemeMode.dark
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          posts_total_answers.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 10.0,
                child: new Center(
                  child: new Container(
                    margin:
                        new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ));
  }

  // Widget builds the display item with the proper formatting to display the user's info
  Widget buildUserInfoDisplay(
    String getValue,
    String title,
  ) =>
      Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${title}: ",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: globals.theme_mode == ThemeMode.dark
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getValue,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: globals.theme_mode == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ));

  Widget buildWarning() {
    return Padding(
        padding: EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange,
              size: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.translate(
                      "If your reports exceeded 50 you will be permanently banned"),
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: globals.theme_mode == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget main_widget() {
    return OfflineBuilder(
        connectivityBuilder: ((
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
          if (connected) {
            return buildblocWidget();
          } else {
            return NoInternetWidget(context);
          }
        }),
        child: Container());
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            globals.theme_mode == ThemeMode.dark ? Colors.black : Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0), // here the desired height
          child: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: globals.theme_mode == ThemeMode.dark
                ? Colors.black
                : MyColors.myRed,
            title: Text(
              AppLocalizations.of(context)!.translate("My Account"),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            centerTitle: false,
          ),
        ),
        body: main_widget());
  }
}
