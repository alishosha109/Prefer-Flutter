import 'package:Prefer/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/data/models/history_post.dart';
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
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:ui';

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

class ChoicesHistoryPage extends StatefulWidget {
  @override
  State<ChoicesHistoryPage> createState() => _ChoicesHistoryPageState();
}

class _ChoicesHistoryPageState extends State<ChoicesHistoryPage> {
  Color main_color = HexColor("#D32F2F");
  late List<History_Post> allhistoryposts;
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
  @override
  void initState() {
    super.initState();
  }

  Widget buildBlocWidget() {
    BlocProvider.of<PostsCubit>(context)
        .getchoiceshistory(globals.main_user.sId, current_page);
    return BlocConsumer<PostsCubit, PostsState>(listener: (context, state) {
      if (state is HistorypostsLoaded) {
        allhistoryposts = state.historyposts;
        loading = false;
      } else if (state is percsLoaded) {
        percs[state.index] = state.percs;
        print(percs);
      } else if (state is MoreHistoryPostsLoaded) {
        allhistoryposts.addAll(state.historyposts);
      } else if (state is HistoryPostsRefresh) {
        allhistoryposts = state.historyposts;
        loading = false;
        Page_View_Index = 0;
      } else if (state is view_photo) {
        _showPreview = state.showstat;
        _image = state.image_url;
      }
    }, builder: (context, state) {
      if (state is historypostsLoading) {
        return buildLoadedScrollerWidget();
      } else if (state is historypostsEmpty) {
        allhistoryposts = [];
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
            color: globals.theme_mode == ThemeMode.dark
                ? Colors.black
                : Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                Text(
                  AppLocalizations.of(context)!.translate("No Choice History"),
                  style: TextStyle(
                    color: globals.theme_mode == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Image.asset('assets/images/nodata.png'),
              ],
            )),
      ),
    );
  }

  Widget First_Container_First_Row_IF_2_Choices(index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.37,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Container(
          decoration: allhistoryposts[index].choice == 0
              ? BoxDecoration(
                  border: Border.all(
                      width: 5, color: Color.fromRGBO(0, 100, 0, 04)),
                  borderRadius: BorderRadius.circular(20))
              : BoxDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GestureDetector(
              onLongPress: () {
                BlocProvider.of<PostsCubit>(context).viewphoto(
                    true, allhistoryposts[index].post!.photos![0][0]);
              },
              onLongPressUp: () {
                BlocProvider.of<PostsCubit>(context).viewphoto(false, "");
              },
              child: Container(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 130),
                    //   child: SpinKitFadingFour(
                    //     itemBuilder: (BuildContext context, int index) {
                    //       return DecoratedBox(
                    //         decoration: BoxDecoration(
                    //           color: index.isEven ? Colors.white : Colors.grey,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.36,
                      child: SizedBox.expand(
                        child: FittedBox(
                          child: CachedNetworkImage(
                            imageUrl:
                                '${allhistoryposts[index].post!.photos![0][0]}',
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Transform.scale(
                                        scale: 0.1,
                                        child: CircularProgressIndicator(
                                            color: Colors.grey,
                                            value: downloadProgress.progress)),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        child: Align(
                            child: Text(
                          "${allhistoryposts[index].post!.photos![0][1]} % (${((int.parse(allhistoryposts[index].post!.photos![0][1]) / 100) * (allhistoryposts[index].post!.totalAnswers!)).toInt()})",
                          style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'lone'),
                        )),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height *
                            0.34 *
                            int.parse(
                                allhistoryposts[index].post!.photos![0][1]) /
                            100,
                        color: Color.fromARGB(255, 13, 81, 1).withOpacity(0.3),
                      ),
                    )
                  ],
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
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Container(
          decoration: allhistoryposts[index].choice == 1
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
                BlocProvider.of<PostsCubit>(context).viewphoto(
                    true, allhistoryposts[index].post!.photos![1][0]);
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
              child: Container(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 130),
                    //   child: SpinKitFadingFour(
                    //     itemBuilder: (BuildContext context, int index) {
                    //       return DecoratedBox(
                    //         decoration: BoxDecoration(
                    //           color: index.isEven ? Colors.white : Colors.grey,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.36,
                      child: SizedBox.expand(
                        child: FittedBox(
                          child: CachedNetworkImage(
                            imageUrl:
                                '${allhistoryposts[index].post!.photos![1][0]}',
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Transform.scale(
                                        scale: 0.1,
                                        child: CircularProgressIndicator(
                                            color: Colors.grey,
                                            value: downloadProgress.progress)),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        child: Align(
                            child: Text(
                          "${allhistoryposts[index].post!.photos![1][1]} % (${((int.parse(allhistoryposts[index].post!.photos![1][1]) / 100) * (allhistoryposts[index].post!.totalAnswers!)).toInt()})",
                          style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'lone'),
                        )),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height *
                            0.34 *
                            int.parse(
                                allhistoryposts[index].post!.photos![1][1]) /
                            100,
                        color: Color.fromARGB(255, 13, 81, 1).withOpacity(0.3),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget First_Row_Two_Images_Widget(index) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            allhistoryposts[index].post!.photos!.length != 2
                ? Container(
                    child: Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: allhistoryposts[index].choice == 0
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
                                print(_showPreview);
                                BlocProvider.of<PostsCubit>(context).viewphoto(
                                    true,
                                    allhistoryposts[index].post!.photos![0][0]);
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
                              child: Container(
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Padding(
                                    //   padding:
                                    //       const EdgeInsets.only(bottom: 130),
                                    //   child: SpinKitFadingFour(
                                    //     itemBuilder:
                                    //         (BuildContext context, int index) {
                                    //       return DecoratedBox(
                                    //         decoration: BoxDecoration(
                                    //           color: index.isEven
                                    //               ? Colors.white
                                    //               : Colors.grey,
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                    Column(
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.34,
                                          child: SizedBox.expand(
                                            child: FittedBox(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '${allhistoryposts[index].post!.photos![0][0]}',
                                                progressIndicatorBuilder: (context,
                                                        url,
                                                        downloadProgress) =>
                                                    Transform.scale(
                                                        scale: 0.1,
                                                        child: CircularProgressIndicator(
                                                            color: Colors.grey,
                                                            value:
                                                                downloadProgress
                                                                    .progress)),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    AnimatedOpacity(
                                      opacity: 1.0,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: Container(
                                        child: Align(
                                            child: Text(
                                          "${allhistoryposts[index].post!.photos![0][1]} % (${((int.parse(allhistoryposts[index].post!.photos![0][1]) / 100) * (allhistoryposts[index].post!.totalAnswers!)).toInt()})",
                                          style: TextStyle(
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'lone'),
                                        )),
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.34 *
                                                int.parse(allhistoryposts[index]
                                                    .post!
                                                    .photos![0][1]) /
                                                100,
                                        color: Color.fromARGB(255, 13, 81, 1)
                                            .withOpacity(0.3),
                                      ),
                                    )
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
            allhistoryposts[index].post!.photos!.length != 2
                ? Container(
                    child: Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: allhistoryposts[index].choice == 1
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
                                print(_showPreview);
                                BlocProvider.of<PostsCubit>(context).viewphoto(
                                    true,
                                    allhistoryposts[index].post!.photos![1][0]);
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
                              child: Container(
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Padding(
                                    //   padding:
                                    //       const EdgeInsets.only(bottom: 130),
                                    //   child: SpinKitFadingFour(
                                    //     itemBuilder:
                                    //         (BuildContext context, int index) {
                                    //       return DecoratedBox(
                                    //         decoration: BoxDecoration(
                                    //           color: index.isEven
                                    //               ? Colors.white
                                    //               : Colors.grey,
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.34,
                                      child: SizedBox.expand(
                                        child: FittedBox(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '${allhistoryposts[index].post!.photos![1][0]}',
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Transform.scale(
                                                    scale: 0.1,
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: Colors.grey,
                                                            value:
                                                                downloadProgress
                                                                    .progress)),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    AnimatedOpacity(
                                      opacity: 1,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: Container(
                                        child: Align(
                                            child: Text(
                                          "${allhistoryposts[index].post!.photos![1][1]} % (${((int.parse(allhistoryposts[index].post!.photos![1][1]) / 100) * (allhistoryposts[index].post!.totalAnswers!)).toInt()})",
                                          style: TextStyle(
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'lone'),
                                        )),
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.34 *
                                                int.parse(allhistoryposts[index]
                                                    .post!
                                                    .photos![1][1]) /
                                                100,
                                        color: Color.fromARGB(255, 13, 81, 1)
                                            .withOpacity(0.3),
                                      ),
                                    )
                                  ],
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
        ),
        !allhistoryposts[index].post!.hidden!
            ? Container(
                height: MediaQuery.of(context).size.height * 0.37,
                width: 2,
                color: Colors.green,
              )
            : Container()
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
          decoration: allhistoryposts[index].choice == 2
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
                BlocProvider.of<PostsCubit>(context).viewphoto(
                    true, allhistoryposts[index].post!.photos![2][0]);
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
              child: Container(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 130),
                    //   child: SpinKitFadingFour(
                    //     itemBuilder: (BuildContext context, int index) {
                    //       return DecoratedBox(
                    //         decoration: BoxDecoration(
                    //           color: index.isEven ? Colors.white : Colors.grey,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.34,
                      child: SizedBox.expand(
                        child: FittedBox(
                          child: CachedNetworkImage(
                            imageUrl:
                                '${allhistoryposts[index].post!.photos![2][0]}',
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Transform.scale(
                                        scale: 0.1,
                                        child: CircularProgressIndicator(
                                            color: Colors.grey,
                                            value: downloadProgress.progress)),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        child: Align(
                            child: Text(
                          "${allhistoryposts[index].post!.photos![2][1]} % (${((int.parse(allhistoryposts[index].post!.photos![2][1]) / 100) * (allhistoryposts[index].post!.totalAnswers!)).toInt()})",
                          style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'lone'),
                        )),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height *
                            0.34 *
                            int.parse(
                                allhistoryposts[index].post!.photos![2][1]) /
                            100,
                        color: Color.fromARGB(255, 13, 81, 1).withOpacity(0.3),
                      ),
                    )
                  ],
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
            decoration: allhistoryposts[index].choice == 2
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
                  BlocProvider.of<PostsCubit>(context).viewphoto(
                      true, allhistoryposts[index].post!.photos![2][0]);
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
                child: Container(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 130),
                      //   child: SpinKitFadingFour(
                      //     itemBuilder: (BuildContext context, int index) {
                      //       return DecoratedBox(
                      //         decoration: BoxDecoration(
                      //           color:
                      //               index.isEven ? Colors.white : Colors.grey,
                      //         ),
                      //       );
                      //     },
                      //   ),
                      // ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.34,
                        child: SizedBox.expand(
                          child: FittedBox(
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${allhistoryposts[index].post!.photos![2][0]}',
                              progressIndicatorBuilder: (context, url,
                                      downloadProgress) =>
                                  Transform.scale(
                                      scale: 0.1,
                                      child: CircularProgressIndicator(
                                          color: Colors.grey,
                                          value: downloadProgress.progress)),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          child: Align(
                              child: Text(
                            "${allhistoryposts[index].post!.photos![2][1]} % (${((int.parse(allhistoryposts[index].post!.photos![2][1]) / 100) * (allhistoryposts[index].post!.totalAnswers!)).toInt()})",
                            style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'lone'),
                          )),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height *
                              0.34 *
                              int.parse(
                                  allhistoryposts[index].post!.photos![2][1]) /
                              100,
                          color:
                              Color.fromARGB(255, 13, 81, 1).withOpacity(0.3),
                        ),
                      )
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

  Widget Second_Row_Two_Images_Widget(index) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            allhistoryposts[index].post!.photos!.length == 4
                ? First_Container_Second_Row(index)
                : allhistoryposts[index].post!.photos!.length == 3
                    ? First_Container_Second_Row_IF_3_choices(index)
                    : First_Container_Second_Row_IF_2_Choices(index),
            allhistoryposts[index].post!.photos!.length == 4
                ? Container(
                    child: Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: allhistoryposts[index].choice == 3
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
                                print(_showPreview);
                                BlocProvider.of<PostsCubit>(context).viewphoto(
                                    true,
                                    allhistoryposts[index].post!.photos![3][0]);
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
                              child: Container(
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Padding(
                                    //   padding:
                                    //       const EdgeInsets.only(bottom: 130),
                                    //   child: SpinKitFadingFour(
                                    //     itemBuilder:
                                    //         (BuildContext context, int index) {
                                    //       return DecoratedBox(
                                    //         decoration: BoxDecoration(
                                    //           color: index.isEven
                                    //               ? Colors.white
                                    //               : Colors.grey,
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.34,
                                      child: SizedBox.expand(
                                        child: FittedBox(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '${allhistoryposts[index].post!.photos![3][0]}',
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Transform.scale(
                                                    scale: 0.1,
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: Colors.grey,
                                                            value:
                                                                downloadProgress
                                                                    .progress)),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    AnimatedOpacity(
                                      opacity: 1,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: Container(
                                        child: Align(
                                            child: Text(
                                          "${allhistoryposts[index].post!.photos![3][1]} % (${((int.parse(allhistoryposts[index].post!.photos![3][1]) / 100) * (allhistoryposts[index].post!.totalAnswers!)).toInt()})",
                                          style: TextStyle(
                                              //fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'lone'),
                                        )),
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.34 *
                                                int.parse(allhistoryposts[index]
                                                    .post!
                                                    .photos![3][1]) /
                                                100,
                                        color: Color.fromARGB(255, 13, 81, 1)
                                            .withOpacity(0.3),
                                      ),
                                    )
                                  ],
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
        ),
        !allhistoryposts[index].post!.hidden!
            ? Container(
                height: MediaQuery.of(context).size.height * 0.37,
                width: 2,
                color: Colors.green,
              )
            : Container()
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
                  itemCount: allhistoryposts.length,
                  // physics: ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    Page_View_Index = index;
                    print(index);
                    if (index == allhistoryposts.length - 1) {
                      print("ana fe el a5er");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text(AppLocalizations.of(context)!
                              .translate("Loading more posts")),
                          backgroundColor: Colors.grey.withOpacity(0.5),
                        ),
                      );
                      current_page = current_page + 1;
                      BlocProvider.of<PostsCubit>(context).getchoiceshistory(
                          globals.main_user.sId, current_page);
                    }
                  },
                  itemBuilder: (context, index) {
                    final item = allhistoryposts[index];

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
                                  padding: EdgeInsets.fromLTRB(17, 20, 17, 0),
                                  child: Wrap(
                                    children: [
                                      Text(
                                        "${allhistoryposts[index].post!.description}",
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

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey();

    return Scaffold(
      key: _key,
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 20),
              child: InkWell(
                onTap: () {
                  var dtnow = DateTime.now();
                  Duration dtdiff = dtnow.difference(last_refresh);
                  print(dtdiff.inSeconds);
                  if (dtdiff.inSeconds >= 15) {
                    last_refresh = dtnow;
                    percs.clear();
                    chs.clear();
                    current_page = 1;
                    Page_View_Index = 0;
                    BlocProvider.of<PostsCubit>(context).getchoiceshistory(
                        globals.main_user.sId, current_page,
                        refresh: true);
                    // controller.animateToPage(Page_View_Index,
                    //     curve: Curves.decelerate,
                    //     duration: Duration(milliseconds: 300));
                    allhistoryposts.clear();
                  }
                },
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          backgroundColor: globals.theme_mode == ThemeMode.dark
              ? Colors.black
              : MyColors.myRed,
          title: Text(
            AppLocalizations.of(context)!.translate("Choices History"),
            style: TextStyle(
              // fontFamily: 'mad',
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
      ),
      backgroundColor:
          globals.theme_mode == ThemeMode.dark ? Colors.black : Colors.white,
      body: Main_Widget(),
    );
  }
}
