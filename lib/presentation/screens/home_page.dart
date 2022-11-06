import 'package:Prefer/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:Prefer/business_logic/cubit/theme_cubit.dart';
import 'package:Prefer/constants/globals.dart';

import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/presentation/widgets/shared_widgets.dart';
import '../../business_logic/cubit/posts_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/my_colors.dart';
import 'package:Prefer/constants/globals.dart' as globals;

import 'package:flutter_offline/flutter_offline.dart';
import '../../data/models/post.dart';

import 'package:draggable_fab/draggable_fab.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'dart:ui';
import 'package:vibration/vibration.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class HomePage extends StatefulWidget {
  String usertype;
  HomePage({Key? key, required this.usertype}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color main_color = HexColor("#D32F2F");
  late List<Post> allposts;
  Map<int, List<dynamic>> percs = {};
  Map<int, int> chs = {};
  List<String> reported_ids = [];
  bool loading = true;
  int current_page = 1;
  int Page_View_Index = 0;
  bool _showPreview = false;
  String _image = "";
  DateTime last_refresh = DateTime.now();
  final PageController controller = PageController(initialPage: 0);

  final supportedLanguages = [
    Languages.english,
    Languages.french,
    Languages.japanese,
    Languages.korean,
  ];
  @override
  void initState() {
    super.initState();
  }

  Widget buildBlocWidget() {
    print(widget.usertype);
    if (widget.usertype == "user") {
      BlocProvider.of<PostsCubit>(context)
          .getAllPosts(globals.main_user.sId, current_page);
    } else {
      BlocProvider.of<PostsCubit>(context).getguestposts(current_page);
    }

    return BlocConsumer<PostsCubit, PostsState>(listener: (context, state) {
      if (state is postsLoaded) {
        allposts = state.posts;
        loading = false;
      } else if (state is percsLoaded) {
        percs[state.index] = state.percs;
        print(percs);
      } else if (state is MorePostsLoaded) {
        allposts.addAll(state.posts);
      } else if (state is PostsRefresh) {
        allposts = state.posts;
        loading = false;
        Page_View_Index = 0;
      } else if (state is reportstatus) {
        if (state.reported) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(
                AppLocalizations.of(context)!.translate("Reported Succesfully"),
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.grey.withOpacity(0.5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(
                  AppLocalizations.of(context)!.translate("Error Occured"),
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.grey.withOpacity(0.5),
            ),
          );
        }
      } else if (state is view_photo) {
        _showPreview = state.showstat;
        _image = state.image_url;
      }
    }, builder: (context, state) {
      if (state is postsLoading) {
        return buildLoadedScrollerWidget();
      } else if (state is postsEmpty) {
        allposts = [];
        return buildNoPostsWidget();
      } else {
        return buildLoadedScrollerWidget();
      }
    });
  }

  Widget buildNoPostsWidget() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
            // color: Colors.black,
            child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            Text(
              AppLocalizations.of(context)!
                  .translate("No Live Posts, Check Later"),
              style: TextStyle(
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            ),
            Image.asset('assets/images/nodata.png'),
          ],
        )),
      ),
    );
  }

  Widget First_Container_First_Row_IF_2_Choices(index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.36,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
        child: Container(
          decoration: chs[index] == 0
              ? BoxDecoration(
                  border: Border.all(
                      width: 5, color: Color.fromRGBO(0, 100, 0, 04)),
                  borderRadius: BorderRadius.circular(20))
              : BoxDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GestureDetector(
              onLongPress: () {
                Vibration.vibrate(duration: 200);

                BlocProvider.of<PostsCubit>(context)
                    .viewphoto(true, allposts[index].photos![0][0]);
              },
              onLongPressUp: () {
                BlocProvider.of<PostsCubit>(context).viewphoto(false, "");
              },
              child: InkWell(
                onTap: percs.containsKey(index)
                    ? null
                    : () {
                        if (widget.usertype == "user") {
                          BlocProvider.of<PostsCubit>(context)
                              .getPercentages(allposts[index].sId, 0, index);
                          chs[index] = 0;
                        } else {
                          Navigator.of(context)
                              .pushReplacementNamed(SignUpScreen);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 3),
                              content: Text(
                                  AppLocalizations.of(context)!.translate(
                                      "Sign up to enjoy helping people :D"),
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.black,
                            ),
                          );
                        }
                      },
                child: Container(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 130),
                        child: SpinKitFadingFour(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    index.isEven ? Colors.white : Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.36,
                        child: SizedBox.expand(
                          child: FittedBox(
                            child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: '${allposts[index].photos?[0][0]}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      widget.usertype == "user"
                          ? AnimatedOpacity(
                              opacity: percs.containsKey(index) ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Container(
                                child: percs.containsKey(index)
                                    ? Align(
                                        child: Text(
                                        "${percs[index]![0][1]} %",
                                        style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ))
                                    : Text(""),
                                width: double.infinity,
                                height: percs.containsKey(index)
                                    ? MediaQuery.of(context).size.height *
                                        0.34 *
                                        int.parse(percs[index]![0][1]) /
                                        100
                                    : 0,
                                color: Color.fromARGB(255, 13, 81, 1)
                                    .withOpacity(0.3),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget First_Container_Second_Row_IF_2_Choices(index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.36,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 15, 8, 8),
        child: Container(
          decoration: chs[index] == 1
              ? BoxDecoration(
                  border: Border.all(
                      width: 5, color: Color.fromRGBO(0, 100, 0, 04)),
                  borderRadius: BorderRadius.circular(20))
              : BoxDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GestureDetector(
              onLongPress: () {
                Vibration.vibrate(duration: 200);

                print(_showPreview);
                BlocProvider.of<PostsCubit>(context)
                    .viewphoto(true, allposts[index].photos![1][0]);
                // setState(() {
                //   _showPreview = true;
                //   _image = allposts[index].photos![0][0].toString();
                // });
              },
              onLongPressUp: () {
                print(_showPreview);
                BlocProvider.of<PostsCubit>(context).viewphoto(false, "");
                // setState(() {
                //   _showPreview = false;
                // });
              },
              child: InkWell(
                onTap: percs.containsKey(index)
                    ? null
                    : () {
                        if (widget.usertype == "user") {
                          BlocProvider.of<PostsCubit>(context)
                              .getPercentages(allposts[index].sId, 1, index);
                          chs[index] = 1;
                        } else {
                          Navigator.of(context)
                              .pushReplacementNamed(SignUpScreen);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 3),
                              content: Text(
                                  AppLocalizations.of(context)!.translate(
                                      "Sign up to enjoy helping people :D,"),
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.black,
                            ),
                          );
                        }
                      },
                child: Container(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 130),
                        child: SpinKitFadingFour(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    index.isEven ? Colors.white : Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.36,
                        child: SizedBox.expand(
                          child: FittedBox(
                            child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: '${allposts[index].photos?[1][0]}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      widget.usertype == "user"
                          ? AnimatedOpacity(
                              opacity: percs.containsKey(index) ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Container(
                                child: percs.containsKey(index)
                                    ? Align(
                                        child: Text(
                                        "${percs[index]![1][1]} %",
                                        style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ))
                                    : Text(""),
                                width: double.infinity,
                                height: percs.containsKey(index)
                                    ? MediaQuery.of(context).size.height *
                                        0.34 *
                                        int.parse(percs[index]![1][1]) /
                                        100
                                    : 0,
                                color: Color.fromARGB(255, 13, 81, 1)
                                    .withOpacity(0.3),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget First_Row_Two_Images_Widget(index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        allposts[index].photos!.length != 2
            ? Container(
                // height: MediaQuery.of(context).size.height * 0.37,
                // width: MediaQuery.of(context).size.width * 0.5,
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: chs[index] == 0
                          ? BoxDecoration(
                              border: Border.all(
                                  width: 5,
                                  color: Color.fromRGBO(0, 100, 0, 04)),
                              borderRadius: BorderRadius.circular(20))
                          : BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: GestureDetector(
                          onLongPress: () async {
                            print(_showPreview);
                            Vibration.vibrate(duration: 200);
                            BlocProvider.of<PostsCubit>(context)
                                .viewphoto(true, allposts[index].photos![0][0]);
                            // setState(() {
                            //   _showPreview = true;
                            //   _image = allposts[index].photos![0][0].toString();
                            // });
                          },
                          onLongPressUp: () {
                            print(_showPreview);
                            BlocProvider.of<PostsCubit>(context)
                                .viewphoto(false, "");
                            // setState(() {
                            //   _showPreview = false;
                            // });
                          },
                          onTap: percs.containsKey(index)
                              ? null
                              : () {
                                  if (widget.usertype == "user") {
                                    BlocProvider.of<PostsCubit>(context)
                                        .getPercentages(
                                            allposts[index].sId, 0, index);
                                    chs[index] = 0;
                                  } else {
                                    Navigator.of(context)
                                        .pushReplacementNamed(SignUpScreen);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 3),
                                        content: Text(
                                            AppLocalizations.of(context)!.translate(
                                                "Sign up to enjoy helping people :D"),
                                            style:
                                                TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.black,
                                      ),
                                    );
                                  }
                                },
                          child: Container(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 130),
                                  child: SpinKitFadingFour(
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: index.isEven
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.34,
                                      child: SizedBox.expand(
                                        child: FittedBox(
                                          child: FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image:
                                                  '${allposts[index].photos?[0][0]}'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                widget.usertype == "user"
                                    ? AnimatedOpacity(
                                        opacity: percs.containsKey(index)
                                            ? 1.0
                                            : 0.0,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: Container(
                                          child: percs.containsKey(index)
                                              ? Align(
                                                  child: Text(
                                                  "${percs[index]![0][1]} %",
                                                  style: TextStyle(
                                                    //fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                ))
                                              : Text(""),
                                          width: double.infinity,
                                          height: percs.containsKey(index)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.34 *
                                                  int.parse(
                                                      percs[index]![0][1]) /
                                                  100
                                              : 0,
                                          color: Color.fromARGB(255, 13, 81, 1)
                                              .withOpacity(0.3),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : First_Container_First_Row_IF_2_Choices(index),
        allposts[index].photos!.length != 2
            ? Container(
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: chs[index] == 1
                          ? BoxDecoration(
                              border: Border.all(
                                  width: 5,
                                  color: Color.fromRGBO(0, 100, 0, 04)),
                              borderRadius: BorderRadius.circular(20))
                          : BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: GestureDetector(
                          onLongPress: () {
                            Vibration.vibrate(duration: 200);

                            print(_showPreview);
                            BlocProvider.of<PostsCubit>(context)
                                .viewphoto(true, allposts[index].photos![1][0]);
                            // setState(() {
                            //   _showPreview = true;
                            //   _image = allposts[index].photos![0][0].toString();
                            // });
                          },
                          onLongPressUp: () {
                            print(_showPreview);
                            BlocProvider.of<PostsCubit>(context)
                                .viewphoto(false, "");
                            // setState(() {
                            //   _showPreview = false;
                            // });
                          },
                          child: InkWell(
                            onTap: percs.containsKey(index)
                                ? null
                                : () {
                                    if (widget.usertype == "user") {
                                      BlocProvider.of<PostsCubit>(context)
                                          .getPercentages(
                                              allposts[index].sId, 1, index);
                                      chs[index] = 1;
                                    } else {
                                      Navigator.of(context)
                                          .pushReplacementNamed(SignUpScreen);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 3),
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      "Sign up to enjoy helping people :D"),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          backgroundColor: Colors.black,
                                        ),
                                      );
                                    }
                                  },
                            child: Container(
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 130),
                                    child: SpinKitFadingFour(
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: index.isEven
                                                ? Colors.white
                                                : Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.34,
                                    child: SizedBox.expand(
                                      child: FittedBox(
                                        child: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image:
                                              '${allposts[index].photos?[1][0]}',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  widget.usertype == "user"
                                      ? AnimatedOpacity(
                                          opacity: percs.containsKey(index)
                                              ? 1.0
                                              : 0.0,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: Container(
                                            child: percs.containsKey(index)
                                                ? Align(
                                                    child: Text(
                                                    "${percs[index]![1][1]} %",
                                                    style: TextStyle(
                                                        //fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontFamily: 'lone'),
                                                  ))
                                                : Text(""),
                                            width: double.infinity,
                                            height: percs.containsKey(index)
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.34 *
                                                    int.parse(
                                                        percs[index]![1][1]) /
                                                    100
                                                : 0,
                                            color:
                                                Color.fromARGB(255, 13, 81, 1)
                                                    .withOpacity(0.3),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget First_Container_Second_Row_IF_3_choices(index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.36,
      width: MediaQuery.of(context).size.width * 0.485,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
        child: Container(
          decoration: chs[index] == 2
              ? BoxDecoration(
                  border: Border.all(
                      width: 5, color: Color.fromRGBO(0, 100, 0, 04)),
                  borderRadius: BorderRadius.circular(20))
              : BoxDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GestureDetector(
              onLongPress: () {
                print(_showPreview);
                Vibration.vibrate(duration: 200);

                BlocProvider.of<PostsCubit>(context)
                    .viewphoto(true, allposts[index].photos![2][0]);
                // setState(() {
                //   _showPreview = true;
                //   _image = allposts[index].photos![0][0].toString();
                // });
              },
              onLongPressUp: () {
                print(_showPreview);
                BlocProvider.of<PostsCubit>(context).viewphoto(false, "");
                // setState(() {
                //   _showPreview = false;
                // });
              },
              child: InkWell(
                onTap: percs.containsKey(index)
                    ? null
                    : () {
                        if (widget.usertype == "user") {
                          BlocProvider.of<PostsCubit>(context)
                              .getPercentages(allposts[index].sId, 2, index);
                          chs[index] = 2;
                        } else {
                          Navigator.of(context)
                              .pushReplacementNamed(SignUpScreen);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 3),
                              content: Text(
                                  AppLocalizations.of(context)!.translate(
                                      "Sign up to enjoy helping people :D"),
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.black,
                            ),
                          );
                        }
                      },
                child: Container(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 130),
                        child: SpinKitFadingFour(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    index.isEven ? Colors.white : Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.34,
                        child: SizedBox.expand(
                          child: FittedBox(
                            child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: '${allposts[index].photos?[2][0]}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      widget.usertype == "user"
                          ? AnimatedOpacity(
                              opacity: percs.containsKey(index) ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Container(
                                child: percs.containsKey(index)
                                    ? Align(
                                        child: Text(
                                        "${percs[index]![2][1]} %",
                                        style: TextStyle(
                                            //fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'lone'),
                                      ))
                                    : Text(""),
                                width: double.infinity,
                                height: percs.containsKey(index)
                                    ? MediaQuery.of(context).size.height *
                                        0.34 *
                                        int.parse(percs[index]![2][1]) /
                                        100
                                    : 0,
                                color: Color.fromARGB(255, 13, 81, 1)
                                    .withOpacity(0.3),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget First_Container_Second_Row(index) {
    return Container(
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: chs[index] == 2
                ? BoxDecoration(
                    border: Border.all(
                        width: 5, color: Color.fromRGBO(0, 100, 0, 04)),
                    borderRadius: BorderRadius.circular(20))
                : BoxDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GestureDetector(
                onLongPress: () {
                  Vibration.vibrate(duration: 200);

                  print(_showPreview);
                  BlocProvider.of<PostsCubit>(context)
                      .viewphoto(true, allposts[index].photos![2][0]);
                  // setState(() {
                  //   _showPreview = true;
                  //   _image = allposts[index].photos![0][0].toString();
                  // });
                },
                onLongPressUp: () {
                  print(_showPreview);
                  BlocProvider.of<PostsCubit>(context).viewphoto(false, "");
                  // setState(() {
                  //   _showPreview = false;
                  // });
                },
                child: InkWell(
                  onTap: percs.containsKey(index)
                      ? null
                      : () {
                          if (widget.usertype == "user") {
                            BlocProvider.of<PostsCubit>(context)
                                .getPercentages(allposts[index].sId, 2, index);
                            chs[index] = 2;
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed(SignUpScreen);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 3),
                                content: Text(
                                    AppLocalizations.of(context)!.translate(
                                        "Sign up to enjoy helping people :D"),
                                    style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.black,
                              ),
                            );
                          }
                        },
                  child: Container(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 130),
                          child: SpinKitFadingFour(
                            itemBuilder: (BuildContext context, int index) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      index.isEven ? Colors.white : Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.34,
                          child: SizedBox.expand(
                            child: FittedBox(
                              child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: '${allposts[index].photos?[2][0]}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        widget.usertype == "user"
                            ? AnimatedOpacity(
                                opacity: percs.containsKey(index) ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Container(
                                  child: percs.containsKey(index)
                                      ? Align(
                                          child: Text(
                                          "${percs[index]![2][1]} %",
                                          style: TextStyle(
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontFamily: 'lone'),
                                        ))
                                      : Text(""),
                                  width: double.infinity,
                                  height: percs.containsKey(index)
                                      ? MediaQuery.of(context).size.height *
                                          0.34 *
                                          (int.parse(percs[index]![2][1]) / 100)
                                      : 0,
                                  color: Color.fromARGB(255, 13, 81, 1)
                                      .withOpacity(0.3),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget Second_Row_Two_Images_Widget(index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        allposts[index].photos!.length == 4
            ? First_Container_Second_Row(index)
            : allposts[index].photos!.length == 3
                ? First_Container_Second_Row_IF_3_choices(index)
                : First_Container_Second_Row_IF_2_Choices(index),
        allposts[index].photos!.length == 4
            ? Container(
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: chs[index] == 3
                          ? BoxDecoration(
                              border: Border.all(
                                  width: 5,
                                  color: Color.fromRGBO(0, 100, 0, 04)),
                              borderRadius: BorderRadius.circular(20))
                          : BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: GestureDetector(
                          onLongPress: () {
                            Vibration.vibrate(duration: 200);

                            print(_showPreview);
                            BlocProvider.of<PostsCubit>(context)
                                .viewphoto(true, allposts[index].photos![3][0]);
                            // setState(() {
                            //   _showPreview = true;
                            //   _image = allposts[index].photos![0][0].toString();
                            // });
                          },
                          onLongPressUp: () {
                            print(_showPreview);
                            BlocProvider.of<PostsCubit>(context)
                                .viewphoto(false, "");
                            // setState(() {
                            //   _showPreview = false;
                            // });
                          },
                          child: InkWell(
                            onTap: percs.containsKey(index)
                                ? null
                                : () {
                                    if (widget.usertype == "user") {
                                      BlocProvider.of<PostsCubit>(context)
                                          .getPercentages(
                                              allposts[index].sId, 3, index);
                                      chs[index] = 3;
                                    } else {
                                      Navigator.of(context)
                                          .pushReplacementNamed(SignUpScreen);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 3),
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      "Sign up to enjoy helping people :D"),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          backgroundColor: Colors.black,
                                        ),
                                      );
                                    }
                                  },
                            child: Container(
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 130),
                                    child: SpinKitFadingFour(
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: index.isEven
                                                ? Colors.white
                                                : Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.34,
                                    child: SizedBox.expand(
                                      child: FittedBox(
                                        child: FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image:
                                                '${allposts[index].photos?[3][0]}'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  widget.usertype == "user"
                                      ? AnimatedOpacity(
                                          opacity: percs.containsKey(index)
                                              ? 1.0
                                              : 0.0,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: Container(
                                            child: percs.containsKey(index)
                                                ? Align(
                                                    child: Text(
                                                    "${percs[index]![3][1]} %",
                                                    style: TextStyle(
                                                        //fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontFamily: 'lone'),
                                                  ))
                                                : Text(""),
                                            width: double.infinity,
                                            height: percs.containsKey(index)
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.34 *
                                                    int.parse(
                                                        percs[index]![3][1]) /
                                                    100
                                                : 0,
                                            color:
                                                Color.fromARGB(255, 13, 81, 1)
                                                    .withOpacity(0.3),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget buildLoadedScrollerWidget() {
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
        : Stack(
            children: [
              PageView.builder(
                  controller: controller,
                  itemCount: allposts.length,
                  // physics: ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    Page_View_Index = index;
                    print(index);
                    if (index == allposts.length - 1) {
                      print("ana fe el a5er");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text(
                              AppLocalizations.of(context)!
                                  .translate("Loading more posts"),
                              style: TextStyle(color: Colors.black)),
                          backgroundColor: Colors.grey.withOpacity(0.5),
                        ),
                      );
                      current_page = current_page + 1;
                      if (widget.usertype == 'user') {
                        BlocProvider.of<PostsCubit>(context)
                            .getAllPosts(globals.main_user.sId, current_page);
                      } else {
                        BlocProvider.of<PostsCubit>(context)
                            .getguestposts(current_page);
                      }
                    }
                  },
                  itemBuilder: (context, index) {
                    return Card(
                      color: globals.theme_mode == ThemeMode.dark
                          ? Colors.black
                          : Colors.white,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(17, 2, 17, 0),
                                  child: Wrap(
                                    children: [
                                      Text(
                                        "${allposts[index].description}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: globals.theme_mode ==
                                                  ThemeMode.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  )),
                              First_Row_Two_Images_Widget(index),
                              Second_Row_Two_Images_Widget(index),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: RawMaterialButton(
                                  onPressed: () {
                                    if (widget.usertype == "user") {
                                      if (reported_ids
                                          .contains(allposts[index].sId)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration:
                                                const Duration(seconds: 1),
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .translate(
                                                        "Already Reported"),
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            backgroundColor:
                                                Colors.grey.withOpacity(0.5),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor:
                                                globals.theme_mode ==
                                                        ThemeMode.dark
                                                    ? Colors.black87
                                                    : Colors.white,
                                            content: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      "Are you sure you want to report this post?"),
                                              style: TextStyle(
                                                color: globals.theme_mode ==
                                                        ThemeMode.dark
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
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate("Cancel"),
                                                    style: TextStyle(
                                                        color:
                                                            MyColors.mywhite),
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  reported_ids.add(
                                                      allposts[index]
                                                          .sId
                                                          .toString());
                                                  BlocProvider.of<PostsCubit>(
                                                          context)
                                                      .report_user(
                                                          allposts[index]
                                                              .user
                                                              ?.sId,
                                                          allposts[index].sId,
                                                          globals
                                                              .main_user.sId);
                                                  controller.animateToPage(
                                                      Page_View_Index + 1,
                                                      curve: Curves.decelerate,
                                                      duration: Duration(
                                                          milliseconds: 300));
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Container(
                                                  color: MyColors.myRed,
                                                  padding:
                                                      const EdgeInsets.all(14),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate("Report"),
                                                    style: TextStyle(
                                                        color:
                                                            MyColors.mywhite),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    } else {
                                      Navigator.of(context)
                                          .pushReplacementNamed(SignUpScreen);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 3),
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      "Sign up to enjoy helping people :D"),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          backgroundColor: Colors.black,
                                        ),
                                      );
                                    }

                                    // for animated jump. Requires a curve and a duration
                                  },
                                  constraints:
                                      BoxConstraints.tight(Size(36, 36)),
                                  elevation: 2.0,
                                  fillColor:
                                      globals.theme_mode == ThemeMode.dark
                                          ? main_color.withOpacity(0.5)
                                          : main_color,
                                  child: Icon(
                                    Icons.report,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  shape: CircleBorder(),
                                ),
                              ),
                            ]),
                      ),
                    );
                  }),
              if (_showPreview) ...[
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                  child: Container(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                Container(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        _image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
  }

  Widget Main_Widget() {
    return OfflineBuilder(
        connectivityBuilder: ((
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;
          if (connected) {
            return buildBlocWidget();
          } else {
            return NoInternetWidget(context);
          }
        }),
        child: Container());
  }

  Widget drawerWidget() {
    return Drawer(
      backgroundColor:
          globals.theme_mode == ThemeMode.dark ? Colors.black : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: globals.theme_mode == ThemeMode.dark
                    ? Colors.black
                    : MyColors.myRed,
              ),
              child: Text(
                AppLocalizations.of(context)!.translate("Menu"),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          globals.theme_mode == ThemeMode.dark
              ? Divider(
                  color: Colors.grey.shade900,
                  thickness: 1,
                )
              : Container(),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(ProfileScreen);
            },
            trailing: Icon(
              Icons.person,
              color: globals.theme_mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.translate("Account"),
              style: TextStyle(
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            ),
          ),
          Divider(
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.grey.shade900
                : MyColors.myRed,
            thickness: 1,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(myPostsScreen);
            },
            trailing: Icon(
              Icons.my_library_books,
              color: globals.theme_mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.translate("My Posts"),
              style: TextStyle(
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            ),
          ),
          Divider(
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.grey.shade900
                : MyColors.myRed,
            thickness: 1,
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(ChoicesScreen);
            },
            trailing: Icon(
              Icons.history,
              color: globals.theme_mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.translate("Choices History"),
              style: TextStyle(
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            ),
          ),
          Divider(
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.grey.shade900
                : MyColors.myRed,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.sunny,
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.orange,
                ),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return FlutterSwitch(
                      activeColor: MyColors.myRed,
                      value:
                          globals.theme_mode == ThemeMode.dark ? false : true,
                      // showOnOff: true,
                      onToggle: (val) {
                        if (val) {
                          BlocProvider.of<ThemeCubit>(context)
                              .toggle_Theme("light");
                        } else {
                          BlocProvider.of<ThemeCubit>(context)
                              .toggle_Theme("dark");
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.grey.shade900
                : MyColors.myRed,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.language,
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.orange,
                ),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return DropdownButton<String>(
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
              ],
            ),
          ),
          Divider(
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.grey.shade900
                : MyColors.myRed,
            thickness: 1,
          ),
          ListTile(
            onTap: () {
              globals.delete_all_prefs(globals.main_user.sId);
              globals.delete_acctoken_reftoken();
              Navigator.of(context).pushReplacementNamed(loginScreen);
            },
            trailing: Icon(
              Icons.logout,
              color: globals.theme_mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.translate("Logout"),
              style: TextStyle(
                  color: globals.theme_mode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            ),
          ),
          Divider(
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.grey.shade900
                : MyColors.myRed,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget appbarWidget(_key) {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        InkWell(
          onTap: () {
            if (widget.usertype == "user") {
              var dtnow = DateTime.now();
              Duration dtdiff = dtnow.difference(last_refresh);
              print(dtdiff.inSeconds);
              if (dtdiff.inSeconds >= 15) {
                last_refresh = dtnow;
                percs.clear();
                chs.clear();
                current_page = 1;
                Page_View_Index = 0;
                BlocProvider.of<PostsCubit>(context).getAllPosts(
                    globals.main_user.sId, current_page,
                    refresh: true);
                controller.animateToPage(Page_View_Index,
                    curve: Curves.decelerate,
                    duration: Duration(milliseconds: 300));
              }
            } else {
              Navigator.of(context).pushReplacementNamed(SignUpScreen);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 3),
                  content: Text(
                      AppLocalizations.of(context)!
                          .translate("Sign up to enjoy helping people :D"),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black,
                ),
              );
            }
          },
          child: Icon(
            Icons.home,
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.white
                : Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: InkWell(
            onTap: () {
              if (widget.usertype == "user") {
                _key.currentState?.openEndDrawer();
              } else {
                Navigator.of(context).pushReplacementNamed(SignUpScreen);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 3),
                    content: Text(
                        AppLocalizations.of(context)!
                            .translate("Sign up to enjoy helping people :D"),
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.black,
                  ),
                );
              }
            },
            child: Icon(
              Icons.menu,
              color: globals.theme_mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.white,
            ),
          ),
        )
      ],
      backgroundColor:
          globals.theme_mode == ThemeMode.dark ? Colors.black : MyColors.myRed,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: InkWell(
          onTap: () {
            determinePosition();
          },
          child: Text(
            "Prefer",
            style: TextStyle(
                fontFamily: 'mad',
                fontSize: 50,
                color: globals.theme_mode == ThemeMode.dark
                    ? Colors.white
                    : Colors.white),
          ),
        ),
      ),
      centerTitle: false,
    );
  }

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey();
    print(widget.usertype);
    return Scaffold(
      key: _key,
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: DraggableFab(
            child: FloatingActionButton(
              mini: true,
              backgroundColor: globals.theme_mode == ThemeMode.dark
                  ? MyColors.myRedOpc
                  : MyColors.myRed,
              onPressed: () {
                if (widget.usertype == "user") {
                  Navigator.pushNamed(context, addpostScreen);
                } else {
                  Navigator.of(context).pushReplacementNamed(SignUpScreen);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 3),
                      content: Text(
                          AppLocalizations.of(context)!
                              .translate("Sign up to enjoy helping people :D"),
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.black,
                    ),
                  );
                }
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          )),
      endDrawer: drawerWidget(),
      //bottomNavigationBar: _getBottomBar(),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(55.0), // here the desired height
          child: appbarWidget(_key)),
      backgroundColor:
          globals.theme_mode == ThemeMode.dark ? Colors.black : Colors.white,
      body: Main_Widget(),
    );
  }
}
