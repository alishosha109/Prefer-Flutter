import 'package:Prefer/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:Prefer/constants/strings.dart';
import 'package:Prefer/data/models/personal_post.dart';
import 'package:Prefer/presentation/widgets/shared_widgets.dart';
import '../../business_logic/cubit/posts_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/my_colors.dart';
import 'package:Prefer/constants/globals.dart' as globals;
import 'package:vibration/vibration.dart';

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

class MyPostsPage extends StatefulWidget {
  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  Color main_color = HexColor("#D32F2F");
  late List<Personal_Post> myposts;
  bool loading = true;
  int current_page = 1;
  int Page_View_Index = 0;
  bool _showPreview = false;
  List removed = [];
  String _image = "";
  DateTime last_refresh = DateTime.now();

  final PageController controller = PageController(initialPage: 0);
  @override
  void initState() {
    super.initState();
  }

  Widget buildBlocWidget() {
    BlocProvider.of<PostsCubit>(context)
        .getmyposts(globals.main_user.sId, current_page);
    return BlocConsumer<PostsCubit, PostsState>(listener: (context, state) {
      if (state is MypostsLoaded) {
        myposts = state.myposts;
        loading = false;
      } else if (state is MoreMyPostsLoaded) {
        myposts.addAll(state.myposts);
      } else if (state is MyPostsRefresh) {
        myposts = state.myposts;
        loading = false;
        removed.clear();
        Page_View_Index = 0;
      } else if (state is view_photo) {
        _showPreview = state.showstat;
        _image = state.image_url;
      } else if (state is changedstatus) {
        if (state.changed) {
          removed.add(state.postId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(AppLocalizations.of(context)!
                  .translate("Post removed from live posts")),
              backgroundColor: Colors.grey.withOpacity(0.5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(
                  AppLocalizations.of(context)!.translate("Error Occured")),
              backgroundColor: Colors.grey.withOpacity(0.5),
            ),
          );
        }
      }
    }, builder: (context, state) {
      if (state is mypostsLoading) {
        return buildLoadedScrollerWidget();
      } else if (state is mypostsEmpty) {
        myposts = [];
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context)!.translate(
                        "You didn't upload any posts yet, go add one now!"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: globals.theme_mode == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
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
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GestureDetector(
            onLongPress: () {
              Vibration.vibrate(duration: 200);

              BlocProvider.of<PostsCubit>(context)
                  .viewphoto(true, myposts[index].photos![0][0]);
            },
            onLongPressUp: () {
              BlocProvider.of<PostsCubit>(context).viewphoto(false, "");
            },
            child: Container(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.36,
                        child: SizedBox.expand(
                          child: FittedBox(
                            child: CachedNetworkImage(
                              imageUrl: '${myposts[index].photos![0][0]}',
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
                    ],
                  ),
                  Container(
                    child: Align(
                        child: Text(
                      "${myposts[index].photos![0][1]} % (${((int.parse(myposts[index].photos![0][1]) / 100) * (myposts[index].totalAnswers!)).toInt()})",
                      style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'lone'),
                    )),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height *
                        0.36 *
                        int.parse(myposts[index].photos![0][1]) /
                        100,
                    color: Color.fromARGB(255, 13, 81, 1).withOpacity(0.3),
                  )
                ],
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
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GestureDetector(
            onLongPress: () {
              Vibration.vibrate(duration: 200);

              BlocProvider.of<PostsCubit>(context)
                  .viewphoto(true, myposts[index].photos![1][0]);
            },
            onLongPressUp: () {
              BlocProvider.of<PostsCubit>(context).viewphoto(false, "");
            },
            child: Container(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.36,
                    child: SizedBox.expand(
                      child: FittedBox(
                        child: CachedNetworkImage(
                          imageUrl: '${myposts[index].photos![1][0]}',
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
                  Container(
                    child: Align(
                        child: Text(
                      "${myposts[index].photos![1][1]} % (${((int.parse(myposts[index].photos![1][1]) / 100) * (myposts[index].totalAnswers!)).toInt()})",
                      style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'lone'),
                    )),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height *
                        0.36 *
                        int.parse(myposts[index].photos![1][1]) /
                        100,
                    color: Color.fromARGB(255, 13, 81, 1).withOpacity(0.3),
                  )
                ],
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
            myposts[index].photos!.length != 2
                ? Container(
                    child: Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onLongPress: () {
                                Vibration.vibrate(duration: 200);

                                BlocProvider.of<PostsCubit>(context).viewphoto(
                                    true, myposts[index].photos![0][0]);
                              },
                              onLongPressUp: () {
                                BlocProvider.of<PostsCubit>(context)
                                    .viewphoto(false, "");
                              },
                              child: Container(
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 130),
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
                                                    '${myposts[index].photos![0][0]}',
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
                                    Container(
                                      child: Align(
                                          child: Text(
                                        "${myposts[index].photos![0][1]} % (${((int.parse(myposts[index].photos![0][1]) / 100) * (myposts[index].totalAnswers!)).toInt()})",
                                        style: TextStyle(
                                            //fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'lone'),
                                      )),
                                      width: double.infinity,
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.34 *
                                          int.parse(
                                              myposts[index].photos![0][1]) /
                                          100,
                                      color: Color.fromARGB(255, 13, 81, 1)
                                          .withOpacity(0.3),
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
            myposts[index].photos!.length != 2
                ? Container(
                    child: Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onLongPress: () {
                                Vibration.vibrate(duration: 200);

                                BlocProvider.of<PostsCubit>(context).viewphoto(
                                    true, myposts[index].photos![1][0]);
                              },
                              onLongPressUp: () {
                                BlocProvider.of<PostsCubit>(context)
                                    .viewphoto(false, "");
                              },
                              child: Container(
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 130),
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
                                                '${myposts[index].photos![1][0]}',
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
                                    Container(
                                      child: Align(
                                          child: Text(
                                        "${myposts[index].photos![1][1]} % (${((int.parse(myposts[index].photos![1][1]) / 100) * (myposts[index].totalAnswers!)).toInt()})",
                                        style: TextStyle(
                                            //fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'lone'),
                                      )),
                                      width: double.infinity,
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.34 *
                                          int.parse(
                                              myposts[index].photos![1][1]) /
                                          100,
                                      color: Color.fromARGB(255, 13, 81, 1)
                                          .withOpacity(0.3),
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
        myposts[index].hidden == false && !removed.contains(myposts[index].sId)
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: GestureDetector(
              onLongPress: () {
                Vibration.vibrate(duration: 200);

                BlocProvider.of<PostsCubit>(context)
                    .viewphoto(true, myposts[index].photos![2][0]);
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
                      height: MediaQuery.of(context).size.height * 0.34,
                      child: SizedBox.expand(
                        child: FittedBox(
                          child: CachedNetworkImage(
                            imageUrl: '${myposts[index].photos![2][0]}',
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
                    Container(
                      child: Align(
                          child: Text(
                        "${myposts[index].photos![2][1]} % (${((int.parse(myposts[index].photos![2][1]) / 100) * (myposts[index].totalAnswers!)).toInt()})",
                        style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'lone'),
                      )),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height *
                          0.34 *
                          int.parse(myposts[index].photos![2][1]) /
                          100,
                      color: Color.fromARGB(255, 13, 81, 1).withOpacity(0.3),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GestureDetector(
                onLongPress: () {
                  Vibration.vibrate(duration: 200);

                  BlocProvider.of<PostsCubit>(context)
                      .viewphoto(true, myposts[index].photos![2][0]);
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
                        height: MediaQuery.of(context).size.height * 0.34,
                        child: SizedBox.expand(
                          child: FittedBox(
                            child: CachedNetworkImage(
                              imageUrl: '${myposts[index].photos![2][0]}',
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
                      Container(
                        child: Align(
                            child: Text(
                          "${myposts[index].photos![2][1]} % (${((int.parse(myposts[index].photos![2][1]) / 100) * (myposts[index].totalAnswers!)).toInt()})",
                          style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'lone'),
                        )),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height *
                            0.34 *
                            int.parse(myposts[index].photos![2][1]) /
                            100,
                        color: Color.fromARGB(255, 13, 81, 1).withOpacity(0.3),
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
            myposts[index].photos!.length == 4
                ? First_Container_Second_Row(index)
                : myposts[index].photos!.length == 3
                    ? First_Container_Second_Row_IF_3_choices(index)
                    : First_Container_Second_Row_IF_2_Choices(index),
            myposts[index].photos!.length == 4
                ? Container(
                    child: Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onLongPress: () {
                                Vibration.vibrate(duration: 200);

                                BlocProvider.of<PostsCubit>(context).viewphoto(
                                    true, myposts[index].photos![3][0]);
                              },
                              onLongPressUp: () {
                                BlocProvider.of<PostsCubit>(context)
                                    .viewphoto(false, "");
                              },
                              child: Container(
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 130),
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
                                                '${myposts[index].photos![3][0]}',
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
                                    Container(
                                      child: Align(
                                          child: Text(
                                        "${myposts[index].photos![3][1]} % (${((int.parse(myposts[index].photos![3][1]) / 100) * (myposts[index].totalAnswers!)).toInt()})",
                                        style: TextStyle(
                                            //fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'lone'),
                                      )),
                                      width: double.infinity,
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.34 *
                                          int.parse(
                                              myposts[index].photos![3][1]) /
                                          100,
                                      color: Color.fromARGB(255, 13, 81, 1)
                                          .withOpacity(0.3),
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
        myposts[index].hidden == false && !removed.contains(myposts[index].sId)
            ? Container(
                height: MediaQuery.of(context).size.height * 0.37,
                width: 2,
                color: Colors.green,
              )
            : Container()
      ],
    );
  }

  Delete_Dialog(index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: globals.theme_mode == ThemeMode.dark
            ? Colors.black87
            : Colors.white,
        content: Text(
          AppLocalizations.of(context)!.translate(
              "Are you sure you want to remove this post from live posts?"),
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
                AppLocalizations.of(context)!.translate("Cancel"),
                style: TextStyle(color: MyColors.mywhite),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<PostsCubit>(context)
                  .changehidden(myposts[index].sId);
              Navigator.of(ctx).pop();
            },
            child: Container(
              color: MyColors.myRed,
              padding: const EdgeInsets.all(14),
              child: Text(
                AppLocalizations.of(context)!.translate("Remove"),
                style: TextStyle(color: MyColors.mywhite),
              ),
            ),
          ),
        ],
      ),
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
                  itemCount: myposts.length,
                  // physics: ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    Page_View_Index = index;
                    print(index);
                    if (index == myposts.length - 1) {
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
                      BlocProvider.of<PostsCubit>(context)
                          .getmyposts(globals.main_user.sId, current_page);
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
                                  padding: EdgeInsets.fromLTRB(17, 20, 17, 0),
                                  child: Wrap(
                                    children: [
                                      Text(
                                        "${myposts[index].description}",
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
                                    if (myposts[index].hidden == true) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content: Text(AppLocalizations.of(
                                                context)!
                                            .translate(
                                                "Post period already ended")),
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.5),
                                      ));
                                    } else {
                                      Delete_Dialog(index);
                                    }
                                  },
                                  constraints:
                                      BoxConstraints.tight(Size(36, 36)),
                                  elevation: 2.0,
                                  fillColor:
                                      globals.theme_mode == ThemeMode.dark
                                          ? main_color.withOpacity(0.5)
                                          : main_color,
                                  child: Icon(
                                    Icons.delete,
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

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey();

    return Scaffold(
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: DraggableFab(
            child: FloatingActionButton(
              mini: true,
              backgroundColor: globals.theme_mode == ThemeMode.dark
                  ? MyColors.myRedOpc
                  : MyColors.myRed,
              onPressed: () {
                Navigator.pushReplacementNamed(context, addpostScreen);
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          )),
      key: _key,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0), // here the desired height
        child: AppBar(
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

                      current_page = 1;
                      Page_View_Index = 0;
                      BlocProvider.of<PostsCubit>(context).getmyposts(
                          globals.main_user.sId, current_page,
                          refresh: true);
                      // controller.animateToPage(Page_View_Index,
                      //     curve: Curves.decelerate,
                      //     duration: Duration(milliseconds: 300));
                      myposts.clear();
                    }
                  },
                  child: Icon(
                    Icons.refresh,
                    color: globals.theme_mode == ThemeMode.dark
                        ? Colors.white
                        : Colors.white,
                  )),
            )
          ],
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.close,
              color: globals.theme_mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.white,
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: globals.theme_mode == ThemeMode.dark
              ? Colors.black
              : MyColors.myRed,
          title: Text(
            AppLocalizations.of(context)!.translate("My Posts"),
            style: TextStyle(
              color: globals.theme_mode == ThemeMode.dark
                  ? Colors.white
                  : Colors.white,
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
